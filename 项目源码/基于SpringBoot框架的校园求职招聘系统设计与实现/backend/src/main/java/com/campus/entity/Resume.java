package com.campus.entity;

import com.baomidou.mybatisplus.annotation.*;

import java.io.Serializable;
import java.util.Date;

import lombok.Data;

@Data
@TableName("resume")
public class Resume implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long studentId;

    private String name;

    private Integer gender;

    private String birth;

    private String phone;

    private String email;

    private String college;

    private String major;

    private String education;

    private String skillCert;

    private String award;

    private String selfEval;

    private Integer completeRate;

    private Integer isPublic;

    @TableField(fill = FieldFill.INSERT)
    private Date createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Date updateTime;

    @TableLogic
    private Integer deleted;
}
