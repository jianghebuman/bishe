package com.campus.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.entity.JobIntention;

/**
 * 求职意向服务
 *
 * @author campus
 */
public interface JobIntentionService extends IService<JobIntention> {

    /** 获取当前学生的求职意向（一个学生一条，可能为 null） */
    JobIntention getByStudent(Long studentId);

    /** 保存或更新当前学生的求职意向（存在则更新，否则新增） */
    void saveOrUpdateByStudent(Long studentId, JobIntention intention);
}
