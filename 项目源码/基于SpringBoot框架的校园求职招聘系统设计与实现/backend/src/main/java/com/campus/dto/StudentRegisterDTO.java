package com.campus.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;

/**
 * 学生注册请求
 *
 * @author campus
 */
@Data
public class StudentRegisterDTO {

    @NotBlank(message = "账号不能为空")
    private String username;

    @NotBlank(message = "密码不能为空")
    private String password;

    @NotBlank(message = "姓名不能为空")
    private String realName;

    private String studentNo;

    private String college;

    private String major;

    private String grade;

    private String phone;

    private String email;
}
