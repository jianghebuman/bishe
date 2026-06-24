package com.campus.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.entity.Enterprise;

/**
 * 企业服务
 *
 * @author campus
 */
public interface EnterpriseService extends IService<Enterprise> {

    /** 根据用户名查询 */
    Enterprise getByUsername(String username);
}
