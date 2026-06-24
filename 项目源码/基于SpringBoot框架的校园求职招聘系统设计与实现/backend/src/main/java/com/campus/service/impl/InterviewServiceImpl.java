package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.common.BusinessException;
import com.campus.common.PageResult;
import com.campus.common.UserContext;
import com.campus.entity.InterviewFeedback;
import com.campus.entity.InterviewNotice;
import com.campus.entity.JobApply;
import com.campus.entity.JobPost;
import com.campus.entity.SystemNotice;
import com.campus.mapper.InterviewFeedbackMapper;
import com.campus.mapper.InterviewNoticeMapper;
import com.campus.mapper.JobApplyMapper;
import com.campus.mapper.JobPostMapper;
import com.campus.mapper.SystemNoticeMapper;
import com.campus.service.InterviewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 面试服务实现（企业HR端）
 *
 * @author campus
 */
@Service
public class InterviewServiceImpl extends ServiceImpl<InterviewNoticeMapper, InterviewNotice>
        implements InterviewService {

    @Autowired
    private JobApplyMapper jobApplyMapper;

    @Autowired
    private SystemNoticeMapper systemNoticeMapper;

    @Autowired
    private InterviewFeedbackMapper interviewFeedbackMapper;

    @Autowired
    private JobPostMapper jobPostMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long invite(InterviewNotice notice) {
        Long enterpriseId = UserContext.getUserId();
        if (notice.getApplyId() == null) {
            throw new BusinessException("缺少投递记录ID");
        }
        if (notice.getInterviewTime() == null) {
            throw new BusinessException("面试时间不能为空");
        }
        JobApply apply = jobApplyMapper.selectById(notice.getApplyId());
        if (apply == null || !enterpriseId.equals(apply.getEnterpriseId())) {
            throw new BusinessException("投递记录不存在或无权操作");
        }
        // 写面试通知，强制归属与冗余字段从投递记录回填
        notice.setId(null);
        notice.setEnterpriseId(enterpriseId);
        notice.setStudentId(apply.getStudentId());
        notice.setJobId(apply.getJobId());
        notice.setStudentStatus(0);
        if (notice.getInterviewType() == null) {
            notice.setInterviewType(1);
        }
        this.save(notice);
        // 把对应 job_apply.status 置 2（邀请面试）
        JobApply applyUpdate = new JobApply();
        applyUpdate.setId(apply.getId());
        applyUpdate.setStatus(2);
        jobApplyMapper.updateById(applyUpdate);
        // 给学生发系统通知
        String jobTitle = "";
        JobPost job = jobPostMapper.selectById(apply.getJobId());
        if (job != null) {
            jobTitle = job.getTitle();
        }
        SystemNotice sn = new SystemNotice();
        sn.setReceiverId(apply.getStudentId());
        sn.setReceiverType("STUDENT");
        sn.setTitle("面试邀请");
        sn.setContent("您收到职位「" + jobTitle + "」的面试邀请，请及时确认。");
        sn.setNoticeType("INTERVIEW");
        sn.setIsRead(0);
        systemNoticeMapper.insert(sn);
        return notice.getId();
    }

    @Override
    public PageResult<InterviewNotice> myInterviewPage(Integer pageNum, Integer pageSize, Integer studentStatus) {
        Long enterpriseId = UserContext.getUserId();
        Page<InterviewNotice> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<InterviewNotice> wrapper = new LambdaQueryWrapper<InterviewNotice>()
                .eq(InterviewNotice::getEnterpriseId, enterpriseId)
                .eq(studentStatus != null, InterviewNotice::getStudentStatus, studentStatus)
                .orderByDesc(InterviewNotice::getCreateTime);
        this.page(page, wrapper);
        return PageResult.of(page.getTotal(), page.getRecords());
    }

    @Override
    public void updateInterview(InterviewNotice notice) {
        Long enterpriseId = UserContext.getUserId();
        InterviewNotice db = this.getById(notice.getId());
        if (db == null || !enterpriseId.equals(db.getEnterpriseId())) {
            throw new BusinessException("面试记录不存在或无权操作");
        }
        // 不允许篡改归属与学生确认状态
        notice.setEnterpriseId(enterpriseId);
        notice.setStudentId(null);
        notice.setStudentStatus(null);
        this.updateById(notice);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void feedback(Long noticeId, Integer score, String content, Integer isPass, String interviewer) {
        Long enterpriseId = UserContext.getUserId();
        InterviewNotice db = this.getById(noticeId);
        if (db == null || !enterpriseId.equals(db.getEnterpriseId())) {
            throw new BusinessException("面试记录不存在或无权操作");
        }
        InterviewFeedback feedback = new InterviewFeedback();
        feedback.setNoticeId(noticeId);
        feedback.setApplyId(db.getApplyId());
        feedback.setEnterpriseId(enterpriseId);
        feedback.setScore(score);
        feedback.setContent(content);
        feedback.setIsPass(isPass);
        feedback.setInterviewer(interviewer);
        interviewFeedbackMapper.insert(feedback);
    }
}
