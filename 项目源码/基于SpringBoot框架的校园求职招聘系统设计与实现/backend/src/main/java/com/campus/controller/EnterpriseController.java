package com.campus.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.campus.common.RequireRole;
import com.campus.common.Result;
import com.campus.common.UserContext;
import com.campus.entity.Enterprise;
import com.campus.entity.EnterpriseAudit;
import com.campus.entity.InterviewNotice;
import com.campus.entity.JobApply;
import com.campus.entity.JobPost;
import com.campus.entity.OfferRecord;
import com.campus.common.FileUploadUtil;
import com.campus.service.EnterpriseAuditService;
import com.campus.service.EnterpriseApplyService;
import com.campus.service.EnterpriseService;
import com.campus.service.InterviewService;
import com.campus.service.JobPostService;
import com.campus.service.OfferService;
import com.campus.service.OperationLogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 企业资料、认证、数据看板（企业HR端）
 *
 * @author campus
 */
@RestController
@RequestMapping("/enterprise")
@RequireRole("ENTERPRISE")
public class EnterpriseController {

    @Autowired
    private EnterpriseService enterpriseService;

    @Autowired
    private EnterpriseAuditService enterpriseAuditService;

    @Autowired
    private JobPostService jobPostService;

    @Autowired
    private EnterpriseApplyService enterpriseApplyService;

    @Autowired
    private InterviewService interviewService;

    @Autowired
    private OfferService offerService;

    @Autowired
    private FileUploadUtil fileUploadUtil;

    @Autowired
    private OperationLogService operationLogService;

    /** 获取当前企业资料 */
    @GetMapping("/profile")
    public Result<Enterprise> profile() {
        Enterprise enterprise = enterpriseService.getById(UserContext.getUserId());
        if (enterprise != null) {
            enterprise.setPassword(null);
        }
        return Result.success(enterprise);
    }

    /** 更新当前企业资料 */
    @PutMapping("/profile")
    public Result<Void> updateProfile(@RequestBody Enterprise enterprise) {
        // 强制只更新当前登录企业，且禁止越权改账号/密码/认证状态等敏感字段
        enterprise.setId(UserContext.getUserId());
        enterprise.setUsername(null);
        enterprise.setPassword(null);
        enterprise.setAuditStatus(null);
        enterprise.setStatus(null);
        enterprise.setCreateTime(null);
        enterpriseService.updateById(enterprise);
        operationLogService.record("OPERATION", "企业资料", "更新企业资料", 1);
        return Result.success("资料更新成功", null);
    }

    /** 上传企业 Logo */
    @PostMapping("/logo")
    public Result<String> uploadLogo(@RequestParam("file") MultipartFile file) {
        String path = fileUploadUtil.uploadImage(file);
        Enterprise update = new Enterprise();
        update.setId(UserContext.getUserId());
        update.setLogo(path);
        enterpriseService.updateById(update);
        return Result.success("Logo上传成功", path);
    }

    /** 上传企业认证材料 */
    @PostMapping("/audit/upload")
    public Result<String> uploadAuditMaterial(@RequestParam("file") MultipartFile file) {
        String path = fileUploadUtil.uploadImage(file);
        return Result.success("材料上传成功", path);
    }

    /** 提交企业认证 */
    @PostMapping("/audit")
    public Result<Void> submitAudit(@RequestParam("licenseNo") String licenseNo,
                                    @RequestParam("licenseImg") String licenseImg,
                                    @RequestParam(value = "extraImg", required = false) String extraImg) {
        enterpriseAuditService.submitAudit(licenseNo, licenseImg, extraImg);
        operationLogService.record("OPERATION", "企业认证", "提交认证申请", 1);
        return Result.success("认证申请已提交，请等待审核", null);
    }

    /** 查询认证状态（当前企业最新一条认证记录 + 企业当前认证状态） */
    @GetMapping("/audit")
    public Result<Map<String, Object>> auditStatus() {
        Map<String, Object> map = new HashMap<>(4);
        Enterprise enterprise = enterpriseService.getById(UserContext.getUserId());
        EnterpriseAudit latest = enterpriseAuditService.getLatest();
        map.put("auditStatus", enterprise == null ? null : enterprise.getAuditStatus());
        map.put("latestAudit", latest);
        return Result.success(map);
    }

    /**
     * 数据看板：职位数、各状态投递数（待查看/面试/录用）、面试数、Offer数、近7天投递趋势。
     */
    @GetMapping("/dashboard")
    public Result<Map<String, Object>> dashboard() {
        Long enterpriseId = UserContext.getUserId();
        Map<String, Object> data = new HashMap<>(16);

        // 职位数（总数 + 招聘中）
        long jobTotal = jobPostService.count(new LambdaQueryWrapper<JobPost>()
                .eq(JobPost::getEnterpriseId, enterpriseId));
        long jobOnline = jobPostService.count(new LambdaQueryWrapper<JobPost>()
                .eq(JobPost::getEnterpriseId, enterpriseId)
                .eq(JobPost::getStatus, 1));
        data.put("jobTotal", jobTotal);
        data.put("jobOnline", jobOnline);

        // 各状态投递数
        long applyTotal = enterpriseApplyService.count(new LambdaQueryWrapper<JobApply>()
                .eq(JobApply::getEnterpriseId, enterpriseId));
        long applyPending = enterpriseApplyService.count(new LambdaQueryWrapper<JobApply>()
                .eq(JobApply::getEnterpriseId, enterpriseId)
                .eq(JobApply::getStatus, 0));
        long applyInterview = enterpriseApplyService.count(new LambdaQueryWrapper<JobApply>()
                .eq(JobApply::getEnterpriseId, enterpriseId)
                .eq(JobApply::getStatus, 2));
        long applyHired = enterpriseApplyService.count(new LambdaQueryWrapper<JobApply>()
                .eq(JobApply::getEnterpriseId, enterpriseId)
                .eq(JobApply::getStatus, 4));
        data.put("applyTotal", applyTotal);
        data.put("applyPending", applyPending);
        data.put("applyInterview", applyInterview);
        data.put("applyHired", applyHired);

        // 面试数
        long interviewTotal = interviewService.count(new LambdaQueryWrapper<InterviewNotice>()
                .eq(InterviewNotice::getEnterpriseId, enterpriseId));
        data.put("interviewTotal", interviewTotal);

        // Offer 数
        long offerTotal = offerService.count(new LambdaQueryWrapper<OfferRecord>()
                .eq(OfferRecord::getEnterpriseId, enterpriseId));
        data.put("offerTotal", offerTotal);

        // 近7天投递趋势（按天统计 createTime）
        data.put("applyTrend", buildApplyTrend(enterpriseId));

        return Result.success(data);
    }

    /** 构造近7天投递趋势：[{date:yyyy-MM-dd, count:n}, ...]，从今天往前7天 */
    private List<Map<String, Object>> buildApplyTrend(Long enterpriseId) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        List<Map<String, Object>> trend = new ArrayList<>(7);
        for (int i = 6; i >= 0; i--) {
            Calendar start = Calendar.getInstance();
            start.add(Calendar.DAY_OF_MONTH, -i);
            start.set(Calendar.HOUR_OF_DAY, 0);
            start.set(Calendar.MINUTE, 0);
            start.set(Calendar.SECOND, 0);
            start.set(Calendar.MILLISECOND, 0);
            Date dayStart = start.getTime();
            Calendar endCal = (Calendar) start.clone();
            endCal.add(Calendar.DAY_OF_MONTH, 1);
            Date dayEnd = endCal.getTime();
            long count = enterpriseApplyService.count(new LambdaQueryWrapper<JobApply>()
                    .eq(JobApply::getEnterpriseId, enterpriseId)
                    .ge(JobApply::getCreateTime, dayStart)
                    .lt(JobApply::getCreateTime, dayEnd));
            Map<String, Object> item = new LinkedHashMap<>(2);
            item.put("date", sdf.format(dayStart));
            item.put("count", count);
            trend.add(item);
        }
        return trend;
    }
}
