package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.entity.Enterprise;
import com.campus.mapper.EnterpriseMapper;
import com.campus.service.EnterpriseService;
import org.springframework.stereotype.Service;

/**
 * 企业服务实现
 *
 * @author campus
 */
@Service
public class EnterpriseServiceImpl extends ServiceImpl<EnterpriseMapper, Enterprise> implements EnterpriseService {

    @Override
    public Enterprise getByUsername(String username) {
        return this.getOne(new LambdaQueryWrapper<Enterprise>().eq(Enterprise::getUsername, username));
    }
}
