package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.campus.entity.*;
import com.campus.mapper.*;
import com.campus.service.StatisticsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

/**
 * 数据统计服务实现（管理员看板）
 *
 * @author campus
 */
@Service
public class StatisticsServiceImpl implements StatisticsService {

    @Autowired
    private StudentMapper studentMapper;
    @Autowired
    private EnterpriseMapper enterpriseMapper;
    @Autowired
    private JobPostMapper jobPostMapper;
    @Autowired
    private JobApplyMapper jobApplyMapper;
    @Autowired
    private JobCategoryMapper jobCategoryMapper;
    @Autowired
    private InterviewFeedbackMapper interviewFeedbackMapper;
    @Autowired
    private OfferRecordMapper offerRecordMapper;

    @Override
    public Map<String, Object> overview() {
        Map<String, Object> result = new LinkedHashMap<>();

        // 1. 总览计数
        long studentCount = studentMapper.selectCount(null);
        long enterpriseCount = enterpriseMapper.selectCount(null);
        long jobCount = jobPostMapper.selectCount(null);
        long applyCount = jobApplyMapper.selectCount(null);
        result.put("studentCount", studentCount);
        result.put("enterpriseCount", enterpriseCount);
        result.put("jobCount", jobCount);
        result.put("applyCount", applyCount);

        // 预加载数据用于聚合
        List<Student> students = studentMapper.selectList(null);
        List<JobApply> applies = jobApplyMapper.selectList(null);
        List<JobPost> jobs = jobPostMapper.selectList(null);

        Map<Long, Student> studentMap = students.stream()
                .collect(Collectors.toMap(Student::getId, s -> s, (a, b) -> a));

        // 2. 各专业投递人数统计（按学生专业）
        Map<String, Long> majorApply = new LinkedHashMap<>();
        for (JobApply a : applies) {
            Student s = studentMap.get(a.getStudentId());
            String major = (s != null && s.getMajor() != null) ? s.getMajor() : "未知";
            majorApply.merge(major, 1L, Long::sum);
        }
        result.put("majorApply", toNameValueList(majorApply));

        // 3. 各岗位类别招聘数量统计
        Map<Long, String> catNameMap = jobCategoryMapper.selectList(null).stream()
                .collect(Collectors.toMap(JobCategory::getId, JobCategory::getName, (a, b) -> a));
        Map<String, Long> categoryJob = new LinkedHashMap<>();
        for (JobPost j : jobs) {
            String name = j.getCategoryId() != null ? catNameMap.getOrDefault(j.getCategoryId(), "其他") : "其他";
            categoryJob.merge(name, 1L, Long::sum);
        }
        result.put("categoryJob", toNameValueList(categoryJob));

        // 4. 企业招聘活跃度 Top（按企业发布职位数）
        Map<Long, Long> entJobCount = jobs.stream()
                .collect(Collectors.groupingBy(JobPost::getEnterpriseId, Collectors.counting()));
        Map<Long, String> entNameMap = enterpriseMapper.selectList(null).stream()
                .collect(Collectors.toMap(Enterprise::getId, Enterprise::getCompanyName, (a, b) -> a));
        List<Map<String, Object>> entActive = entJobCount.entrySet().stream()
                .sorted((a, b) -> Long.compare(b.getValue(), a.getValue()))
                .limit(10)
                .map(e -> {
                    Map<String, Object> m = new HashMap<>();
                    m.put("name", entNameMap.getOrDefault(e.getKey(), "企业" + e.getKey()));
                    m.put("value", e.getValue());
                    return m;
                })
                .collect(Collectors.toList());
        result.put("enterpriseActive", entActive);

        // 5. 投递到录用漏斗（按 job_apply.status）
        // 0待查看 1已查看 2邀请面试 3笔试 4已录用 5不合适
        long total = applies.size();
        long viewed = applies.stream().filter(a -> a.getStatus() != null && a.getStatus() >= 1 && a.getStatus() != 5).count();
        long interview = applies.stream().filter(a -> a.getStatus() != null && (a.getStatus() == 2 || a.getStatus() == 3 || a.getStatus() == 4)).count();
        long hired = applies.stream().filter(a -> a.getStatus() != null && a.getStatus() == 4).count();
        List<Map<String, Object>> funnel = new ArrayList<>();
        funnel.add(funnelItem("投递", total));
        funnel.add(funnelItem("被查看", viewed));
        funnel.add(funnelItem("进入面试", interview));
        funnel.add(funnelItem("录用", hired));
        result.put("funnel", funnel);

        // 6. 面试通过率
        long feedbackTotal = interviewFeedbackMapper.selectCount(null);
        long feedbackPass = interviewFeedbackMapper.selectCount(
                new LambdaQueryWrapper<InterviewFeedback>().eq(InterviewFeedback::getIsPass, 1));
        result.put("interviewPassRate", feedbackTotal == 0 ? 0 : Math.round(feedbackPass * 1000.0 / feedbackTotal) / 10.0);

        // 7. Offer 接受率
        long offerTotal = offerRecordMapper.selectCount(null);
        long offerAccept = offerRecordMapper.selectCount(
                new LambdaQueryWrapper<OfferRecord>().eq(OfferRecord::getOfferStatus, 1));
        result.put("offerAcceptRate", offerTotal == 0 ? 0 : Math.round(offerAccept * 1000.0 / offerTotal) / 10.0);

        // 8. 投递状态分布（用于饼图）
        Map<Integer, Long> statusCount = applies.stream()
                .filter(a -> a.getStatus() != null)
                .collect(Collectors.groupingBy(JobApply::getStatus, Collectors.counting()));
        String[] statusNames = {"待查看", "已查看", "邀请面试", "笔试", "已录用", "不合适"};
        List<Map<String, Object>> applyStatus = new ArrayList<>();
        for (int i = 0; i < statusNames.length; i++) {
            Map<String, Object> m = new HashMap<>();
            m.put("name", statusNames[i]);
            m.put("value", statusCount.getOrDefault(i, 0L));
            applyStatus.add(m);
        }
        result.put("applyStatus", applyStatus);

        return result;
    }

    private List<Map<String, Object>> toNameValueList(Map<String, Long> map) {
        return map.entrySet().stream().map(e -> {
            Map<String, Object> m = new HashMap<>();
            m.put("name", e.getKey());
            m.put("value", e.getValue());
            return m;
        }).collect(Collectors.toList());
    }

    private Map<String, Object> funnelItem(String name, long value) {
        Map<String, Object> m = new HashMap<>();
        m.put("name", name);
        m.put("value", value);
        return m;
    }
}
