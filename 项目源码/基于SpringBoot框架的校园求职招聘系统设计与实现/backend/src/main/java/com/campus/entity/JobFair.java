package com.campus.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.util.Date;

/**
 * 招聘会实体
 */
@Data
@TableName("job_fair")
public class JobFair implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 招聘会标题
     */
    private String title;

    /**
     * 举办时间
     */
    private Date fairTime;

    /**
     * 举办地点
     */
    private String location;

    /**
     * 主办方
     */
    private String host;

    /**
     * 招聘会内容
     */
    private String content;

    /**
     * 封面图
     */
    private String cover;

    /**
     * 参会企业数
     */
    private Integer companyCount;

    /**
     * 招聘岗位数
     */
    private Integer jobCount;

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
