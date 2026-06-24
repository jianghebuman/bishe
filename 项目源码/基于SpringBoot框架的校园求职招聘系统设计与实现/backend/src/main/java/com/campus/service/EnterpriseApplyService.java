package com.campus.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.common.PageResult;
import com.campus.entity.JobApply;

/**
 * 企业端投递（收到的简历）服务。
 * 注意：与学生模块的 JobApplyService 区分，这里只承载企业HR视角的操作，
 * 复用 JobApply 实体，但作为独立 Service，不覆盖学生模块文件。
 *
 * @author campus
 */
public interface EnterpriseApplyService extends IService<JobApply> {

    /**
     * 收到的简历分页（按当前企业，可按职位/状态筛选）
     *
     * @param pageNum  页码
     * @param pageSize 每页数量
     * @param jobId    职位ID（可空）
     * @param status   投递状态（可空）
     */
    PageResult<JobApply> receivedPage(Integer pageNum, Integer pageSize, Long jobId, Integer status);

    /**
     * 更新投递状态，并给学生发系统通知。
     *
     * @param applyId  投递ID
     * @param status   新状态：0待查看 1已查看 2邀请面试 3笔试 4已录用 5不合适
     * @param hrRemark HR备注
     */
    void updateStatus(Long applyId, Integer status, String hrRemark);

    /**
     * 查看简历详情：返回该投递记录，并把 status=0（待查看）的置为 1（已查看）。
     *
     * @param applyId 投递ID
     */
    JobApply viewDetail(Long applyId);
}
