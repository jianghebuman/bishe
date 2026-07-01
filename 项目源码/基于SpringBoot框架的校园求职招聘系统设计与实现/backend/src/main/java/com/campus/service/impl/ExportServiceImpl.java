package com.campus.service.impl;

import com.alibaba.excel.EasyExcel;
import com.alibaba.excel.ExcelWriter;
import com.alibaba.excel.write.metadata.WriteSheet;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
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
import java.util.function.Function;

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
    private static final long EXPORT_PAGE_SIZE = 500L;

    @Override
    public void exportStudents(HttpServletResponse response) {
        write(response, "学生信息", StudentExcel.class, (pageNum, pageSize) -> studentMapper
                .selectPage(new Page<>(pageNum, pageSize, false),
                        new LambdaQueryWrapper<Student>().orderByAsc(Student::getId))
                .getRecords().stream().map(s -> {
            StudentExcel e = new StudentExcel();
            BeanUtils.copyProperties(s, e);
            return e;
        }).collect(Collectors.toList()));
    }

    @Override
    public void exportEnterprises(HttpServletResponse response) {
        write(response, "企业信息", EnterpriseExcel.class, (pageNum, pageSize) -> enterpriseMapper
                .selectPage(new Page<>(pageNum, pageSize, false),
                        new LambdaQueryWrapper<Enterprise>().orderByAsc(Enterprise::getId))
                .getRecords().stream().map(en -> {
            EnterpriseExcel e = new EnterpriseExcel();
            BeanUtils.copyProperties(en, e);
            int st = en.getAuditStatus() == null ? 0 : en.getAuditStatus();
            e.setAuditStatusText(st >= 0 && st < AUDIT_TEXT.length ? AUDIT_TEXT[st] : "未知");
            return e;
        }).collect(Collectors.toList()));
    }

    @Override
    public void exportJobs(HttpServletResponse response) {
        write(response, "岗位信息", JobExcel.class, (pageNum, pageSize) -> {
            List<JobPost> jobs = jobPostMapper
                    .selectPage(new Page<>(pageNum, pageSize, false),
                            new LambdaQueryWrapper<JobPost>().orderByAsc(JobPost::getId))
                    .getRecords();
            Map<Long, String> entNameMap = nameMap(jobs.stream().map(JobPost::getEnterpriseId).collect(Collectors.toSet()),
                    ids -> enterpriseMapper.selectBatchIds(ids), Enterprise::getId, Enterprise::getCompanyName);
            return jobs.stream().map(j -> {
                JobExcel e = new JobExcel();
                BeanUtils.copyProperties(j, e);
                e.setCompanyName(entNameMap.get(j.getEnterpriseId()));
                return e;
            }).collect(Collectors.toList());
        });
    }

    @Override
    public void exportApplies(HttpServletResponse response) {
        write(response, "投递记录", ApplyExcel.class, (pageNum, pageSize) -> {
            List<JobApply> applies = jobApplyMapper
                    .selectPage(new Page<>(pageNum, pageSize, false),
                            new LambdaQueryWrapper<JobApply>().orderByAsc(JobApply::getId))
                    .getRecords();
            Map<Long, String> stuNameMap = nameMap(applies.stream().map(JobApply::getStudentId).collect(Collectors.toSet()),
                    ids -> studentMapper.selectBatchIds(ids), Student::getId, Student::getRealName);
            Map<Long, String> entNameMap = nameMap(applies.stream().map(JobApply::getEnterpriseId).collect(Collectors.toSet()),
                    ids -> enterpriseMapper.selectBatchIds(ids), Enterprise::getId, Enterprise::getCompanyName);
            Map<Long, String> jobTitleMap = nameMap(applies.stream().map(JobApply::getJobId).collect(Collectors.toSet()),
                    ids -> jobPostMapper.selectBatchIds(ids), JobPost::getId, JobPost::getTitle);
            return applies.stream().map(a -> {
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
        });
    }

    /** 通用写出 */
    private <T> void write(HttpServletResponse response, String fileName, Class<T> clazz, PageLoader<T> loader) {
        try {
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setCharacterEncoding("utf-8");
            String name = URLEncoder.encode(fileName, "UTF-8").replaceAll("\\+", "%20");
            response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + name + ".xlsx");
            ExcelWriter writer = EasyExcel.write(response.getOutputStream(), clazz).build();
            try {
                WriteSheet sheet = EasyExcel.writerSheet(fileName).build();
                for (long pageNum = 1; ; pageNum++) {
                    List<T> data = loader.load(pageNum, EXPORT_PAGE_SIZE);
                    if (data.isEmpty()) {
                        break;
                    }
                    writer.write(data, sheet);
                    if (data.size() < EXPORT_PAGE_SIZE) {
                        break;
                    }
                }
            } finally {
                writer.finish();
            }
        } catch (Exception e) {
            throw new BusinessException("导出失败：" + e.getMessage());
        }
    }

    private <E> Map<Long, String> nameMap(Set<Long> ids, Function<Collection<Long>, List<E>> loader,
                                          Function<E, Long> idGetter, Function<E, String> nameGetter) {
        ids.remove(null);
        if (ids.isEmpty()) {
            return Collections.emptyMap();
        }
        return loader.apply(ids).stream()
                .collect(Collectors.toMap(idGetter, nameGetter, (a, b) -> a));
    }

    private interface PageLoader<T> {
        List<T> load(long pageNum, long pageSize);
    }
}
