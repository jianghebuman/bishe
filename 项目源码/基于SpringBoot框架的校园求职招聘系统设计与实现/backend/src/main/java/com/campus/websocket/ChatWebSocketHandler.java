package com.campus.websocket;

import com.campus.common.LoginUser;
import com.campus.common.UserContext;
import com.campus.entity.ChatMessage;
import com.campus.service.ChatMessageService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class ChatWebSocketHandler extends TextWebSocketHandler {

    private final Map<String, WebSocketSession> sessions = new ConcurrentHashMap<>();

    @Autowired
    private ChatMessageService chatMessageService;

    @Autowired
    private ObjectMapper objectMapper;

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        LoginUser user = (LoginUser) session.getAttributes().get("user");
        if (user != null) {
            sessions.put(key(user.getRole(), user.getUserId()), session);
        }
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage textMessage) throws Exception {
        LoginUser user = (LoginUser) session.getAttributes().get("user");
        if (user == null) {
            session.close(CloseStatus.NOT_ACCEPTABLE);
            return;
        }
        ChatMessage message = objectMapper.readValue(textMessage.getPayload(), ChatMessage.class);
        UserContext.set(user);
        try {
            ChatMessage saved = chatMessageService.send(message);
            push(saved);
            WebSocketSession current = sessions.get(key(saved.getFromRole(), saved.getFromUserId()));
            if (current != null && current.isOpen()) {
                current.sendMessage(new TextMessage(objectMapper.writeValueAsString(saved)));
            }
        } finally {
            UserContext.clear();
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        LoginUser user = (LoginUser) session.getAttributes().get("user");
        if (user != null) {
            sessions.remove(key(user.getRole(), user.getUserId()), session);
        }
    }

    public void push(ChatMessage message) {
        WebSocketSession session = sessions.get(key(message.getToRole(), message.getToUserId()));
        if (session != null && session.isOpen()) {
            try {
                session.sendMessage(new TextMessage(objectMapper.writeValueAsString(message)));
            } catch (Exception ignored) {
            }
        }
    }

    private String key(String role, Long userId) {
        return role + ":" + userId;
    }
}
