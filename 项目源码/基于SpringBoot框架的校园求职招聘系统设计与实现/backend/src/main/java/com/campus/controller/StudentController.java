package com.campus.controller;

import com.campus.common.RequireRole;
import com.campus.common.Result;
import com.campus.common.UserContext;
import com.campus.entity.JobIntention;
import com.campus.entity.Student;
import com.campus.service.JobIntentionService;
import com.campus.service.StudentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.campus.common.FileUploadUtil;

/**
 * 学生端：个人资料、求职意向
 *
 * @author campus
 */
@RestController
@RequestMapping("/student")
@RequireRole("STUDENT")
public class StudentController {

    @Autowired
    private StudentService studentService;

    @Autowired
    private JobIntentionService jobIntentionService;

    @Autowired
    private FileUploadUtil fileUploadUtil;

    // ===== 个人资料 =====

    /** 获取当前学生资料 */
    @GetMapping("/profile")
    public Result<Student> profile() {
        Student student = studentService.getById(UserContext.getUserId());
        if (student != null) {
            student.setPassword(null);
        }
        return Result.success(student);
    }

    /** 更新当前学生资料（仅允许修改本人可维护字段） */
    @PutMapping("/profile")
    public Result<Void> updateProfile(@RequestBody Student form) {
        Long studentId = UserContext.getUserId();
        Student update = new Student();
        update.setId(studentId);
        update.setRealName(form.getRealName());
        update.setStudentNo(form.getStudentNo());
        update.setGender(form.getGender());
        update.setCollege(form.getCollege());
        update.setMajor(form.getMajor());
        update.setGrade(form.getGrade());
        update.setEducation(form.getEducation());
        update.setPhone(form.getPhone());
        update.setEmail(form.getEmail());
        update.setIntro(form.getIntro());
        studentService.updateById(update);
        return Result.success("资料更新成功", null);
    }

    /** 上传头像 */
    @PostMapping("/avatar")
    public Result<String> avatar(@RequestParam("file") MultipartFile file) {
        Long studentId = UserContext.getUserId();
        String url = fileUploadUtil.uploadImage(file);
        Student update = new Student();
        update.setId(studentId);
        update.setAvatar(url);
        studentService.updateById(update);
        return Result.success("头像上传成功", url);
    }

    // ===== 求职意向 =====

    /** 获取当前学生的求职意向（没有则返回 null） */
    @GetMapping("/intention")
    public Result<JobIntention> getIntention() {
        return Result.success(jobIntentionService.getByStudent(UserContext.getUserId()));
    }

    /** 保存或更新求职意向（一个学生一条） */
    @PostMapping("/intention")
    public Result<Void> saveIntention(@RequestBody JobIntention intention) {
        jobIntentionService.saveOrUpdateByStudent(UserContext.getUserId(), intention);
        return Result.success("求职意向保存成功", null);
    }
}
