package com.campus.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.util.Date;

/**
 * 宣讲会实体
 */
@Data
@TableName("campus_talk")
public class CampusTalk implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 宣讲会标题
     */
    private String title;

    /**
     * 企业ID
     */
    private Long enterpriseId;

    /**
     * 企业名称
     */
    private String companyName;

    /**
     * 宣讲时间
     */
    private Date talkTime;

    /**
     * 宣讲地点
     */
    private String location;

    /**
     * 宣讲内容
     */
    private String content;

    /**
     * 封面图
     */
    private String cover;

    /**
     * 报名人数
     */
    private Integer signCount;

    /**
     * 状态
     */
    private Integer status;

    @TableField(fill = FieldFill.INSERT)
    private Date createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Date updateTime;

    @TableLogic
    private Integer deleted;
}
