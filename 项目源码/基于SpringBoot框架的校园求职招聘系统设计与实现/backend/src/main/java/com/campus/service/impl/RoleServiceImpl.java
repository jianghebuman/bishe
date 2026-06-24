package com.campus.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.entity.Role;
import com.campus.mapper.RoleMapper;
import com.campus.service.RoleService;
import org.springframework.stereotype.Service;

/**
 * 角色服务实现
 *
 * @author campus
 */
@Service
public class RoleServiceImpl extends ServiceImpl<RoleMapper, Role> implements RoleService {
}
