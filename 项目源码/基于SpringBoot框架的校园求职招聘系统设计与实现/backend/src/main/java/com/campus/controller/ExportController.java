package com.campus.controller;

import com.campus.common.RequireRole;
import com.campus.service.ExportService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletResponse;

/**
 * 管理员-数据导出（Excel）
 *
 * @author campus
 */
@RestController
@RequestMapping("/admin/export")
@RequireRole("ADMIN")
public class ExportController {

    @Autowired
    private ExportService exportService;

    @GetMapping("/student")
    public void exportStudents(HttpServletResponse response) {
        exportService.exportStudents(response);
    }

    @GetMapping("/enterprise")
    public void exportEnterprises(HttpServletResponse response) {
        exportService.exportEnterprises(response);
    }

    @GetMapping("/job")
    public void exportJobs(HttpServletResponse response) {
        exportService.exportJobs(response);
    }

    @GetMapping("/apply")
    public void exportApplies(HttpServletResponse response) {
        exportService.exportApplies(response);
    }
}
