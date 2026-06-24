package com.campus.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.entity.SystemNotice;

/**
 * 系统消息通知服务
 *
 * @author campus
 */
public interface SystemNoticeService extends IService<SystemNotice> {

    /** 发送通知 */
    void send(Long receiverId, String receiverType, String title, String content, String noticeType);

    /** 当前用户未读数量 */
    long unreadCount(Long receiverId, String receiverType);
}
