package com.campus.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.common.PageResult;
import com.campus.common.RequireRole;
import com.campus.common.Result;
import com.campus.entity.OperationLog;
import com.campus.service.OperationLogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 管理员-系统日志
 *
 * @author campus
 */
@RestController
@RequestMapping("/admin/log")
@RequireRole("ADMIN")
public class LogController {

    @Autowired
    private OperationLogService operationLogService;

    @GetMapping
    public Result<PageResult<OperationLog>> page(@RequestParam(defaultValue = "1") Integer pageNum,
                                                 @RequestParam(defaultValue = "10") Integer pageSize,
                                                 @RequestParam(required = false) String logType) {
        Page<OperationLog> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<OperationLog> wrapper = new LambdaQueryWrapper<OperationLog>()
                .eq(logType != null && !logType.isEmpty(), OperationLog::getLogType, logType)
                .orderByDesc(OperationLog::getCreateTime);
        operationLogService.page(page, wrapper);
        return Result.success(PageResult.of(page.getTotal(), page.getRecords()));
    }
}
