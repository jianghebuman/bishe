package com.campus.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.util.Date;

/**
 * 职位
 *
 * @author campus
 */
@Data
@TableName("job_post")
public class JobPost implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long enterpriseId;

    private Long categoryId;

    private String title;

    /** 1全职2实习 */
    private Integer jobType;

    private Integer recruitNum;

    private String city;

    private Integer salaryMin;

    private Integer salaryMax;

    private String education;

    private String majorRequire;

    private String experience;

    private String duty;

    private String requirement;

    private String welfare;

    /** 审核状态：0待审核1通过2驳回 */
    private Integer auditStatus;

    private String auditRemark;

    /** 状态：1招聘中0已下架 */
    private Integer status;

    private Integer viewCount;

    private Integer applyCount;

    private Date publishTime;

    @TableField(fill = FieldFill.INSERT)
    private Date createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Date updateTime;

    @TableLogic
    private Integer deleted;
}
