package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.common.BusinessException;
import com.campus.common.UserContext;
import com.campus.entity.ChatMessage;
import com.campus.entity.Enterprise;
import com.campus.entity.Student;
import com.campus.mapper.ChatMessageMapper;
import com.campus.mapper.EnterpriseMapper;
import com.campus.mapper.StudentMapper;
import com.campus.service.ChatMessageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ChatMessageServiceImpl extends ServiceImpl<ChatMessageMapper, ChatMessage> implements ChatMessageService {

    @Autowired
    private StudentMapper studentMapper;

    @Autowired
    private EnterpriseMapper enterpriseMapper;

    @Override
    public ChatMessage send(ChatMessage message) {
        String fromRole = UserContext.getRole();
        Long fromUserId = UserContext.getUserId();
        if (!"STUDENT".equals(fromRole) && !"ENTERPRISE".equals(fromRole)) {
            throw new BusinessException("仅学生和企业可发送消息");
        }
        if (message.getToUserId() == null || message.getToRole() == null || message.getContent() == null
                || message.getContent().trim().isEmpty()) {
            throw new BusinessException("消息参数不完整");
        }
        if (!"STUDENT".equals(message.getToRole()) && !"ENTERPRISE".equals(message.getToRole())) {
            throw new BusinessException("接收方角色非法");
        }
        if (fromRole.equals(message.getToRole())) {
            throw new BusinessException("仅支持学生与企业互发消息");
        }
        String content = message.getContent().trim();
        if (content.length() > 1000) {
            throw new BusinessException("消息内容不能超过1000字");
        }
        message.setId(null);
        message.setFromUserId(fromUserId);
        message.setFromRole(fromRole);
        message.setContent(content);
        message.setIsRead(0);
        this.save(message);
        return message;
    }

    @Override
    public List<Map<String, Object>> conversations() {
        Long userId = UserContext.getUserId();
        String role = UserContext.getRole();
        List<ChatMessage> list = this.list(new LambdaQueryWrapper<ChatMessage>()
                .and(w -> w.eq(ChatMessage::getFromUserId, userId).eq(ChatMessage::getFromRole, role)
                        .or()
                        .eq(ChatMessage::getToUserId, userId).eq(ChatMessage::getToRole, role))
                .orderByDesc(ChatMessage::getCreateTime));
        Map<String, Map<String, Object>> map = new HashMap<>();
        for (ChatMessage msg : list) {
            boolean sent = userId.equals(msg.getFromUserId()) && role.equals(msg.getFromRole());
            Long peerId = sent ? msg.getToUserId() : msg.getFromUserId();
            String peerRole = sent ? msg.getToRole() : msg.getFromRole();
            String key = peerRole + ":" + peerId;
            Map<String, Object> item = map.computeIfAbsent(key, k -> {
                Map<String, Object> v = new HashMap<>();
                v.put("peerId", peerId);
                v.put("peerRole", peerRole);
                v.put("peerName", peerName(peerRole, peerId));
                v.put("unread", 0L);
                return v;
            });
            if (!item.containsKey("lastMessage")) {
                item.put("lastMessage", msg);
            }
            if (!sent && (msg.getIsRead() == null || msg.getIsRead() == 0)) {
                item.put("unread", ((Long) item.get("unread")) + 1);
            }
        }
        List<Map<String, Object>> result = new ArrayList<>(map.values());
        result.sort(Comparator.comparing(o -> ((ChatMessage) o.get("lastMessage")).getCreateTime(), Comparator.reverseOrder()));
        return result;
    }

    @Override
    public List<ChatMessage> messages(String peerRole, Long peerId) {
        Long userId = UserContext.getUserId();
        String role = UserContext.getRole();
        return this.list(new LambdaQueryWrapper<ChatMessage>()
                .and(w -> w.eq(ChatMessage::getFromUserId, userId).eq(ChatMessage::getFromRole, role)
                        .eq(ChatMessage::getToUserId, peerId).eq(ChatMessage::getToRole, peerRole)
                        .or()
                        .eq(ChatMessage::getFromUserId, peerId).eq(ChatMessage::getFromRole, peerRole)
                        .eq(ChatMessage::getToUserId, userId).eq(ChatMessage::getToRole, role))
                .orderByAsc(ChatMessage::getCreateTime));
    }

    @Override
    public void read(String peerRole, Long peerId) {
        ChatMessage update = new ChatMessage();
        update.setIsRead(1);
        this.update(update, new LambdaQueryWrapper<ChatMessage>()
                .eq(ChatMessage::getFromUserId, peerId)
                .eq(ChatMessage::getFromRole, peerRole)
                .eq(ChatMessage::getToUserId, UserContext.getUserId())
                .eq(ChatMessage::getToRole, UserContext.getRole())
                .eq(ChatMessage::getIsRead, 0));
    }

    private String peerName(String role, Long id) {
        if ("STUDENT".equals(role)) {
            Student student = studentMapper.selectById(id);
            return student == null ? "学生" + id : student.getRealName();
        }
        Enterprise enterprise = enterpriseMapper.selectById(id);
        return enterprise == null ? "企业" + id : enterprise.getCompanyName();
    }
}
