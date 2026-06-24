package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.entity.AdminUser;
import com.campus.mapper.AdminUserMapper;
import com.campus.service.AdminUserService;
import org.springframework.stereotype.Service;

/**
 * 管理员服务实现
 *
 * @author campus
 */
@Service
public class AdminUserServiceImpl extends ServiceImpl<AdminUserMapper, AdminUser> implements AdminUserService {

    @Override
    public AdminUser getByUsername(String username) {
        return this.getOne(new LambdaQueryWrapper<AdminUser>().eq(AdminUser::getUsername, username));
    }
}
