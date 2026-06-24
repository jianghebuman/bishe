package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.common.BusinessException;
import com.campus.common.PageResult;
import com.campus.common.UserContext;
import com.campus.entity.JobApply;
import com.campus.entity.JobPost;
import com.campus.entity.SystemNotice;
import com.campus.mapper.JobApplyMapper;
import com.campus.mapper.JobPostMapper;
import com.campus.mapper.SystemNoticeMapper;
import com.campus.service.EnterpriseApplyService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
    private SystemNoticeMapper systemNoticeMapper;

    @Autowired
    private JobPostMapper jobPostMapper;

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
        // 给学生发系统通知
        sendNotice(apply.getStudentId(), apply.getJobId(), status);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public JobApply viewDetail(Long applyId) {
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
        }
        return apply;
    }

    /** 构造并发送投递状态变更通知 */
    private void sendNotice(Long studentId, Long jobId, Integer status) {
        String jobTitle = "";
        JobPost job = jobPostMapper.selectById(jobId);
        if (job != null) {
            jobTitle = job.getTitle();
        }
        String text = (status >= 0 && status < STATUS_TEXT.length) ? STATUS_TEXT[status] : "已更新";
        SystemNotice notice = new SystemNotice();
        notice.setReceiverId(studentId);
        notice.setReceiverType("STUDENT");
        notice.setTitle("投递状态更新");
        notice.setContent("您投递的职位「" + jobTitle + "」状态已更新为：" + text);
        notice.setNoticeType("APPLY");
        notice.setIsRead(0);
        systemNoticeMapper.insert(notice);
    }
}
