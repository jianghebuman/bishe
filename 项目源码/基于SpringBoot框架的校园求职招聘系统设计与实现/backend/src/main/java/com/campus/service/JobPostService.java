package com.campus.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.common.PageResult;
import com.campus.entity.JobPost;

/**
 * 职位服务（企业HR端）
 *
 * @author campus
 */
public interface JobPostService extends IService<JobPost> {

    /**
     * 发布职位（归属当前企业，audit_status=0 待审核，status=1 招聘中，publishTime=now）
     *
     * @return 新职位ID
     */
    Long publishJob(JobPost jobPost);

    /** 编辑职位（仅限当前企业自己的职位） */
    void updateJob(JobPost jobPost);

    /** 删除职位（仅限当前企业自己的职位） */
    void deleteJob(Long jobId);

    /**
     * 上架/下架职位（修改 status）
     *
     * @param jobId  职位ID
     * @param status 1招聘中 0已下架
     */
    void changeStatus(Long jobId, Integer status);

    /** 批量刷新职位（更新 publishTime 为当前时间） */
    void refresh(java.util.List<Long> jobIds);

    /**
     * 我的职位分页（按当前企业，可按 status / auditStatus 筛选）
     *
     * @param pageNum     页码
     * @param pageSize    每页数量
     * @param status      状态（可空）
     * @param auditStatus 审核状态（可空）
     */
    PageResult<JobPost> myJobPage(Integer pageNum, Integer pageSize, Integer status, Integer auditStatus);

    /** 职位详情（仅限当前企业自己的职位） */
    JobPost getDetail(Long jobId);
}
