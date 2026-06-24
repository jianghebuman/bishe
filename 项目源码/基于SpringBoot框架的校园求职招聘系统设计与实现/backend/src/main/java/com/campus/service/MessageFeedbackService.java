package com.campus.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.entity.MessageFeedback;

/**
 * 留言反馈服务
 *
 * @author campus
 */
public interface MessageFeedbackService extends IService<MessageFeedback> {

    /** 回复留言 */
    void reply(Long id, String reply);
}
