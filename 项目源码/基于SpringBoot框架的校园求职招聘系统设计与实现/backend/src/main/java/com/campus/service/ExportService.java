package com.campus.service;

import javax.servlet.http.HttpServletResponse;

/**
 * 数据导出服务（Excel）
 *
 * @author campus
 */
public interface ExportService {

    void exportStudents(HttpServletResponse response);

    void exportEnterprises(HttpServletResponse response);

    void exportJobs(HttpServletResponse response);

    void exportApplies(HttpServletResponse response);
}
