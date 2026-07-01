package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.campus.entity.*;
import com.campus.mapper.*;
import com.campus.service.StatisticsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

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

        // 2. 各专业投递人数统计（按学生专业）
        result.put("majorApply", toNameValueList(jobApplyMapper.countApplyByMajor()));

        // 3. 各岗位类别招聘数量统计
        result.put("categoryJob", toNameValueList(jobPostMapper.countJobsByCategory()));

        // 4. 企业招聘活跃度 Top（按企业发布职位数）
        result.put("enterpriseActive", toNameValueList(jobPostMapper.countTopEnterpriseActivity()));

        // 5. 投递到录用漏斗（按 job_apply.status）
        // 0待查看 1已查看 2邀请面试 3笔试 4已录用 5不合适
        Map<Integer, Long> statusCount = toStatusCountMap(jobApplyMapper.countApplyByStatus());
        long total = applyCount;
        long viewed = statusCount.getOrDefault(1, 0L) + statusCount.getOrDefault(2, 0L)
                + statusCount.getOrDefault(3, 0L) + statusCount.getOrDefault(4, 0L);
        long interview = statusCount.getOrDefault(2, 0L) + statusCount.getOrDefault(3, 0L)
                + statusCount.getOrDefault(4, 0L);
        long hired = statusCount.getOrDefault(4, 0L);
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
        double interviewPassRate = rate(feedbackPass, feedbackTotal);
        result.put("interviewPassRate", interviewPassRate);

        // 7. Offer 接受率
        long offerTotal = offerRecordMapper.selectCount(null);
        long offerAccept = offerRecordMapper.selectCount(
                new LambdaQueryWrapper<OfferRecord>().eq(OfferRecord::getOfferStatus, 1));
        double offerAcceptRate = rate(offerAccept, offerTotal);
        result.put("offerAcceptRate", offerAcceptRate);

        List<Map<String, Object>> keyRates = new ArrayList<>();
        keyRates.add(rateItem("简历查看率", rate(viewed, total), "已查看及后续状态占投递总数"));
        keyRates.add(rateItem("面试转化率", rate(interview, total), "进入面试环节占投递总数"));
        keyRates.add(rateItem("录用转化率", rate(hired, total), "最终录用占投递总数"));
        keyRates.add(rateItem("面试通过率", interviewPassRate, "面试反馈中通过的比例"));
        keyRates.add(rateItem("Offer 接受率", offerAcceptRate, "已发 Offer 中被接受的比例"));
        result.put("keyRates", keyRates);

        // 8. 投递状态分布（用于饼图）
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

    private List<Map<String, Object>> toNameValueList(List<Map<String, Object>> rows) {
        List<Map<String, Object>> list = new ArrayList<>();
        for (Map<String, Object> row : rows) {
            Map<String, Object> m = new HashMap<>();
            Object name = get(row, "name");
            m.put("name", name == null ? "" : name.toString());
            m.put("value", toLong(get(row, "value")));
            list.add(m);
        }
        return list;
    }

    private Map<Integer, Long> toStatusCountMap(List<Map<String, Object>> rows) {
        Map<Integer, Long> map = new HashMap<>();
        for (Map<String, Object> row : rows) {
            Integer status = toInteger(get(row, "status"));
            if (status != null) {
                map.put(status, toLong(get(row, "value")));
            }
        }
        return map;
    }

    private Object get(Map<String, Object> row, String key) {
        Object value = row.get(key);
        if (value == null) {
            value = row.get(key.toUpperCase(Locale.ROOT));
        }
        return value;
    }

    private long toLong(Object value) {
        if (value instanceof Number) {
            return ((Number) value).longValue();
        }
        return value == null ? 0L : Long.parseLong(value.toString());
    }

    private Integer toInteger(Object value) {
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }
        return value == null ? null : Integer.valueOf(value.toString());
    }

    private Map<String, Object> funnelItem(String name, long value) {
        Map<String, Object> m = new HashMap<>();
        m.put("name", name);
        m.put("value", value);
        return m;
    }

    private double rate(long part, long total) {
        return total == 0 ? 0 : Math.round(part * 1000.0 / total) / 10.0;
    }

    private Map<String, Object> rateItem(String name, double value, String caption) {
        Map<String, Object> m = new HashMap<>();
        m.put("name", name);
        m.put("value", value);
        m.put("caption", caption);
        return m;
    }
}
