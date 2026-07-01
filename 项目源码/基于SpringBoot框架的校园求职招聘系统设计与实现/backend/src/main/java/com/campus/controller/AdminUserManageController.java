package com.campus.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.common.PageResult;
import com.campus.common.RequireRole;
import com.campus.common.Result;
import com.campus.entity.Enterprise;
import com.campus.entity.EnterpriseAudit;
import com.campus.entity.EnterpriseHr;
import com.campus.entity.Student;
import com.campus.dto.EnterpriseHrDTO;
import com.campus.service.EnterpriseHrService;
import com.campus.service.EnterpriseService;
import com.campus.service.OperationLogService;
import com.campus.service.StudentService;
import com.campus.service.SystemNoticeService;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.campus.mapper.EnterpriseAuditMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.Date;

/**
 * 管理员-用户管理（学生、企业）
 *
 * @author campus
 */
@RestController
@RequestMapping("/admin")
@RequireRole("ADMIN")
public class AdminUserManageController {

    @Autowired
    private StudentService studentService;
    @Autowired
    private EnterpriseService enterpriseService;
    @Autowired
    private EnterpriseHrService enterpriseHrService;
    @Autowired
    private EnterpriseAuditMapper enterpriseAuditMapper;
    @Autowired
    private BCryptPasswordEncoder passwordEncoder;
    @Autowired
    private OperationLogService operationLogService;
    @Autowired
    private SystemNoticeService systemNoticeService;

    // ==================== 学生管理 ====================

    @GetMapping("/student")
    public Result<PageResult<Student>> studentPage(@RequestParam(defaultValue = "1") Integer pageNum,
                                                   @RequestParam(defaultValue = "10") Integer pageSize,
                                                   @RequestParam(required = false) String keyword) {
        Page<Student> page = new Page<>(pageNum, pageSize);
        boolean hasKw = keyword != null && !keyword.isEmpty();
        LambdaQueryWrapper<Student> wrapper = new LambdaQueryWrapper<Student>()
                .and(hasKw, w -> w.like(Student::getRealName, keyword)
                        .or().like(Student::getUsername, keyword)
                        .or().like(Student::getSchool, keyword)
                        .or().like(Student::getStudentNo, keyword))
                .orderByDesc(Student::getCreateTime);
        studentService.page(page, wrapper);
        // 脱敏：不返回密码
        page.getRecords().forEach(s -> s.setPassword(null));
        return Result.success(PageResult.of(page.getTotal(), page.getRecords()));
    }

    @PostMapping("/student")
    public Result<Void> addStudent(@RequestBody Student student) {
        student.setPassword(passwordEncoder.encode("123456"));
        student.setStatus(1);
        studentService.save(student);
        return Result.success("新增成功，初始密码123456", null);
    }

    @PutMapping("/student")
    public Result<Void> updateStudent(@RequestBody Student student) {
        student.setPassword(null);
        studentService.updateById(student);
        return Result.success("修改成功", null);
    }

    @PutMapping("/student/{id}/status")
    public Result<Void> toggleStudent(@PathVariable Long id, @RequestParam Integer status) {
        Student s = new Student();
        s.setId(id);
        s.setStatus(status);
        studentService.updateById(s);
        return Result.success(status == 1 ? "已启用" : "已禁用", null);
    }

    @PutMapping("/student/{id}/reset")
    public Result<Void> resetStudentPwd(@PathVariable Long id) {
        Student s = new Student();
        s.setId(id);
        s.setPassword(passwordEncoder.encode("123456"));
        studentService.updateById(s);
        return Result.success("密码已重置为123456", null);
    }

    // ==================== 企业管理 ====================

    @GetMapping("/enterprise")
    public Result<PageResult<Enterprise>> enterprisePage(@RequestParam(defaultValue = "1") Integer pageNum,
                                                         @RequestParam(defaultValue = "10") Integer pageSize,
                                                         @RequestParam(required = false) String keyword,
                                                         @RequestParam(required = false) Integer auditStatus) {
        Page<Enterprise> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<Enterprise> wrapper = new LambdaQueryWrapper<Enterprise>()
                .like(keyword != null && !keyword.isEmpty(), Enterprise::getCompanyName, keyword)
                .eq(auditStatus != null, Enterprise::getAuditStatus, auditStatus)
                .orderByDesc(Enterprise::getCreateTime);
        enterpriseService.page(page, wrapper);
        return Result.success(PageResult.of(page.getTotal(), page.getRecords()));
    }

    @PutMapping("/enterprise/{id}/status")
    public Result<Void> toggleEnterprise(@PathVariable Long id, @RequestParam Integer status) {
        Enterprise e = new Enterprise();
        e.setId(id);
        e.setStatus(status);
        enterpriseService.updateById(e);
        return Result.success(status == 1 ? "已启用" : "已禁用", null);
    }

    // ==================== 企业 HR 管理 ====================

    @GetMapping("/enterprise/{enterpriseId}/hr")
    public Result<PageResult<EnterpriseHr>> enterpriseHrPage(@PathVariable Long enterpriseId,
                                                            @RequestParam(defaultValue = "1") Integer pageNum,
                                                            @RequestParam(defaultValue = "10") Integer pageSize,
                                                            @RequestParam(required = false) String keyword) {
        if (enterpriseService.getById(enterpriseId) == null) {
            return Result.error("企业不存在");
        }
        return Result.success(enterpriseHrService.pageByEnterprise(enterpriseId, pageNum, pageSize, keyword));
    }

    @PostMapping("/enterprise/{enterpriseId}/hr")
    public Result<Long> addEnterpriseHr(@PathVariable Long enterpriseId, @Valid @RequestBody EnterpriseHrDTO dto) {
        if (enterpriseService.getById(enterpriseId) == null) {
            return Result.error("企业不存在");
        }
        Long id = enterpriseHrService.createHr(enterpriseId, dto);
        operationLogService.record("OPERATION", "企业HR管理", "新增企业HR：" + dto.getUsername(), 1);
        return Result.success("新增成功，初始密码123456", id);
    }

    @PutMapping("/enterprise/hr/{id}")
    public Result<Void> updateEnterpriseHr(@PathVariable Long id, @Valid @RequestBody EnterpriseHrDTO dto) {
        enterpriseHrService.updateHr(id, dto);
        operationLogService.record("OPERATION", "企业HR管理", "修改企业HR：" + id, 1);
        return Result.success("修改成功", null);
    }

    @PutMapping("/enterprise/hr/{id}/role")
    public Result<Void> updateEnterpriseHrRole(@PathVariable Long id, @RequestParam String role) {
        enterpriseHrService.changeRole(id, role);
        operationLogService.record("OPERATION", "企业HR管理", "调整企业HR角色：" + id + " -> " + role, 1);
        return Result.success("角色已更新", null);
    }

    @PutMapping("/enterprise/hr/{id}/status")
    public Result<Void> updateEnterpriseHrStatus(@PathVariable Long id, @RequestParam Integer status) {
        enterpriseHrService.changeStatus(id, status);
        return Result.success(status == 1 ? "已启用" : "已禁用", null);
    }

    @PutMapping("/enterprise/hr/{id}/reset")
    public Result<Void> resetEnterpriseHrPassword(@PathVariable Long id) {
        enterpriseHrService.resetPassword(id);
        return Result.success("密码已重置为123456", null);
    }

    /** 企业认证审核列表（待审核的认证申请） */
    @GetMapping("/enterprise/audit")
    public Result<PageResult<EnterpriseAudit>> auditPage(@RequestParam(defaultValue = "1") Integer pageNum,
                                                         @RequestParam(defaultValue = "10") Integer pageSize,
                                                         @RequestParam(required = false) Long enterpriseId,
                                                         @RequestParam(required = false) Integer auditStatus) {
        Page<EnterpriseAudit> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<EnterpriseAudit> wrapper = new LambdaQueryWrapper<EnterpriseAudit>()
                .eq(enterpriseId != null, EnterpriseAudit::getEnterpriseId, enterpriseId)
                .eq(auditStatus != null, EnterpriseAudit::getAuditStatus, auditStatus)
                .orderByDesc(EnterpriseAudit::getCreateTime);
        enterpriseAuditMapper.selectPage(page, wrapper);
        return Result.success(PageResult.of(page.getTotal(), page.getRecords()));
    }

    /** 审核企业认证：status=2通过 3驳回，同时更新企业表 audit_status */
    @PutMapping("/enterprise/audit/{id}")
    public Result<Void> auditEnterprise(@PathVariable Long id,
                                        @RequestParam Integer status,
                                        @RequestParam(required = false) String remark) {
        if (!Integer.valueOf(2).equals(status) && !Integer.valueOf(3).equals(status)) {
            return Result.error("审核状态只能为通过或驳回");
        }
        EnterpriseAudit audit = enterpriseAuditMapper.selectById(id);
        if (audit == null) {
            return Result.error("认证记录不存在");
        }
        audit.setAuditStatus(status);
        audit.setAuditRemark(remark);
        audit.setAuditorId(com.campus.common.UserContext.getUserId());
        audit.setAuditTime(new Date());
        enterpriseAuditMapper.updateById(audit);
        // 同步企业认证状态
        LambdaUpdateWrapper<Enterprise> up = new LambdaUpdateWrapper<Enterprise>()
                .eq(Enterprise::getId, audit.getEnterpriseId())
                .set(Enterprise::getAuditStatus, status);
        enterpriseService.update(up);
        Enterprise enterprise = enterpriseService.getById(audit.getEnterpriseId());
        String companyName = enterprise == null ? String.valueOf(audit.getEnterpriseId()) : enterprise.getCompanyName();
        systemNoticeService.sendToEnterpriseSupervisors(audit.getEnterpriseId(),
                status == 2 ? "企业认证审核通过" : "企业认证审核驳回",
                status == 2
                        ? "您的企业认证已审核通过，可正常开展招聘。"
                        : "您的企业认证未通过审核。原因：" + (remark == null ? "请修改材料后重新提交。" : remark),
                "AUDIT");
        operationLogService.record("OPERATION", "企业管理",
                (status == 2 ? "审核通过企业认证：" : "驳回企业认证：") + companyName, 1);
        return Result.success(status == 2 ? "审核通过" : "已驳回", null);
    }
}
