package com.campus.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.entity.AdminUser;

/**
 * 管理员服务
 *
 * @author campus
 */
public interface AdminUserService extends IService<AdminUser> {

    /** 根据用户名查询 */
    AdminUser getByUsername(String username);
}
