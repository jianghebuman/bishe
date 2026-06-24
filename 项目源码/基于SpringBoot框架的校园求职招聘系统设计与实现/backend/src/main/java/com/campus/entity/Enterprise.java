package com.campus.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.util.Date;

/**
 * 企业
 *
 * @author campus
 */
@Data
@TableName("enterprise")
public class Enterprise implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    private String username;

    private String password;

    private String companyName;

    private String creditCode;

    private String industry;

    private String scale;

    private String nature;

    private String address;

    private String city;

    private String logo;

    private String intro;

    private String welfare;

    private String contactName;

    private String contactPhone;

    private String email;

    private String website;

    /** 认证状态：0未认证1待审核2已通过3已驳回 */
    private Integer auditStatus;

    private Integer status;

    private Date lastLogin;

    @TableField(fill = FieldFill.INSERT)
    private Date createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Date updateTime;

    @TableLogic
    private Integer deleted;
}
