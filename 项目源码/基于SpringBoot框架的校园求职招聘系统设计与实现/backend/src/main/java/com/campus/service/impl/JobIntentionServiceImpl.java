package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.entity.JobIntention;
import com.campus.mapper.JobIntentionMapper;
import com.campus.service.JobIntentionService;
import org.springframework.stereotype.Service;

/**
 * 求职意向服务实现
 *
 * @author campus
 */
@Service
public class JobIntentionServiceImpl extends ServiceImpl<JobIntentionMapper, JobIntention>
        implements JobIntentionService {

    @Override
    public JobIntention getByStudent(Long studentId) {
        return this.getOne(new LambdaQueryWrapper<JobIntention>()
                .eq(JobIntention::getStudentId, studentId)
                .last("limit 1"));
    }

    @Override
    public void saveOrUpdateByStudent(Long studentId, JobIntention intention) {
        // 一个学生只保留一条求职意向：存在则更新，否则新增
        JobIntention exist = getByStudent(studentId);
        intention.setStudentId(studentId);
        if (exist != null) {
            intention.setId(exist.getId());
            this.updateById(intention);
        } else {
            intention.setId(null);
            this.save(intention);
        }
    }
}
