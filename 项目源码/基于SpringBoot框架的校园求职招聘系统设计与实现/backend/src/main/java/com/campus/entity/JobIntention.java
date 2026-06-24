package com.campus.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.util.Date;

/**
 * 求职意向
 *
 * @author campus
 */
@Data
@TableName("job_intention")
public class JobIntention implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long studentId;

    private String expectPost;

    private String expectCity;

    private String expectSalary;

    /** 1全职2实习 */
    private Integer jobType;

    private String arrivalTime;

    @TableField(fill = FieldFill.INSERT)
    private Date createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Date updateTime;

    @TableLogic
    private Integer deleted;
}
