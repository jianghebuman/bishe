package com.campus.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.common.BusinessException;
import com.campus.entity.MessageFeedback;
import com.campus.mapper.MessageFeedbackMapper;
import com.campus.service.MessageFeedbackService;
import org.springframework.stereotype.Service;

import java.util.Date;

/**
 * 留言反馈服务实现
 *
 * @author campus
 */
@Service
public class MessageFeedbackServiceImpl extends ServiceImpl<MessageFeedbackMapper, MessageFeedback> implements MessageFeedbackService {

    @Override
    public void reply(Long id, String reply) {
        MessageFeedback fb = this.getById(id);
        if (fb == null) {
            throw new BusinessException("留言不存在");
        }
        fb.setReply(reply);
        fb.setReplyTime(new Date());
        fb.setStatus(1);
        this.updateById(fb);
    }
}
