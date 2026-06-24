package com.campus.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 登录请求
 *
 * @author campus
 */
@Data
public class LoginDTO {

    @NotBlank(message = "账号不能为空")
    private String username;

    @NotBlank(message = "密码不能为空")
    private String password;

    /** 登录角色：ADMIN/ENTERPRISE/STUDENT */
    @NotBlank(message = "请选择登录身份")
    private String role;
}
