package com.campus.entity;

import com.baomidou.mybatisplus.annotation.*;
import java.io.Serializable;
import java.util.Date;
import lombok.Data;

@Data
@TableName("interview_notice")
public class InterviewNotice implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long applyId;

    private Long studentId;

    private Long enterpriseId;

    private Long jobId;

    private Date interviewTime;

    private Integer interviewType;

    private String location;

    private String contact;

    private String remark;

    private Integer studentStatus;

    @TableField(fill = FieldFill.INSERT)
    private Date createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Date updateTime;

    @TableLogic
    private Integer deleted;
}
