package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.common.BusinessException;
import com.campus.common.PageResult;
import com.campus.common.UserContext;
import com.campus.entity.JobApply;
import com.campus.entity.JobPost;
import com.campus.entity.Resume;
import com.campus.entity.ResumeAttachment;
import com.campus.entity.ResumeEducation;
import com.campus.entity.ResumeExperience;
import com.campus.entity.ResumeProject;
import com.campus.entity.Student;
import com.campus.mapper.JobApplyMapper;
import com.campus.mapper.JobPostMapper;
import com.campus.mapper.ResumeAttachmentMapper;
import com.campus.mapper.ResumeEducationMapper;
import com.campus.mapper.ResumeExperienceMapper;
import com.campus.mapper.ResumeMapper;
import com.campus.mapper.ResumeProjectMapper;
import com.campus.mapper.StudentMapper;
import com.campus.service.EnterpriseApplyService;
import com.campus.service.SystemNoticeService;
import com.campus.vo.EnterpriseApplyDetailVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 企业端投递（收到的简历）服务实现。
 * 独立于学生模块的 JobApplyService，仅承载企业HR视角操作。
 *
 * @author campus
 */
@Service
public class EnterpriseApplyServiceImpl extends ServiceImpl<JobApplyMapper, JobApply>
        implements EnterpriseApplyService {

    @Autowired
    private SystemNoticeService systemNoticeService;

    @Autowired
    private JobPostMapper jobPostMapper;
    @Autowired
    private StudentMapper studentMapper;
    @Autowired
    private ResumeMapper resumeMapper;
    @Autowired
    private ResumeEducationMapper resumeEducationMapper;
    @Autowired
    private ResumeProjectMapper resumeProjectMapper;
    @Autowired
    private ResumeExperienceMapper resumeExperienceMapper;
    @Autowired
    private ResumeAttachmentMapper resumeAttachmentMapper;

    /** 投递状态文案，用于通知内容 */
    private static final String[] STATUS_TEXT = {"待查看", "已查看", "邀请面试", "笔试", "已录用", "不合适"};

    @Override
    public PageResult<JobApply> receivedPage(Integer pageNum, Integer pageSize, Long jobId, Integer status) {
        Long enterpriseId = UserContext.getUserId();
        Page<JobApply> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<JobApply> wrapper = new LambdaQueryWrapper<JobApply>()
                .eq(JobApply::getEnterpriseId, enterpriseId)
                .eq(jobId != null, JobApply::getJobId, jobId)
                .eq(status != null, JobApply::getStatus, status)
                .orderByDesc(JobApply::getCreateTime);
        this.page(page, wrapper);
        List<JobApply> records = page.getRecords();
        List<Long> studentIds = records.stream()
                .map(JobApply::getStudentId)
                .filter(java.util.Objects::nonNull)
                .distinct()
                .collect(Collectors.toList());
        Map<Long, String> nameMap = studentIds.isEmpty() ? Collections.emptyMap()
                : studentMapper.selectBatchIds(studentIds).stream()
                .collect(Collectors.toMap(Student::getId, Student::getRealName));
        records.forEach(apply -> apply.setStudentName(nameMap.get(apply.getStudentId())));
        return PageResult.of(page.getTotal(), page.getRecords());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateStatus(Long applyId, Integer status, String hrRemark) {
        Long enterpriseId = UserContext.getUserId();
        if (status == null || status < 0 || status > 5) {
            throw new BusinessException("投递状态非法");
        }
        JobApply apply = this.getById(applyId);
        if (apply == null || !enterpriseId.equals(apply.getEnterpriseId())) {
            throw new BusinessException("投递记录不存在或无权操作");
        }
        JobApply update = new JobApply();
        update.setId(applyId);
        update.setStatus(status);
        update.setHrRemark(hrRemark);
        this.updateById(update);
        if (!status.equals(apply.getStatus())) {
            sendNotice(apply.getStudentId(), apply.getJobId(), status);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public EnterpriseApplyDetailVO viewDetail(Long applyId) {
        Long enterpriseId = UserContext.getUserId();
        JobApply apply = this.getById(applyId);
        if (apply == null || !enterpriseId.equals(apply.getEnterpriseId())) {
            throw new BusinessException("投递记录不存在或无权查看");
        }
        // status=0 待查看 -> 1 已查看
        if (Integer.valueOf(0).equals(apply.getStatus())) {
            JobApply update = new JobApply();
            update.setId(applyId);
            update.setStatus(1);
            this.updateById(update);
            apply.setStatus(1);
            sendNotice(apply.getStudentId(), apply.getJobId(), 1);
        }
        Student student = studentMapper.selectById(apply.getStudentId());
        Resume resume = apply.getResumeId() == null ? null : resumeMapper.selectById(apply.getResumeId());
        if (resume != null && !apply.getStudentId().equals(resume.getStudentId())) {
            resume = null;
        }

        EnterpriseApplyDetailVO detail = new EnterpriseApplyDetailVO();
        detail.setApply(apply);
        detail.setApplicantName(student == null ? null : student.getRealName());
        detail.setResume(resume);
        if (resume != null) {
            detail.setEducations(resumeEducationMapper.selectList(new LambdaQueryWrapper<ResumeEducation>()
                    .eq(ResumeEducation::getResumeId, resume.getId())));
            detail.setProjects(resumeProjectMapper.selectList(new LambdaQueryWrapper<ResumeProject>()
                    .eq(ResumeProject::getResumeId, resume.getId())));
            detail.setExperiences(resumeExperienceMapper.selectList(new LambdaQueryWrapper<ResumeExperience>()
                    .eq(ResumeExperience::getResumeId, resume.getId())));
        }
        detail.setAttachments(resumeAttachmentMapper.selectList(new LambdaQueryWrapper<ResumeAttachment>()
                .eq(ResumeAttachment::getStudentId, apply.getStudentId())));
        return detail;
    }

    /** 构造并发送投递状态变更通知 */
    private void sendNotice(Long studentId, Long jobId, Integer status) {
        String jobTitle = "";
        JobPost job = jobPostMapper.selectById(jobId);
        if (job != null) {
            jobTitle = job.getTitle();
        }
        String text = (status >= 0 && status < STATUS_TEXT.length) ? STATUS_TEXT[status] : "已更新";
        systemNoticeService.send(studentId, "STUDENT", "投递状态更新",
                "您投递的职位「" + jobTitle + "」状态已更新为：" + text,
                "APPLY");
    }
}
