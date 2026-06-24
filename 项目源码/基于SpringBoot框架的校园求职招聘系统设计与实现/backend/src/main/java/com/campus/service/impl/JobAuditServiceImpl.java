package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.common.BusinessException;
import com.campus.common.PageResult;
import com.campus.entity.Enterprise;
import com.campus.entity.JobCategory;
import com.campus.entity.JobPost;
import com.campus.mapper.EnterpriseMapper;
import com.campus.mapper.JobCategoryMapper;
import com.campus.mapper.JobPostMapper;
import com.campus.service.JobAuditService;
import com.campus.vo.JobAuditVO;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

/**
 * 岗位审核服务实现（管理员端）
 *
 * @author campus
 */
@Service
public class JobAuditServiceImpl implements JobAuditService {

    @Autowired
    private JobPostMapper jobPostMapper;
    @Autowired
    private EnterpriseMapper enterpriseMapper;
    @Autowired
    private JobCategoryMapper jobCategoryMapper;

    @Override
    public PageResult<JobAuditVO> auditPage(Integer pageNum, Integer pageSize, Integer auditStatus, String title) {
        Page<JobPost> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<JobPost> wrapper = new LambdaQueryWrapper<JobPost>()
                .eq(auditStatus != null, JobPost::getAuditStatus, auditStatus)
                .like(title != null && !title.isEmpty(), JobPost::getTitle, title)
                .orderByDesc(JobPost::getCreateTime);
        jobPostMapper.selectPage(page, wrapper);
        List<JobPost> records = page.getRecords();
        if (records.isEmpty()) {
            return PageResult.of(page.getTotal(), Collections.emptyList());
        }
        // 批量查企业名、类别名，避免 N+1
        Set<Long> entIds = records.stream().map(JobPost::getEnterpriseId).filter(Objects::nonNull).collect(Collectors.toSet());
        Set<Long> catIds = records.stream().map(JobPost::getCategoryId).filter(Objects::nonNull).collect(Collectors.toSet());
        Map<Long, String> entNameMap = new HashMap<>();
        if (!entIds.isEmpty()) {
            for (Enterprise e : enterpriseMapper.selectBatchIds(entIds)) {
                entNameMap.put(e.getId(), e.getCompanyName());
            }
        }
        Map<Long, String> catNameMap = new HashMap<>();
        if (!catIds.isEmpty()) {
            for (JobCategory c : jobCategoryMapper.selectBatchIds(catIds)) {
                catNameMap.put(c.getId(), c.getName());
            }
        }
        List<JobAuditVO> list = records.stream().map(jp -> {
            JobAuditVO vo = new JobAuditVO();
            BeanUtils.copyProperties(jp, vo);
            vo.setCompanyName(entNameMap.get(jp.getEnterpriseId()));
            vo.setCategoryName(catNameMap.get(jp.getCategoryId()));
            return vo;
        }).collect(Collectors.toList());
        return PageResult.of(page.getTotal(), list);
    }

    @Override
    public void pass(Long jobId) {
        JobPost db = jobPostMapper.selectById(jobId);
        if (db == null) {
            throw new BusinessException("岗位不存在");
        }
        JobPost update = new JobPost();
        update.setId(jobId);
        update.setAuditStatus(1);
        update.setAuditRemark("");
        jobPostMapper.updateById(update);
    }

    @Override
    public void reject(Long jobId, String auditRemark) {
        JobPost db = jobPostMapper.selectById(jobId);
        if (db == null) {
            throw new BusinessException("岗位不存在");
        }
        JobPost update = new JobPost();
        update.setId(jobId);
        update.setAuditStatus(2);
        update.setAuditRemark(auditRemark);
        jobPostMapper.updateById(update);
    }

    @Override
    public void offline(Long jobId) {
        JobPost db = jobPostMapper.selectById(jobId);
        if (db == null) {
            throw new BusinessException("岗位不存在");
        }
        JobPost update = new JobPost();
        update.setId(jobId);
        update.setStatus(0);
        jobPostMapper.updateById(update);
    }
}
