package com.campus.dto;

import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;

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
    @Size(min = 6, message = "密码至少6位")
    private String password;

    @NotBlank(message = "姓名不能为空")
    private String realName;

    @NotBlank(message = "学校不能为空")
    private String school;

    @NotBlank(message = "学号不能为空")
    private String studentNo;

    private String college;

    private String major;

    private String grade;

    @NotBlank(message = "手机号不能为空")
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "请输入有效的手机号")
    private String phone;

    private String email;
}
