package com.campus.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.common.PageResult;
import com.campus.entity.JobSeekerPost;
import com.campus.entity.Student;

import java.util.Map;

public interface JobSeekerPostService extends IService<JobSeekerPost> {

    PageResult<Map<String, Object>> publicPage(Integer pageNum, Integer pageSize, String keyword, String city,
                                               String expectPost, String college, Integer salaryMin);

    Map<String, Object> publicDetail(Long id);

    Student studentInfoForEnterprise(Long id);

    JobSeekerPost myPost();

    Long saveMine(JobSeekerPost post);

    void changeMineStatus(Integer status);

    PageResult<Map<String, Object>> adminPage(Integer pageNum, Integer pageSize, String title, Long studentId, Integer status);
}
