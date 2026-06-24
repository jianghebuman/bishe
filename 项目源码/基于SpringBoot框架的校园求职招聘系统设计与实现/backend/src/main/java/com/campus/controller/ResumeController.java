package com.campus.controller;

import com.campus.common.RequireRole;
import com.campus.common.Result;
import com.campus.common.UserContext;
import com.campus.entity.Resume;
import com.campus.entity.ResumeAttachment;
import com.campus.entity.ResumeEducation;
import com.campus.entity.ResumeExperience;
import com.campus.entity.ResumeProject;
import com.campus.service.ResumeAttachmentService;
import com.campus.service.ResumeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 学生端：在线简历（主表 + 教育/项目/实习经历）与附件简历
 *
 * @author campus
 */
@RestController
@RequestMapping("/student/resume")
@RequireRole("STUDENT")
public class ResumeController {

    @Autowired
    private ResumeService resumeService;

    @Autowired
    private ResumeAttachmentService resumeAttachmentService;

    // ===== 简历主表 =====

    /** 获取当前学生的简历，没有则返回 null */
    @GetMapping
    public Result<Resume> getMyResume() {
        return Result.success(resumeService.getByStudent(UserContext.getUserId()));
    }

    /** 保存（新增或更新）当前学生的简历，返回简历ID与完整度 */
    @PostMapping
    public Result<Map<String, Object>> saveResume(@RequestBody Resume resume) {
        Long studentId = UserContext.getUserId();
        Long resumeId = resumeService.saveOrUpdateResume(studentId, resume);
        Resume saved = resumeService.getById(resumeId);
        Map<String, Object> data = new HashMap<>(2);
        data.put("resumeId", resumeId);
        data.put("completeRate", saved == null ? null : saved.getCompleteRate());
        return Result.success("简历保存成功", data);
    }

    // ===== 教育经历 =====

    /** 教育经历列表 */
    @GetMapping("/education")
    public Result<List<ResumeEducation>> listEducation(@RequestParam Long resumeId) {
        return Result.success(resumeService.listEducation(resumeId, UserContext.getUserId()));
    }

    /** 新增或更新教育经历 */
    @PostMapping("/education")
    public Result<Void> saveEducation(@RequestBody ResumeEducation education) {
        resumeService.saveOrUpdateEducation(UserContext.getUserId(), education);
        return Result.success("保存成功", null);
    }

    /** 删除教育经历 */
    @DeleteMapping("/education/{id}")
    public Result<Void> deleteEducation(@PathVariable Long id) {
        resumeService.deleteEducation(UserContext.getUserId(), id);
        return Result.success("删除成功", null);
    }

    // ===== 项目经历 =====

    /** 项目经历列表 */
    @GetMapping("/project")
    public Result<List<ResumeProject>> listProject(@RequestParam Long resumeId) {
        return Result.success(resumeService.listProject(resumeId, UserContext.getUserId()));
    }

    /** 新增或更新项目经历 */
    @PostMapping("/project")
    public Result<Void> saveProject(@RequestBody ResumeProject project) {
        resumeService.saveOrUpdateProject(UserContext.getUserId(), project);
        return Result.success("保存成功", null);
    }

    /** 删除项目经历 */
    @DeleteMapping("/project/{id}")
    public Result<Void> deleteProject(@PathVariable Long id) {
        resumeService.deleteProject(UserContext.getUserId(), id);
        return Result.success("删除成功", null);
    }

    // ===== 实习/工作经历 =====

    /** 实习经历列表 */
    @GetMapping("/experience")
    public Result<List<ResumeExperience>> listExperience(@RequestParam Long resumeId) {
        return Result.success(resumeService.listExperience(resumeId, UserContext.getUserId()));
    }

    /** 新增或更新实习经历 */
    @PostMapping("/experience")
    public Result<Void> saveExperience(@RequestBody ResumeExperience experience) {
        resumeService.saveOrUpdateExperience(UserContext.getUserId(), experience);
        return Result.success("保存成功", null);
    }

    /** 删除实习经历 */
    @DeleteMapping("/experience/{id}")
    public Result<Void> deleteExperience(@PathVariable Long id) {
        resumeService.deleteExperience(UserContext.getUserId(), id);
        return Result.success("删除成功", null);
    }

    // ===== 附件简历 =====

    /** 当前学生的附件简历列表 */
    @GetMapping("/attachment")
    public Result<List<ResumeAttachment>> listAttachment() {
        return Result.success(resumeAttachmentService.listByStudent(UserContext.getUserId()));
    }

    /** 上传附件简历 */
    @PostMapping("/attachment")
    public Result<ResumeAttachment> uploadAttachment(@RequestParam("file") MultipartFile file) {
        ResumeAttachment attachment = resumeAttachmentService.upload(UserContext.getUserId(), file);
        return Result.success("上传成功", attachment);
    }

    /** 删除附件简历 */
    @DeleteMapping("/attachment/{id}")
    public Result<Void> deleteAttachment(@PathVariable Long id) {
        resumeAttachmentService.deleteOwn(UserContext.getUserId(), id);
        return Result.success("删除成功", null);
    }
}
