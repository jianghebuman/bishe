package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.entity.Student;
import com.campus.mapper.StudentMapper;
import com.campus.service.StudentService;
import org.springframework.stereotype.Service;

/**
 * 学生服务实现
 *
 * @author campus
 */
@Service
public class StudentServiceImpl extends ServiceImpl<StudentMapper, Student> implements StudentService {

    @Override
    public Student getByUsername(String username) {
        return this.getOne(new LambdaQueryWrapper<Student>().eq(Student::getUsername, username));
    }
}
