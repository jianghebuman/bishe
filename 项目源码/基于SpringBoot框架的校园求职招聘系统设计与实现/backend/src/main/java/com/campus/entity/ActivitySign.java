package com.campus.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.util.Date;

/**
 * 活动报名实体
 */
@Data
@TableName("activity_sign")
public class ActivitySign implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 活动类型
     */
    private Integer activityType;

    /**
     * 活动ID
     */
    private Long activityId;

    /**
     * 学生ID
     */
    private Long studentId;

    /**
     * 报名状态
     */
    private Integer signStatus;

    @TableField(fill = FieldFill.INSERT)
    private Date createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Date updateTime;

    @TableLogic
    private Integer deleted;
}
