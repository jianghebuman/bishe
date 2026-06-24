package com.campus.entity;

import com.baomidou.mybatisplus.annotation.*;
import java.io.Serializable;
import java.util.Date;
import lombok.Data;

@Data
@TableName("interview_feedback")
public class InterviewFeedback implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long noticeId;

    private Long applyId;

    private Long enterpriseId;

    private Integer score;

    private String content;

    private Integer isPass;

    private String interviewer;

    @TableField(fill = FieldFill.INSERT)
    private Date createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Date updateTime;

    @TableLogic
    private Integer deleted;
}
