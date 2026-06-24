package com.campus.service.impl;

import com.alibaba.excel.EasyExcel;
import com.campus.common.BusinessException;
import com.campus.entity.*;
import com.campus.mapper.*;
import com.campus.service.ExportService;
import com.campus.vo.excel.*;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.servlet.http.HttpServletResponse;
import java.net.URLEncoder;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 数据导出服务实现（EasyExcel）
 *
 * @author campus
 */
@Service
public class ExportServiceImpl implements ExportService {

    @Autowired
    private StudentMapper studentMapper;
    @Autowired
    private EnterpriseMapper enterpriseMapper;
    @Autowired
    private JobPostMapper jobPostMapper;
    @Autowired
    private JobApplyMapper jobApplyMapper;

    private static final String[] AUDIT_TEXT = {"未认证", "待审核", "已通过", "已驳回"};
    private static final String[] APPLY_TEXT = {"待查看", "已查看", "邀请面试", "笔试", "已录用", "不合适"};

    @Override
    public void exportStudents(HttpServletResponse response) {
        List<StudentExcel> list = studentMapper.selectList(null).stream().map(s -> {
            StudentExcel e = new StudentExcel();
            BeanUtils.copyProperties(s, e);
            return e;
        }).collect(Collectors.toList());
        write(response, "学生信息", StudentExcel.class, list);
    }

    @Override
    public void exportEnterprises(HttpServletResponse response) {
        List<EnterpriseExcel> list = enterpriseMapper.selectList(null).stream().map(en -> {
            EnterpriseExcel e = new EnterpriseExcel();
            BeanUtils.copyProperties(en, e);
            int st = en.getAuditStatus() == null ? 0 : en.getAuditStatus();
            e.setAuditStatusText(st >= 0 && st < AUDIT_TEXT.length ? AUDIT_TEXT[st] : "未知");
            return e;
        }).collect(Collectors.toList());
        write(response, "企业信息", EnterpriseExcel.class, list);
    }

    @Override
    public void exportJobs(HttpServletResponse response) {
        Map<Long, String> entNameMap = enterpriseMapper.selectList(null).stream()
                .collect(Collectors.toMap(Enterprise::getId, Enterprise::getCompanyName, (a, b) -> a));
        List<JobExcel> list = jobPostMapper.selectList(null).stream().map(j -> {
            JobExcel e = new JobExcel();
            BeanUtils.copyProperties(j, e);
            e.setCompanyName(entNameMap.get(j.getEnterpriseId()));
            return e;
        }).collect(Collectors.toList());
        write(response, "岗位信息", JobExcel.class, list);
    }

    @Override
    public void exportApplies(HttpServletResponse response) {
        Map<Long, String> stuNameMap = studentMapper.selectList(null).stream()
                .collect(Collectors.toMap(Student::getId, Student::getRealName, (a, b) -> a));
        Map<Long, String> entNameMap = enterpriseMapper.selectList(null).stream()
                .collect(Collectors.toMap(Enterprise::getId, Enterprise::getCompanyName, (a, b) -> a));
        Map<Long, String> jobTitleMap = jobPostMapper.selectList(null).stream()
                .collect(Collectors.toMap(JobPost::getId, JobPost::getTitle, (a, b) -> a));
        List<ApplyExcel> list = jobApplyMapper.selectList(null).stream().map(a -> {
            ApplyExcel e = new ApplyExcel();
            e.setId(a.getId());
            e.setStudentName(stuNameMap.get(a.getStudentId()));
            e.setJobTitle(jobTitleMap.get(a.getJobId()));
            e.setCompanyName(entNameMap.get(a.getEnterpriseId()));
            int st = a.getStatus() == null ? 0 : a.getStatus();
            e.setStatusText(st >= 0 && st < APPLY_TEXT.length ? APPLY_TEXT[st] : "未知");
            e.setCreateTime(a.getCreateTime());
            return e;
        }).collect(Collectors.toList());
        write(response, "投递记录", ApplyExcel.class, list);
    }

    /** 通用写出 */
    private <T> void write(HttpServletResponse response, String fileName, Class<T> clazz, List<T> data) {
        try {
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setCharacterEncoding("utf-8");
            String name = URLEncoder.encode(fileName, "UTF-8").replaceAll("\\+", "%20");
            response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + name + ".xlsx");
            EasyExcel.write(response.getOutputStream(), clazz).sheet(fileName).doWrite(data);
        } catch (Exception e) {
            throw new BusinessException("导出失败：" + e.getMessage());
        }
    }
}
