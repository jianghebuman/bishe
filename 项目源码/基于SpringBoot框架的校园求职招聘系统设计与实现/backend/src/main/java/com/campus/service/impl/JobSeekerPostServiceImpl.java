package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.common.BusinessException;
import com.campus.common.PageResult;
import com.campus.common.UserContext;
import com.campus.entity.JobSeekerPost;
import com.campus.entity.Resume;
import com.campus.entity.ResumeEducation;
import com.campus.entity.ResumeExperience;
import com.campus.entity.ResumeProject;
import com.campus.entity.Student;
import com.campus.mapper.JobSeekerPostMapper;
import com.campus.mapper.ResumeEducationMapper;
import com.campus.mapper.ResumeExperienceMapper;
import com.campus.mapper.ResumeMapper;
import com.campus.mapper.ResumeProjectMapper;
import com.campus.mapper.StudentMapper;
import com.campus.service.JobSeekerPostService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Service
public class JobSeekerPostServiceImpl extends ServiceImpl<JobSeekerPostMapper, JobSeekerPost> implements JobSeekerPostService {

    private static final Pattern SALARY_PATTERN = Pattern.compile("(\\d+(?:\\.\\d+)?)\\s*(?:[kK]|千)");

    @Autowired
    private ResumeMapper resumeMapper;

    @Autowired
    private ResumeEducationMapper resumeEducationMapper;

    @Autowired
    private ResumeProjectMapper resumeProjectMapper;

    @Autowired
    private ResumeExperienceMapper resumeExperienceMapper;

    @Autowired
    private StudentMapper studentMapper;

    @Override
    public PageResult<Map<String, Object>> publicPage(Integer pageNum, Integer pageSize, String keyword, String city,
                                                      String expectPost, String college, Integer salaryMin) {
        String keywordText = normalize(keyword);
        String cityText = normalize(city);
        String expectPostText = normalize(expectPost);
        String collegeText = normalize(college);
        List<Long> studentIds = null;
        if (collegeText != null) {
            studentIds = studentMapper.selectList(new LambdaQueryWrapper<Student>()
                            .like(Student::getCollege, collegeText))
                    .stream()
                    .map(Student::getId)
                    .collect(Collectors.toList());
            if (studentIds.isEmpty()) {
                return PageResult.of(0L, Collections.emptyList());
            }
        }

        Page<JobSeekerPost> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<JobSeekerPost> wrapper = new LambdaQueryWrapper<JobSeekerPost>()
                .eq(JobSeekerPost::getStatus, 1)
                .and(keywordText != null, w -> w
                        .like(JobSeekerPost::getTitle, keywordText)
                        .or().like(JobSeekerPost::getExpectPost, keywordText)
                        .or().like(JobSeekerPost::getIntro, keywordText))
                .like(cityText != null, JobSeekerPost::getExpectCity, cityText)
                .like(expectPostText != null, JobSeekerPost::getExpectPost, expectPostText)
                .in(studentIds != null, JobSeekerPost::getStudentId, studentIds)
                .orderByDesc(JobSeekerPost::getUpdateTime);
        if (salaryMin != null) {
            List<JobSeekerPost> filtered = this.list(wrapper).stream()
                    .filter(post -> matchSalaryMin(post.getExpectSalary(), salaryMin))
                    .collect(Collectors.toList());
            int fromIndex = Math.min(Math.max(pageNum - 1, 0) * pageSize, filtered.size());
            int toIndex = Math.min(fromIndex + pageSize, filtered.size());
            return PageResult.of((long) filtered.size(), enrich(filtered.subList(fromIndex, toIndex), false));
        }
        this.page(page, wrapper);
        return PageResult.of(page.getTotal(), enrich(page.getRecords(), false));
    }

    private String normalize(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private boolean matchSalaryMin(String salary, Integer salaryMin) {
        if (salary == null || salaryMin == null) {
            return salaryMin == null;
        }
        Matcher matcher = SALARY_PATTERN.matcher(salary);
        if (!matcher.find()) {
            return false;
        }
        return Double.parseDouble(matcher.group(1)) >= salaryMin;
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
    public Student studentInfoForEnterprise(Long id) {
        JobSeekerPost post = this.getById(id);
        if (post == null || post.getStatus() == null || post.getStatus() != 1) {
            throw new BusinessException("求职信息不存在或已下架");
        }
        Student student = studentMapper.selectById(post.getStudentId());
        if (student != null) {
            student.setPassword(null);
            student.setLastLogin(null);
        }
        return student;
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
        Map<Long, List<ResumeEducation>> educationMap = java.util.Collections.emptyMap();
        Map<Long, List<ResumeProject>> projectMap = java.util.Collections.emptyMap();
        Map<Long, List<ResumeExperience>> experienceMap = java.util.Collections.emptyMap();
        if (includeResume && !resumeIds.isEmpty()) {
            educationMap = resumeEducationMapper.selectList(new LambdaQueryWrapper<ResumeEducation>()
                            .in(ResumeEducation::getResumeId, resumeIds)
                            .orderByAsc(ResumeEducation::getStartDate))
                    .stream().collect(Collectors.groupingBy(ResumeEducation::getResumeId));
            projectMap = resumeProjectMapper.selectList(new LambdaQueryWrapper<ResumeProject>()
                            .in(ResumeProject::getResumeId, resumeIds)
                            .orderByAsc(ResumeProject::getStartDate))
                    .stream().collect(Collectors.groupingBy(ResumeProject::getResumeId));
            experienceMap = resumeExperienceMapper.selectList(new LambdaQueryWrapper<ResumeExperience>()
                            .in(ResumeExperience::getResumeId, resumeIds)
                            .orderByAsc(ResumeExperience::getStartDate))
                    .stream().collect(Collectors.groupingBy(ResumeExperience::getResumeId));
        }
        final Map<Long, List<ResumeEducation>> finalEducationMap = educationMap;
        final Map<Long, List<ResumeProject>> finalProjectMap = projectMap;
        final Map<Long, List<ResumeExperience>> finalExperienceMap = experienceMap;
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
                item.put("educations", finalEducationMap.getOrDefault(post.getResumeId(), java.util.Collections.emptyList()));
                item.put("projects", finalProjectMap.getOrDefault(post.getResumeId(), java.util.Collections.emptyList()));
                item.put("experiences", finalExperienceMap.getOrDefault(post.getResumeId(), java.util.Collections.emptyList()));
            }
            return item;
        }).collect(Collectors.toList());
    }
}
