package com.campus.controller;

import com.campus.common.PageResult;
import com.campus.common.RequireRole;
import com.campus.common.Result;
import com.campus.entity.InterviewNotice;
import com.campus.entity.JobApply;
import com.campus.entity.JobPost;
import com.campus.entity.OfferRecord;
import com.campus.entity.Resume;
import com.campus.entity.TalentPool;
import com.campus.service.EnterpriseApplyService;
import com.campus.service.InterviewService;
import com.campus.service.JobPostService;
import com.campus.service.OfferService;
import com.campus.service.TalentPoolService;
import com.campus.vo.EnterpriseApplyDetailVO;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 企业端：职位、简历筛选、面试、Offer、人才库
 *
 * @author campus
 */
@RestController
@RequestMapping("/enterprise")
@RequireRole("ENTERPRISE")
public class EnterpriseBusinessController {

    @Autowired
    private JobPostService jobPostService;
    @Autowired
    private EnterpriseApplyService enterpriseApplyService;
    @Autowired
    private InterviewService interviewService;
    @Autowired
    private OfferService offerService;
    @Autowired
    private TalentPoolService talentPoolService;

    // ==================== 职位管理 ====================
    @GetMapping("/job")
    public Result<PageResult<JobPost>> jobPage(@RequestParam(defaultValue = "1") Integer pageNum,
                                               @RequestParam(defaultValue = "10") Integer pageSize,
                                               @RequestParam(required = false) Integer status,
                                               @RequestParam(required = false) Integer auditStatus) {
        return Result.success(jobPostService.myJobPage(pageNum, pageSize, status, auditStatus));
    }

    @GetMapping("/job/{id}")
    public Result<JobPost> jobDetail(@PathVariable Long id) {
        return Result.success(jobPostService.getDetail(id));
    }

    @PostMapping("/job")
    public Result<Long> publishJob(@RequestBody JobPost jobPost) {
        return Result.success("职位已提交审核", jobPostService.publishJob(jobPost));
    }

    @PutMapping("/job")
    public Result<Void> updateJob(@RequestBody JobPost jobPost) {
        jobPostService.updateJob(jobPost);
        return Result.success("职位修改成功，已重新进入审核", null);
    }

    @DeleteMapping("/job/{id}")
    public Result<Void> deleteJob(@PathVariable Long id) {
        jobPostService.deleteJob(id);
        return Result.success("删除成功", null);
    }

    @PutMapping("/job/{id}/status")
    public Result<Void> changeStatus(@PathVariable Long id, @RequestParam Integer status) {
        jobPostService.changeStatus(id, status);
        return Result.success(status == 1 ? "已上架" : "已下架", null);
    }

    @PutMapping("/job/{id}/refresh")
    public Result<Void> refreshOne(@PathVariable Long id) {
        jobPostService.refresh(java.util.Collections.singletonList(id));
        return Result.success("刷新成功", null);
    }

    @PutMapping("/job/refresh")
    public Result<Void> refreshBatch(@RequestBody List<Long> ids) {
        jobPostService.refresh(ids);
        return Result.success("批量刷新成功", null);
    }

    // ==================== 收到的简历 ====================
    @GetMapping("/apply")
    public Result<PageResult<JobApply>> applyPage(@RequestParam(defaultValue = "1") Integer pageNum,
                                                  @RequestParam(defaultValue = "10") Integer pageSize,
                                                  @RequestParam(required = false) Long jobId,
                                                  @RequestParam(required = false) Integer status) {
        return Result.success(enterpriseApplyService.receivedPage(pageNum, pageSize, jobId, status));
    }

    @GetMapping("/apply/{id}")
    public Result<EnterpriseApplyDetailVO> applyDetail(@PathVariable Long id) {
        return Result.success(enterpriseApplyService.viewDetail(id));
    }

    @PutMapping("/apply/{id}/status")
    public Result<Void> updateApplyStatus(@PathVariable Long id,
                                          @RequestParam Integer status,
                                          @RequestParam(required = false) String hrRemark) {
        enterpriseApplyService.updateStatus(id, status, hrRemark);
        return Result.success("状态更新成功", null);
    }

    // ==================== 面试管理 ====================
    @PostMapping("/interview")
    public Result<Long> sendInterview(@RequestBody InterviewNotice notice) {
        return Result.success("面试邀请已发送", interviewService.invite(notice));
    }

    @GetMapping("/interview")
    public Result<PageResult<InterviewNotice>> interviewPage(@RequestParam(defaultValue = "1") Integer pageNum,
                                                             @RequestParam(defaultValue = "10") Integer pageSize,
                                                             @RequestParam(required = false) Integer studentStatus) {
        return Result.success(interviewService.myInterviewPage(pageNum, pageSize, studentStatus));
    }

    @PutMapping("/interview")
    public Result<Void> updateInterview(@RequestBody InterviewNotice notice) {
        interviewService.updateInterview(notice);
        return Result.success("面试信息已更新", null);
    }

    @PostMapping("/interview/feedback")
    public Result<Void> feedback(@RequestBody FeedbackDTO dto) {
        interviewService.feedback(dto.getNoticeId(), dto.getScore(), dto.getContent(), dto.getIsPass(), dto.getInterviewer());
        return Result.success("评价已保存", null);
    }

    // ==================== Offer 管理 ====================
    @PostMapping("/offer")
    public Result<Long> sendOffer(@RequestBody OfferRecord offer) {
        return Result.success("Offer已发送", offerService.sendOffer(offer));
    }

    @GetMapping("/offer")
    public Result<PageResult<OfferRecord>> offerPage(@RequestParam(defaultValue = "1") Integer pageNum,
                                                     @RequestParam(defaultValue = "10") Integer pageSize,
                                                     @RequestParam(required = false) Integer offerStatus) {
        return Result.success(offerService.myOfferPage(pageNum, pageSize, offerStatus));
    }

    @PutMapping("/offer/{id}/revoke")
    public Result<Void> revokeOffer(@PathVariable Long id) {
        offerService.revoke(id);
        return Result.success("Offer已撤回", null);
    }

    // ==================== 人才库 ====================
    @GetMapping("/talent")
    public Result<PageResult<TalentPool>> talentPage(@RequestParam(defaultValue = "1") Integer pageNum,
                                                     @RequestParam(defaultValue = "10") Integer pageSize,
                                                     @RequestParam(required = false) String tag,
                                                     @RequestParam(required = false) String keyword) {
        return Result.success(talentPoolService.talentPage(pageNum, pageSize, tag, keyword));
    }

    @PostMapping("/talent")
    public Result<Void> addTalent(@RequestBody TalentDTO dto) {
        talentPoolService.addTalent(dto.getStudentId(), dto.getResumeId(), dto.getTag(), dto.getRemark());
        return Result.success("已加入人才库", null);
    }

    @DeleteMapping("/talent/{id}")
    public Result<Void> removeTalent(@PathVariable Long id) {
        talentPoolService.removeTalent(id);
        return Result.success("已移出人才库", null);
    }

    @GetMapping("/talent/search")
    public Result<PageResult<Resume>> searchTalent(@RequestParam(defaultValue = "1") Integer pageNum,
                                                   @RequestParam(defaultValue = "10") Integer pageSize,
                                                   @RequestParam(required = false) String major,
                                                   @RequestParam(required = false) String education,
                                                   @RequestParam(required = false) String keyword) {
        return Result.success(talentPoolService.searchResume(pageNum, pageSize, major, education, keyword));
    }

    @Data
    public static class FeedbackDTO {
        private Long noticeId;
        private Integer score;
        private String content;
        private Integer isPass;
        private String interviewer;
    }

    @Data
    public static class TalentDTO {
        private Long studentId;
        private Long resumeId;
        private String tag;
        private String remark;
    }
}
