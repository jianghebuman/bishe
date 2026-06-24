package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.common.BusinessException;
import com.campus.entity.JobApply;
import com.campus.entity.JobPost;
import com.campus.entity.Resume;
import com.campus.entity.SystemNotice;
import com.campus.mapper.JobApplyMapper;
import com.campus.mapper.JobPostMapper;
import com.campus.mapper.ResumeMapper;
import com.campus.mapper.SystemNoticeMapper;
import com.campus.service.JobApplyService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 职位投递服务实现（学生侧）
 *
 * @author campus
 */
@Service
public class JobApplyServiceImpl extends ServiceImpl<JobApplyMapper, JobApply> implements JobApplyService {

    @Autowired
    private JobPostMapper jobPostMapper;

    @Autowired
    private ResumeMapper resumeMapper;

    @Autowired
    private SystemNoticeMapper systemNoticeMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void apply(Long studentId, Long jobId, Long resumeId, String applyRemark) {
        // 1. 校验职位存在、已通过审核且在招聘中
        JobPost job = jobPostMapper.selectById(jobId);
        if (job == null) {
            throw new BusinessException("职位不存在");
        }
        if (job.getAuditStatus() == null || job.getAuditStatus() != 1
                || job.getStatus() == null || job.getStatus() != 1) {
            throw new BusinessException("该职位当前不可投递");
        }
        // 2. 校验简历归属当前学生
        Resume resume = resumeMapper.selectById(resumeId);
        if (resume == null || !resume.getStudentId().equals(studentId)) {
            throw new BusinessException("简历不存在或不属于当前用户");
        }
        // 3. 校验是否重复投递同一职位
        long exist = this.count(new LambdaQueryWrapper<JobApply>()
                .eq(JobApply::getStudentId, studentId)
                .eq(JobApply::getJobId, jobId));
        if (exist > 0) {
            throw new BusinessException("您已投递过该职位，请勿重复投递");
        }
        // 4. 写入投递记录，初始状态 0 待查看
        JobApply apply = new JobApply();
        apply.setStudentId(studentId);
        apply.setResumeId(resumeId);
        apply.setJobId(jobId);
        apply.setEnterpriseId(job.getEnterpriseId());
        apply.setStatus(0);
        apply.setApplyRemark(applyRemark);
        this.save(apply);
        // 5. job_post.apply_count + 1
        JobPost update = new JobPost();
        update.setId(jobId);
        update.setApplyCount((job.getApplyCount() == null ? 0 : job.getApplyCount()) + 1);
        jobPostMapper.updateById(update);
        // 6. 给企业发系统通知
        SystemNotice notice = new SystemNotice();
        notice.setReceiverId(job.getEnterpriseId());
        notice.setReceiverType("ENTERPRISE");
        notice.setTitle("收到新的简历投递");
        notice.setContent("您发布的职位【" + job.getTitle() + "】收到了一份新的简历投递，请及时查看。");
        notice.setNoticeType("APPLY");
        notice.setIsRead(0);
        systemNoticeMapper.insert(notice);
    }

    @Override
    public com.campus.common.PageResult<?> pageMyApply(Long studentId, Integer pageNum, Integer pageSize,
                                                       Integer status) {
        Page<JobApply> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<JobApply> wrapper = new LambdaQueryWrapper<JobApply>()
                .eq(JobApply::getStudentId, studentId)
                .eq(status != null, JobApply::getStatus, status)
                .orderByDesc(JobApply::getCreateTime);
        Page<JobApply> result = this.page(page, wrapper);

        List<JobApply> records = result.getRecords();
        if (records.isEmpty()) {
            return com.campus.common.PageResult.of(result.getTotal(), new ArrayList<>());
        }
        // 填充关联职位信息，便于前端展示
        List<Long> jobIds = records.stream().map(JobApply::getJobId).collect(Collectors.toList());
        Map<Long, JobPost> jobMap = jobPostMapper.selectBatchIds(jobIds).stream()
                .collect(Collectors.toMap(JobPost::getId, j -> j, (a, b) -> a));

        List<Map<String, Object>> list = new ArrayList<>();
        for (JobApply apply : records) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("id", apply.getId());
            item.put("jobId", apply.getJobId());
            item.put("resumeId", apply.getResumeId());
            item.put("enterpriseId", apply.getEnterpriseId());
            item.put("status", apply.getStatus());
            item.put("applyRemark", apply.getApplyRemark());
            item.put("hrRemark", apply.getHrRemark());
            item.put("createTime", apply.getCreateTime());
            item.put("job", jobMap.get(apply.getJobId()));
            list.add(item);
        }
        return com.campus.common.PageResult.of(result.getTotal(), list);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void withdraw(Long studentId, Long applyId) {
        JobApply apply = this.getById(applyId);
        if (apply == null) {
            throw new BusinessException("投递记录不存在");
        }
        if (!apply.getStudentId().equals(studentId)) {
            throw new BusinessException("无权操作他人投递记录");
        }
        // 仅在企业尚未进入面试/笔试/录用流程（0待查看、1已查看）时允许撤回
        Integer status = apply.getStatus();
        if (status != null && status > 1) {
            throw new BusinessException("企业已处理该投递，无法撤回");
        }
        this.removeById(applyId);
        // 撤回后职位投递数 -1（避免减成负数）
        JobPost job = jobPostMapper.selectById(apply.getJobId());
        if (job != null && job.getApplyCount() != null && job.getApplyCount() > 0) {
            JobPost update = new JobPost();
            update.setId(job.getId());
            update.setApplyCount(job.getApplyCount() - 1);
            jobPostMapper.updateById(update);
        }
    }
}
