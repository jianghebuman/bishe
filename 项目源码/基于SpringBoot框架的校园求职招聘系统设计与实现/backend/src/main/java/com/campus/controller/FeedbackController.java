package com.campus.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.common.PageResult;
import com.campus.common.RequireRole;
import com.campus.common.Result;
import com.campus.entity.MessageFeedback;
import com.campus.service.MessageFeedbackService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 管理员-留言反馈管理
 *
 * @author campus
 */
@RestController
@RequestMapping("/admin/feedback")
@RequireRole("ADMIN")
public class FeedbackController {

    @Autowired
    private MessageFeedbackService messageFeedbackService;

    @GetMapping
    public Result<PageResult<MessageFeedback>> page(@RequestParam(defaultValue = "1") Integer pageNum,
                                                    @RequestParam(defaultValue = "10") Integer pageSize,
                                                    @RequestParam(required = false) Integer status) {
        Page<MessageFeedback> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<MessageFeedback> wrapper = new LambdaQueryWrapper<MessageFeedback>()
                .eq(status != null, MessageFeedback::getStatus, status)
                .orderByDesc(MessageFeedback::getCreateTime);
        messageFeedbackService.page(page, wrapper);
        return Result.success(PageResult.of(page.getTotal(), page.getRecords()));
    }

    @PutMapping("/{id}/reply")
    public Result<Void> reply(@PathVariable Long id, @RequestParam String reply) {
        messageFeedbackService.reply(id, reply);
        return Result.success("回复成功", null);
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        messageFeedbackService.removeById(id);
        return Result.success("删除成功", null);
    }
}
