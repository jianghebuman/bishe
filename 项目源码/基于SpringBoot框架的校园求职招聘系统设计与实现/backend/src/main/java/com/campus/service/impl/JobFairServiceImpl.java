package com.campus.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.entity.JobFair;
import com.campus.mapper.JobFairMapper;
import com.campus.service.JobFairService;
import org.springframework.stereotype.Service;

/**
 * 招聘会服务实现
 *
 * @author campus
 */
@Service
public class JobFairServiceImpl extends ServiceImpl<JobFairMapper, JobFair> implements JobFairService {
}
