package com.campus.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.entity.ChatMessage;

import java.util.List;
import java.util.Map;

public interface ChatMessageService extends IService<ChatMessage> {

    ChatMessage send(ChatMessage message);

    List<Map<String, Object>> conversations();

    List<ChatMessage> messages(String peerRole, Long peerId);

    void read(String peerRole, Long peerId);
}
