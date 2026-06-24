package com.campus.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.entity.Student;

/**
 * 学生服务
 *
 * @author campus
 */
public interface StudentService extends IService<Student> {

    /** 根据用户名查询 */
    Student getByUsername(String username);
}
