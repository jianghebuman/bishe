package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.common.BusinessException;
import com.campus.common.PageResult;
import com.campus.common.UserContext;
import com.campus.entity.JobPost;
import com.campus.mapper.JobPostMapper;
import com.campus.service.JobPostService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;
import java.util.List;

/**
 * 职位服务实现（企业HR端）
 *
 * @author campus
 */
@Service
public class JobPostServiceImpl extends ServiceImpl<JobPostMapper, JobPost> implements JobPostService {

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long publishJob(JobPost jobPost) {
        Long enterpriseId = UserContext.getUserId();
        if (jobPost.getTitle() == null || jobPost.getTitle().trim().isEmpty()) {
            throw new BusinessException("职位名称不能为空");
        }
        // 强制归属当前企业，前端传入的归属字段无效
        jobPost.setId(null);
        jobPost.setEnterpriseId(enterpriseId);
        jobPost.setAuditStatus(0);
        jobPost.setStatus(1);
        jobPost.setPublishTime(new Date());
        if (jobPost.getViewCount() == null) {
            jobPost.setViewCount(0);
        }
        if (jobPost.getApplyCount() == null) {
            jobPost.setApplyCount(0);
        }
        // 重新发布需清空原审核驳回原因
        jobPost.setAuditRemark(null);
        this.save(jobPost);
        return jobPost.getId();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateJob(JobPost jobPost) {
        Long enterpriseId = UserContext.getUserId();
        JobPost db = this.getById(jobPost.getId());
        if (db == null || !enterpriseId.equals(db.getEnterpriseId())) {
            throw new BusinessException("职位不存在或无权操作");
        }
        // 不允许修改归属与统计字段
        jobPost.setEnterpriseId(enterpriseId);
        jobPost.setViewCount(null);
        jobPost.setApplyCount(null);
        // 编辑后重新进入待审核
        jobPost.setAuditStatus(0);
        jobPost.setAuditRemark(null);
        this.updateById(jobPost);
    }

    @Override
    public void deleteJob(Long jobId) {
        Long enterpriseId = UserContext.getUserId();
        JobPost db = this.getById(jobId);
        if (db == null || !enterpriseId.equals(db.getEnterpriseId())) {
            throw new BusinessException("职位不存在或无权操作");
        }
        this.removeById(jobId);
    }

    @Override
    public void changeStatus(Long jobId, Integer status) {
        Long enterpriseId = UserContext.getUserId();
        if (status == null || (status != 0 && status != 1)) {
            throw new BusinessException("状态值非法");
        }
        JobPost db = this.getById(jobId);
        if (db == null || !enterpriseId.equals(db.getEnterpriseId())) {
            throw new BusinessException("职位不存在或无权操作");
        }
        JobPost update = new JobPost();
        update.setId(jobId);
        update.setStatus(status);
        this.updateById(update);
    }

    @Override
    public void refresh(List<Long> jobIds) {
        Long enterpriseId = UserContext.getUserId();
        if (jobIds == null || jobIds.isEmpty()) {
            throw new BusinessException("请选择要刷新的职位");
        }
        // 批量更新 publishTime，限定当前企业，避免越权刷新
        LambdaUpdateWrapper<JobPost> wrapper = new LambdaUpdateWrapper<JobPost>()
                .set(JobPost::getPublishTime, new Date())
                .eq(JobPost::getEnterpriseId, enterpriseId)
                .in(JobPost::getId, jobIds);
        this.update(wrapper);
    }

    @Override
    public PageResult<JobPost> myJobPage(Integer pageNum, Integer pageSize, Integer status, Integer auditStatus) {
        Long enterpriseId = UserContext.getUserId();
        Page<JobPost> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<JobPost> wrapper = new LambdaQueryWrapper<JobPost>()
                .eq(JobPost::getEnterpriseId, enterpriseId)
                .eq(status != null, JobPost::getStatus, status)
                .eq(auditStatus != null, JobPost::getAuditStatus, auditStatus)
                .orderByDesc(JobPost::getCreateTime);
        this.page(page, wrapper);
        return PageResult.of(page.getTotal(), page.getRecords());
    }

    @Override
    public JobPost getDetail(Long jobId) {
        Long enterpriseId = UserContext.getUserId();
        JobPost db = this.getById(jobId);
        if (db == null || !enterpriseId.equals(db.getEnterpriseId())) {
            throw new BusinessException("职位不存在或无权查看");
        }
        return db;
    }
}
