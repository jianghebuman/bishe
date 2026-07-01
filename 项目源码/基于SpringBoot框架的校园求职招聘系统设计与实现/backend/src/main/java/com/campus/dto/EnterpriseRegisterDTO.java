package com.campus.dto;

import lombok.Data;

import javax.validation.constraints.AssertTrue;
import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;

/**
 * 企业注册请求
 *
 * @author campus
 */
@Data
public class EnterpriseRegisterDTO {

    @NotBlank(message = "账号不能为空")
    private String username;

    @NotBlank(message = "密码不能为空")
    @Size(min = 6, message = "密码至少6位")
    private String password;

    @NotBlank(message = "企业名称不能为空")
    private String companyName;

    @NotBlank(message = "统一社会信用代码不能为空")
    @Pattern(regexp = "^[0-9A-Z]{18}$", message = "请输入18位统一社会信用代码")
    private String creditCode;

    @NotBlank(message = "所属行业不能为空")
    private String industry;

    private String scale;

    @NotBlank(message = "所在城市不能为空")
    private String city;

    @NotBlank(message = "联系人不能为空")
    private String contactName;

    @NotBlank(message = "联系电话不能为空")
    @Pattern(regexp = "^1[3-9]\\d{9}$|^0\\d{2,3}-?\\d{7,8}$", message = "请输入有效的手机号或固定电话")
    private String contactPhone;

    @Email(message = "请输入有效的企业邮箱")
    private String email;

    private String website;

    @NotNull(message = "请确认企业信息真实有效")
    @AssertTrue(message = "请确认企业信息真实有效")
    private Boolean agreeTerms;
}
