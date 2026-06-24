package com.campus.vo.excel;

import com.alibaba.excel.annotation.ExcelProperty;
import lombok.Data;

/**
 * 企业导出模型
 *
 * @author campus
 */
@Data
public class EnterpriseExcel {

    @ExcelProperty("ID")
    private Long id;

    @ExcelProperty("账号")
    private String username;

    @ExcelProperty("企业名称")
    private String companyName;

    @ExcelProperty("行业")
    private String industry;

    @ExcelProperty("规模")
    private String scale;

    @ExcelProperty("城市")
    private String city;

    @ExcelProperty("联系人")
    private String contactName;

    @ExcelProperty("联系电话")
    private String contactPhone;

    @ExcelProperty("认证状态")
    private String auditStatusText;
}
