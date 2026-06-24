package com.campus.vo;

import lombok.Data;

import java.io.Serializable;
import java.util.Date;

/**
 * 岗位审核列表 VO（带企业名称、类别名称）
 *
 * @author campus
 */
@Data
public class JobAuditVO implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;

    private Long enterpriseId;

    /** 企业名称 */
    private String companyName;

    private Long categoryId;

    /** 类别名称 */
    private String categoryName;

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

    private Date createTime;
}
