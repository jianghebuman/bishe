package com.campus.service;

import com.campus.common.PageResult;
import com.campus.vo.JobAuditVO;

/**
 * 岗位审核服务（管理员端，独立于企业端 JobPostService）
 *
 * @author campus
 */
public interface JobAuditService {

    /**
     * 岗位审核分页
     *
     * @param pageNum     页码
     * @param pageSize    每页数量
     * @param auditStatus 审核状态：0待审核 1通过 2驳回（可空，默认查全部）
     * @param title       岗位标题关键字（可空）
     * @return 分页结果（含企业名称、类别名称）
     */
    PageResult<JobAuditVO> auditPage(Integer pageNum, Integer pageSize, Integer auditStatus, String title);

    /** 审核通过（audit_status=1，清空驳回原因） */
    void pass(Long jobId);

    /** 审核驳回（audit_status=2，记录 auditRemark） */
    void reject(Long jobId, String auditRemark);

    /** 下架违规岗位（status=0） */
    void offline(Long jobId);
}
