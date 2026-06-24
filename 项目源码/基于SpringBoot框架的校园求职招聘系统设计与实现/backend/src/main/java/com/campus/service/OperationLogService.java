package com.campus.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.entity.OperationLog;

/**
 * 操作日志服务
 *
 * @author campus
 */
public interface OperationLogService extends IService<OperationLog> {

    /** 异步记录日志 */
    void record(String logType, String module, String operation, Integer status);
}
