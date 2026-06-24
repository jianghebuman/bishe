package com.campus.vo.excel;

import com.alibaba.excel.annotation.ExcelProperty;
import lombok.Data;

import java.util.Date;

/**
 * 投递记录导出模型
 *
 * @author campus
 */
@Data
public class ApplyExcel {

    @ExcelProperty("ID")
    private Long id;

    @ExcelProperty("学生")
    private String studentName;

    @ExcelProperty("岗位")
    private String jobTitle;

    @ExcelProperty("企业")
    private String companyName;

    @ExcelProperty("状态")
    private String statusText;

    @ExcelProperty("投递时间")
    private Date createTime;
}
