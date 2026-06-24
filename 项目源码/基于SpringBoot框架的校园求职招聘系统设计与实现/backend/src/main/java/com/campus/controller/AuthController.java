package com.campus.controller;

import com.campus.common.Result;
import com.campus.dto.*;
import com.campus.service.AuthService;
import com.campus.vo.LoginVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;

/**
 * 认证控制器：登录、注册、退出、改密码
 *
 * @author campus
 */
@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private AuthService authService;

    /** 统一登录 */
    @PostMapping("/login")
    public Result<LoginVO> login(@Valid @RequestBody LoginDTO dto) {
        return Result.success("登录成功", authService.login(dto));
    }

    /** 学生注册 */
    @PostMapping("/register/student")
    public Result<Void> studentRegister(@Valid @RequestBody StudentRegisterDTO dto) {
        authService.studentRegister(dto);
        return Result.success("注册成功", null);
    }

    /** 企业注册 */
    @PostMapping("/register/enterprise")
    public Result<Void> enterpriseRegister(@Valid @RequestBody EnterpriseRegisterDTO dto) {
        authService.enterpriseRegister(dto);
        return Result.success("注册成功，请完善企业认证信息", null);
    }

    /** 退出登录（前端清除 token 即可，这里仅作占位） */
    @PostMapping("/logout")
    public Result<Void> logout() {
        return Result.success("已退出登录", null);
    }
}
