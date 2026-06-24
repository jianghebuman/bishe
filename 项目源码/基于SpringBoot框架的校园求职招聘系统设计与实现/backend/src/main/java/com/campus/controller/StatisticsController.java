package com.campus.controller;

import com.campus.common.RequireRole;
import com.campus.common.Result;
import com.campus.service.StatisticsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * 管理员-数据统计
 *
 * @author campus
 */
@RestController
@RequestMapping("/admin/statistics")
@RequireRole("ADMIN")
public class StatisticsController {

    @Autowired
    private StatisticsService statisticsService;

    @GetMapping
    public Result<Map<String, Object>> overview() {
        return Result.success(statisticsService.overview());
    }
}
