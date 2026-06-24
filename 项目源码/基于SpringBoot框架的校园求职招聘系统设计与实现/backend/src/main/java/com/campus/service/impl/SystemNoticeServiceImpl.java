package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.entity.SystemNotice;
import com.campus.mapper.SystemNoticeMapper;
import com.campus.service.SystemNoticeService;
import org.springframework.stereotype.Service;

/**
 * 系统消息通知服务实现
 *
 * @author campus
 */
@Service
public class SystemNoticeServiceImpl extends ServiceImpl<SystemNoticeMapper, SystemNotice> implements SystemNoticeService {

    @Override
    public void send(Long receiverId, String receiverType, String title, String content, String noticeType) {
        SystemNotice notice = new SystemNotice();
        notice.setReceiverId(receiverId);
        notice.setReceiverType(receiverType);
        notice.setTitle(title);
        notice.setContent(content);
        notice.setNoticeType(noticeType == null ? "SYSTEM" : noticeType);
        notice.setIsRead(0);
        this.save(notice);
    }

    @Override
    public long unreadCount(Long receiverId, String receiverType) {
        return this.count(new LambdaQueryWrapper<SystemNotice>()
                .eq(SystemNotice::getReceiverId, receiverId)
                .eq(SystemNotice::getReceiverType, receiverType)
                .eq(SystemNotice::getIsRead, 0));
    }
}
