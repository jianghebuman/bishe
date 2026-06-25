package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.common.BusinessException;
import com.campus.common.PageResult;
import com.campus.common.UserContext;
import com.campus.entity.JobSeekerPost;
import com.campus.entity.Resume;
import com.campus.entity.Student;
import com.campus.mapper.JobSeekerPostMapper;
import com.campus.mapper.ResumeMapper;
import com.campus.mapper.StudentMapper;
import com.campus.service.JobSeekerPostService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class JobSeekerPostServiceImpl extends ServiceImpl<JobSeekerPostMapper, JobSeekerPost> implements JobSeekerPostService {

    @Autowired
    private ResumeMapper resumeMapper;

    @Autowired
    private StudentMapper studentMapper;

    @Override
    public PageResult<Map<String, Object>> publicPage(Integer pageNum, Integer pageSize, String keyword, String city) {
        Page<JobSeekerPost> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<JobSeekerPost> wrapper = new LambdaQueryWrapper<JobSeekerPost>()
                .eq(JobSeekerPost::getStatus, 1)
                .like(keyword != null && !keyword.trim().isEmpty(), JobSeekerPost::getTitle, keyword)
                .like(city != null && !city.trim().isEmpty(), JobSeekerPost::getExpectCity, city)
                .orderByDesc(JobSeekerPost::getUpdateTime);
        this.page(page, wrapper);
        return PageResult.of(page.getTotal(), enrich(page.getRecords(), false));
    }

    @Override
    public Map<String, Object> publicDetail(Long id) {
        JobSeekerPost post = this.getById(id);
        if (post == null || post.getStatus() == null || post.getStatus() != 1) {
            throw new BusinessException("求职信息不存在或已下架");
        }
        JobSeekerPost update = new JobSeekerPost();
        update.setId(id);
        update.setViewCount((post.getViewCount() == null ? 0 : post.getViewCount()) + 1);
        this.updateById(update);
        post.setViewCount(update.getViewCount());
        return enrich(java.util.Collections.singletonList(post), true).get(0);
    }

    @Override
    public JobSeekerPost myPost() {
        return this.getOne(new LambdaQueryWrapper<JobSeekerPost>()
                .eq(JobSeekerPost::getStudentId, UserContext.getUserId())
                .last("LIMIT 1"));
    }

    @Override
    public Long saveMine(JobSeekerPost post) {
        Long studentId = UserContext.getUserId();
        if (post.getTitle() == null || post.getTitle().trim().isEmpty()) {
            throw new BusinessException("求职标题不能为空");
        }
        if (post.getIntro() != null && post.getIntro().length() > 2000) {
            throw new BusinessException("自我介绍不能超过2000字");
        }
        if (post.getResumeId() != null) {
            Resume resume = resumeMapper.selectById(post.getResumeId());
            if (resume == null || !studentId.equals(resume.getStudentId())) {
                throw new BusinessException("只能绑定自己的简历");
            }
        }
        JobSeekerPost db = myPost();
        if (db == null) {
            post.setId(null);
            post.setStudentId(studentId);
            post.setStatus(post.getStatus() == null ? 1 : post.getStatus());
            post.setViewCount(0);
            this.save(post);
            return post.getId();
        }
        post.setId(db.getId());
        post.setStudentId(studentId);
        this.updateById(post);
        return db.getId();
    }

    @Override
    public void changeMineStatus(Integer status) {
        if (status == null || (status != 0 && status != 1)) {
            throw new BusinessException("状态非法");
        }
        JobSeekerPost db = myPost();
        if (db == null) {
            throw new BusinessException("请先发布求职信息");
        }
        JobSeekerPost update = new JobSeekerPost();
        update.setId(db.getId());
        update.setStatus(status);
        this.updateById(update);
    }

    @Override
    public PageResult<Map<String, Object>> adminPage(Integer pageNum, Integer pageSize, String title, Long studentId, Integer status) {
        Page<JobSeekerPost> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<JobSeekerPost> wrapper = new LambdaQueryWrapper<JobSeekerPost>()
                .like(title != null && !title.trim().isEmpty(), JobSeekerPost::getTitle, title)
                .eq(studentId != null, JobSeekerPost::getStudentId, studentId)
                .eq(status != null, JobSeekerPost::getStatus, status)
                .orderByDesc(JobSeekerPost::getUpdateTime);
        this.page(page, wrapper);
        return PageResult.of(page.getTotal(), enrich(page.getRecords(), false));
    }

    private List<Map<String, Object>> enrich(List<JobSeekerPost> posts, boolean includeResume) {
        if (posts == null || posts.isEmpty()) {
            return java.util.Collections.emptyList();
        }
        java.util.Set<Long> studentIds = posts.stream()
                .map(JobSeekerPost::getStudentId)
                .filter(java.util.Objects::nonNull)
                .collect(Collectors.toSet());
        java.util.Set<Long> resumeIds = posts.stream()
                .map(JobSeekerPost::getResumeId)
                .filter(java.util.Objects::nonNull)
                .collect(Collectors.toSet());
        Map<Long, Student> studentMap = studentIds.isEmpty() ? java.util.Collections.emptyMap()
                : studentMapper.selectBatchIds(studentIds).stream().collect(Collectors.toMap(Student::getId, s -> s));
        Map<Long, Resume> resumeMap = includeResume && !resumeIds.isEmpty()
                ? resumeMapper.selectBatchIds(resumeIds).stream().collect(Collectors.toMap(Resume::getId, r -> r))
                : java.util.Collections.emptyMap();
        return posts.stream().map(post -> {
            Map<String, Object> item = new HashMap<>();
            item.put("post", post);
            Student student = studentMap.get(post.getStudentId());
            if (student != null) {
                student.setPassword(null);
                student.setPhone(null);
                student.setEmail(null);
                student.setStudentNo(null);
                student.setLastLogin(null);
            }
            item.put("student", student);
            if (includeResume) {
                Resume resume = resumeMap.get(post.getResumeId());
                if (resume != null) {
                    resume.setPhone(null);
                    resume.setEmail(null);
                }
                item.put("resume", resume);
            }
            return item;
        }).collect(Collectors.toList());
    }
}
