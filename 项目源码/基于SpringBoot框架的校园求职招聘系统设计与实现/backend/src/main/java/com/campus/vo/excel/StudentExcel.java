package com.campus.vo.excel;

import com.alibaba.excel.annotation.ExcelProperty;
import lombok.Data;

/**
 * 学生导出模型
 *
 * @author campus
 */
@Data
public class StudentExcel {

    @ExcelProperty("ID")
    private Long id;

    @ExcelProperty("账号")
    private String username;

    @ExcelProperty("姓名")
    private String realName;

    @ExcelProperty("学校")
    private String school;

    @ExcelProperty("学号")
    private String studentNo;

    @ExcelProperty("学院")
    private String college;

    @ExcelProperty("专业")
    private String major;

    @ExcelProperty("年级")
    private String grade;

    @ExcelProperty("手机号")
    private String phone;

    @ExcelProperty("邮箱")
    private String email;
}
