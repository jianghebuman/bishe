package com.campus.entity;

import com.baomidou.mybatisplus.annotation.*;
import java.io.Serializable;
import java.util.Date;
import lombok.Data;

@Data
@TableName("offer_record")
public class OfferRecord implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long applyId;

    private Long studentId;

    private Long enterpriseId;

    private Long jobId;

    private String position;

    private String salary;

    private String workCity;

    private String reportTime;

    private String content;

    private Integer offerStatus;

    @TableField(fill = FieldFill.INSERT)
    private Date createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Date updateTime;

    @TableLogic
    private Integer deleted;
}
