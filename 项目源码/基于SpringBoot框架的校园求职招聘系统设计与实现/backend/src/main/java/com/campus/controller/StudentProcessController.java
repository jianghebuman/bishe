package com.campus.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.common.PageResult;
import com.campus.common.RequireRole;
import com.campus.common.Result;
import com.campus.common.UserContext;
import com.campus.entity.InterviewNotice;
import com.campus.entity.OfferRecord;
import com.campus.service.InterviewService;
import com.campus.service.OfferService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 学生端：面试通知与 Offer 确认
 *
 * @author campus
 */
@RestController
@RequestMapping("/student")
@RequireRole("STUDENT")
public class StudentProcessController {

    @Autowired
    private InterviewService interviewService;

    @Autowired
    private OfferService offerService;

    /** 我的面试通知分页 */
    @GetMapping("/interview")
    public Result<PageResult<InterviewNotice>> interviews(@RequestParam(defaultValue = "1") Integer pageNum,
                                                          @RequestParam(defaultValue = "10") Integer pageSize,
                                                          @RequestParam(required = false) Integer studentStatus) {
        Page<InterviewNotice> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<InterviewNotice> wrapper = new LambdaQueryWrapper<InterviewNotice>()
                .eq(InterviewNotice::getStudentId, UserContext.getUserId())
                .eq(studentStatus != null, InterviewNotice::getStudentStatus, studentStatus)
                .orderByDesc(InterviewNotice::getInterviewTime)
                .orderByDesc(InterviewNotice::getCreateTime);
        interviewService.page(page, wrapper);
        return Result.success(PageResult.of(page.getTotal(), page.getRecords()));
    }

    /** 学生确认/拒绝面试：status=1确认，2拒绝 */
    @PutMapping("/interview/{id}/confirm")
    public Result<Void> confirmInterview(@PathVariable Long id, @RequestParam Integer status) {
        if (status == null || (status != 1 && status != 2)) {
            return Result.error("确认状态非法");
        }
        InterviewNotice notice = interviewService.getById(id);
        if (notice == null || !UserContext.getUserId().equals(notice.getStudentId())) {
            return Result.error("面试通知不存在或无权操作");
        }
        InterviewNotice update = new InterviewNotice();
        update.setId(id);
        update.setStudentStatus(status);
        interviewService.updateById(update);
        return Result.success(status == 1 ? "已确认参加面试" : "已拒绝面试", null);
    }

    /** 我的 Offer 分页 */
    @GetMapping("/offer")
    public Result<PageResult<OfferRecord>> offers(@RequestParam(defaultValue = "1") Integer pageNum,
                                                  @RequestParam(defaultValue = "10") Integer pageSize,
                                                  @RequestParam(required = false) Integer offerStatus) {
        Page<OfferRecord> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<OfferRecord> wrapper = new LambdaQueryWrapper<OfferRecord>()
                .eq(OfferRecord::getStudentId, UserContext.getUserId())
                .eq(offerStatus != null, OfferRecord::getOfferStatus, offerStatus)
                .orderByDesc(OfferRecord::getCreateTime);
        offerService.page(page, wrapper);
        return Result.success(PageResult.of(page.getTotal(), page.getRecords()));
    }

    /** 学生接受/拒绝 Offer：status=1接受，2拒绝 */
    @PutMapping("/offer/{id}/handle")
    public Result<Void> handleOffer(@PathVariable Long id, @RequestParam Integer status) {
        if (status == null || (status != 1 && status != 2)) {
            return Result.error("Offer处理状态非法");
        }
        OfferRecord offer = offerService.getById(id);
        if (offer == null || !UserContext.getUserId().equals(offer.getStudentId())) {
            return Result.error("Offer不存在或无权操作");
        }
        OfferRecord update = new OfferRecord();
        update.setId(id);
        update.setOfferStatus(status);
        offerService.updateById(update);
        return Result.success(status == 1 ? "已接受Offer" : "已拒绝Offer", null);
    }
}
