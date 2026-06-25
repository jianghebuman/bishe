package com.campus.controller;

import com.campus.common.Result;
import com.campus.common.RequireRole;
import com.campus.entity.ChatMessage;
import com.campus.service.ChatMessageService;
import com.campus.websocket.ChatWebSocketHandler;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/chat")
@RequireRole({"STUDENT", "ENTERPRISE"})
public class ChatController {

    @Autowired
    private ChatMessageService chatMessageService;

    @Autowired
    private ChatWebSocketHandler chatWebSocketHandler;

    @GetMapping("/conversations")
    public Result<List<Map<String, Object>>> conversations() {
        return Result.success(chatMessageService.conversations());
    }

    @GetMapping("/messages")
    public Result<List<ChatMessage>> messages(@RequestParam String peerRole, @RequestParam Long peerId) {
        return Result.success(chatMessageService.messages(peerRole, peerId));
    }

    @PostMapping("/messages")
    public Result<ChatMessage> send(@RequestBody ChatMessage message) {
        ChatMessage saved = chatMessageService.send(message);
        chatWebSocketHandler.push(saved);
        return Result.success(saved);
    }

    @PostMapping("/messages/read")
    public Result<Void> read(@RequestParam String peerRole, @RequestParam Long peerId) {
        chatMessageService.read(peerRole, peerId);
        return Result.success("已读", null);
    }
}
