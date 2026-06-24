package com.campus.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.common.PageResult;
import com.campus.entity.JobApply;

/**
 * 职位投递服务（学生侧）
 *
 * @author campus
 */
public interface JobApplyService extends IService<JobApply> {

    /**
     * 投递职位：
     * 校验是否重复投递同一职位，写入投递记录后 job_post.apply_count+1，并给企业发系统通知。
     */
    void apply(Long studentId, Long jobId, Long resumeId, String applyRemark);

    /** 我的投递分页（status 可空，表示全部） */
    PageResult<?> pageMyApply(Long studentId, Integer pageNum, Integer pageSize, Integer status);

    /** 撤回投递（仅本人、且企业尚未处理时允许） */
    void withdraw(Long studentId, Long applyId);
}
