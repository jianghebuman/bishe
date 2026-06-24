package com.campus.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.common.PageResult;
import com.campus.common.Result;
import com.campus.common.UserContext;
import com.campus.entity.SystemNotice;
import com.campus.mapper.SystemNoticeMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * 消息中心：登录用户查看自己的系统消息（按 receiverId + receiverType 归属）。
 * 不限定角色，仅需登录（由登录拦截器保证）。
 *
 * @author campus
 */
@RestController
@RequestMapping("/notice")
public class NoticeController {

    @Autowired
    private SystemNoticeMapper systemNoticeMapper;

    /** 我的消息分页：receiverId=当前用户，receiverType=当前角色 */
    @GetMapping("/list")
    public Result<PageResult<SystemNotice>> list(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) Integer isRead) {
        LambdaQueryWrapper<SystemNotice> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SystemNotice::getReceiverId, UserContext.getUserId())
                .eq(SystemNotice::getReceiverType, UserContext.getRole())
                .eq(isRead != null, SystemNotice::getIsRead, isRead)
                .orderByDesc(SystemNotice::getCreateTime);
        Page<SystemNotice> page = systemNoticeMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
        return Result.success(PageResult.of(page.getTotal(), page.getRecords()));
    }

    /** 未读消息数 */
    @GetMapping("/unread-count")
    public Result<Long> unreadCount() {
        LambdaQueryWrapper<SystemNotice> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SystemNotice::getReceiverId, UserContext.getUserId())
                .eq(SystemNotice::getReceiverType, UserContext.getRole())
                .eq(SystemNotice::getIsRead, 0);
        return Result.success(systemNoticeMapper.selectCount(wrapper));
    }

    /** 标记单条消息为已读（仅能标记属于自己的消息） */
    @PostMapping("/{id}/read")
    public Result<Void> read(@PathVariable Long id) {
        SystemNotice notice = systemNoticeMapper.selectById(id);
        if (notice == null) {
            return Result.error("消息不存在");
        }
        if (!UserContext.getUserId().equals(notice.getReceiverId())
                || !UserContext.getRole().equals(notice.getReceiverType())) {
            return Result.error("无权操作他人消息");
        }
        SystemNotice update = new SystemNotice();
        update.setId(id);
        update.setIsRead(1);
        systemNoticeMapper.updateById(update);
        return Result.success("已标记为已读", null);
    }

    /** 全部标记为已读 */
    @PostMapping("/read-all")
    public Result<Void> readAll() {
        SystemNotice update = new SystemNotice();
        update.setIsRead(1);
        LambdaQueryWrapper<SystemNotice> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SystemNotice::getReceiverId, UserContext.getUserId())
                .eq(SystemNotice::getReceiverType, UserContext.getRole())
                .eq(SystemNotice::getIsRead, 0);
        systemNoticeMapper.update(update, wrapper);
        return Result.success("已全部标记为已读", null);
    }
}
