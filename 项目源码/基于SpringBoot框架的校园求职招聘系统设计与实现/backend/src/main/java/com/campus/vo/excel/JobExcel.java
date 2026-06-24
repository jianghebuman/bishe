package com.campus.vo.excel;

import com.alibaba.excel.annotation.ExcelProperty;
import lombok.Data;

/**
 * 岗位导出模型
 *
 * @author campus
 */
@Data
public class JobExcel {

    @ExcelProperty("ID")
    private Long id;

    @ExcelProperty("岗位名称")
    private String title;

    @ExcelProperty("企业")
    private String companyName;

    @ExcelProperty("城市")
    private String city;

    @ExcelProperty("最低薪资(K)")
    private Integer salaryMin;

    @ExcelProperty("最高薪资(K)")
    private Integer salaryMax;

    @ExcelProperty("学历要求")
    private String education;

    @ExcelProperty("招聘人数")
    private Integer recruitNum;

    @ExcelProperty("浏览量")
    private Integer viewCount;

    @ExcelProperty("投递量")
    private Integer applyCount;
}
