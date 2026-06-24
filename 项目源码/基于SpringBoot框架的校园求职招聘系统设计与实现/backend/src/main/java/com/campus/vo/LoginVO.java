package com.campus.vo;

import lombok.Data;

/**
 * 登录成功返回
 *
 * @author campus
 */
@Data
public class LoginVO {

    /** 登录令牌 */
    private String token;

    /** 用户ID */
    private Long userId;

    /** 登录账号 */
    private String username;

    /** 显示名称 */
    private String name;

    /** 角色：ADMIN/ENTERPRISE/STUDENT */
    private String role;

    /** 头像/Logo */
    private String avatar;

    /** 企业认证状态（仅企业）：0未认证1待审核2已通过3已驳回 */
    private Integer auditStatus;
}
