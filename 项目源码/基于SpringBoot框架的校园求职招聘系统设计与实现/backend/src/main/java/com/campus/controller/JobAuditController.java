package com.campus.controller;

import com.campus.common.PageResult;
import com.campus.common.RequireRole;
import com.campus.common.Result;
import com.campus.service.JobAuditService;
import com.campus.vo.JobAuditVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 管理员-岗位审核
 *
 * @author campus
 */
@RestController
@RequestMapping("/admin/job")
@RequireRole("ADMIN")
public class JobAuditController {

    @Autowired
    private JobAuditService jobAuditService;

    @GetMapping
    public Result<PageResult<JobAuditVO>> page(@RequestParam(defaultValue = "1") Integer pageNum,
                                               @RequestParam(defaultValue = "10") Integer pageSize,
                                               @RequestParam(required = false) Integer auditStatus,
                                               @RequestParam(required = false) String title) {
        return Result.success(jobAuditService.auditPage(pageNum, pageSize, auditStatus, title));
    }

    @PutMapping("/{id}/audit")
    public Result<Void> audit(@PathVariable Long id,
                              @RequestParam Integer status,
                              @RequestParam(required = false) String remark) {
        if (status == 1) {
            jobAuditService.pass(id);
            return Result.success("审核通过", null);
        } else {
            jobAuditService.reject(id, remark);
            return Result.success("已驳回", null);
        }
    }

    @PutMapping("/{id}/offline")
    public Result<Void> offline(@PathVariable Long id) {
        jobAuditService.offline(id);
        return Result.success("已下架", null);
    }
}
