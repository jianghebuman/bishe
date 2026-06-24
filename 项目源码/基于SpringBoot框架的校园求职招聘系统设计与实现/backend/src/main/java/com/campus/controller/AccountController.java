package com.campus.controller;

import com.campus.common.Result;
import com.campus.common.UserContext;
import com.campus.dto.ChangePasswordDTO;
import com.campus.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.HashMap;
import java.util.Map;

/**
 * 当前登录账户通用接口：改密码、获取当前身份
 *
 * @author campus
 */
@RestController
@RequestMapping("/account")
public class AccountController {

    @Autowired
    private AuthService authService;

    /** 修改密码（三类角色通用） */
    @PostMapping("/password")
    public Result<Void> changePassword(@Valid @RequestBody ChangePasswordDTO dto) {
        authService.changePassword(dto);
        return Result.success("密码修改成功", null);
    }

    /** 获取当前登录用户的身份信息 */
    @GetMapping("/info")
    public Result<Map<String, Object>> info() {
        Map<String, Object> map = new HashMap<>(4);
        map.put("userId", UserContext.getUserId());
        map.put("username", UserContext.getUsername());
        map.put("role", UserContext.getRole());
        return Result.success(map);
    }
}
