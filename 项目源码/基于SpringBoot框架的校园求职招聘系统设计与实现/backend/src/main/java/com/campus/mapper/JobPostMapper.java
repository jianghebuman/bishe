package com.campus.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.campus.entity.JobPost;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface JobPostMapper extends BaseMapper<JobPost> {
}
