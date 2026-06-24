package com.campus.service;

import java.util.Map;

/**
 * 数据统计服务（管理员看板）
 *
 * @author campus
 */
public interface StatisticsService {

    /** 综合统计数据 */
    Map<String, Object> overview();
}
