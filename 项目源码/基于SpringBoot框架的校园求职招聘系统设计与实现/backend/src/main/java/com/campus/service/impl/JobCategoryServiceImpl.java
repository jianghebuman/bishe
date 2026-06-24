package com.campus.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.entity.JobCategory;
import com.campus.mapper.JobCategoryMapper;
import com.campus.service.JobCategoryService;
import org.springframework.stereotype.Service;

/**
 * 岗位类别服务实现
 *
 * @author campus
 */
@Service
public class JobCategoryServiceImpl extends ServiceImpl<JobCategoryMapper, JobCategory> implements JobCategoryService {
}
