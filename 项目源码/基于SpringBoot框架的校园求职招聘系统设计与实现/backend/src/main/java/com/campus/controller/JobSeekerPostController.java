package com.campus.controller;

import com.campus.common.PageResult;
import com.campus.common.RequireRole;
import com.campus.common.Result;
import com.campus.entity.JobSeekerPost;
import com.campus.entity.Student;
import com.campus.service.JobSeekerPostService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class JobSeekerPostController {

    @Autowired
    private JobSeekerPostService jobSeekerPostService;

    @GetMapping("/public/seeker-posts")
    public Result<PageResult<Map<String, Object>>> publicPage(@RequestParam(defaultValue = "1") Integer pageNum,
                                                              @RequestParam(defaultValue = "10") Integer pageSize,
                                                              @RequestParam(required = false) String keyword,
                                                              @RequestParam(required = false) String city,
                                                              @RequestParam(required = false) String expectPost,
                                                              @RequestParam(required = false) String college,
                                                              @RequestParam(required = false) Integer salaryMin) {
        return Result.success(jobSeekerPostService.publicPage(pageNum, pageSize, keyword, city, expectPost, college, salaryMin));
    }

    @GetMapping("/public/seeker-posts/{id}")
    public Result<Map<String, Object>> publicDetail(@PathVariable Long id) {
        return Result.success(jobSeekerPostService.publicDetail(id));
    }

    @GetMapping("/enterprise/seeker-posts/{id}/student")
    @RequireRole("ENTERPRISE")
    public Result<Student> studentInfo(@PathVariable Long id) {
        return Result.success(jobSeekerPostService.studentInfoForEnterprise(id));
    }

    @GetMapping("/student/seeker-post")
    @RequireRole("STUDENT")
    public Result<JobSeekerPost> mine() {
        return Result.success(jobSeekerPostService.myPost());
    }

    @PostMapping("/student/seeker-post")
    @RequireRole("STUDENT")
    public Result<Long> saveMine(@RequestBody JobSeekerPost post) {
        return Result.success("求职信息已保存", jobSeekerPostService.saveMine(post));
    }

    @PutMapping("/student/seeker-post/status")
    @RequireRole("STUDENT")
    public Result<Void> status(@RequestParam Integer status) {
        jobSeekerPostService.changeMineStatus(status);
        return Result.success(status == 1 ? "已上架" : "已下架", null);
    }

    @GetMapping("/admin/seeker-posts")
    @RequireRole("ADMIN")
    public Result<PageResult<Map<String, Object>>> adminPage(@RequestParam(defaultValue = "1") Integer pageNum,
                                                             @RequestParam(defaultValue = "10") Integer pageSize,
                                                             @RequestParam(required = false) String title,
                                                             @RequestParam(required = false) Long studentId,
                                                             @RequestParam(required = false) Integer status) {
        return Result.success(jobSeekerPostService.adminPage(pageNum, pageSize, title, studentId, status));
    }

    @DeleteMapping("/admin/seeker-posts/{id}")
    @RequireRole("ADMIN")
    public Result<Void> delete(@PathVariable Long id) {
        jobSeekerPostService.removeById(id);
        return Result.success("删除成功", null);
    }
}
