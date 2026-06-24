package com.campus.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.common.LoginUser;
import com.campus.common.UserContext;
import com.campus.entity.OperationLog;
import com.campus.mapper.OperationLogMapper;
import com.campus.service.OperationLogService;
import org.springframework.stereotype.Service;

/**
 * 操作日志服务实现
 *
 * @author campus
 */
@Service
public class OperationLogServiceImpl extends ServiceImpl<OperationLogMapper, OperationLog> implements OperationLogService {

    @Override
    public void record(String logType, String module, String operation, Integer status) {
        OperationLog log = new OperationLog();
        log.setLogType(logType);
        log.setModule(module);
        log.setOperation(operation);
        log.setStatus(status);
        LoginUser user = UserContext.get();
        if (user != null) {
            log.setUserId(user.getUserId());
            log.setUserType(user.getRole());
            log.setUserName(user.getUsername());
        }
        this.save(log);
    }
}
