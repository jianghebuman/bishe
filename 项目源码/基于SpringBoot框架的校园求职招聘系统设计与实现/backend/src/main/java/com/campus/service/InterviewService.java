package com.campus.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.common.PageResult;
import com.campus.entity.InterviewNotice;

/**
 * 面试服务（企业HR端）
 *
 * @author campus
 */
public interface InterviewService extends IService<InterviewNotice> {

    /**
     * 发送面试邀请：写 interview_notice（student_status=0 待确认），
     * 把对应 job_apply.status 置 2（邀请面试），并给学生发系统通知。
     *
     * @return 新面试通知ID
     */
    Long invite(InterviewNotice notice);

    /**
     * 我发出的面试分页（按当前企业，可按学生确认状态筛选）
     *
     * @param pageNum       页码
     * @param pageSize      每页数量
     * @param studentStatus 学生确认状态（可空）：0待确认 1已确认 2已拒绝
     */
    PageResult<InterviewNotice> myInterviewPage(Integer pageNum, Integer pageSize, Integer studentStatus);

    /** 设置/修改面试信息（仅限当前企业自己发出的面试） */
    void updateInterview(InterviewNotice notice);

    /**
     * 录入面试评价（写 interview_feedback）
     *
     * @param noticeId    面试通知ID
     * @param score       评分
     * @param content     评价内容
     * @param isPass      是否通过：1通过 0不通过
     * @param interviewer 面试官
     */
    void feedback(Long noticeId, Integer score, String content, Integer isPass, String interviewer);
}
