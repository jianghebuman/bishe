package com.campus.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.common.PageResult;
import com.campus.common.RequireRole;
import com.campus.common.Result;
import com.campus.entity.CampusTalk;
import com.campus.entity.JobFair;
import com.campus.service.CampusTalkService;
import com.campus.service.JobFairService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 管理员-宣讲会 / 招聘会管理
 *
 * @author campus
 */
@RestController
@RequestMapping("/admin")
@RequireRole("ADMIN")
public class ActivityController {

    @Autowired
    private CampusTalkService campusTalkService;
    @Autowired
    private JobFairService jobFairService;

    // ==================== 宣讲会 ====================

    @GetMapping("/talk")
    public Result<PageResult<CampusTalk>> talkPage(@RequestParam(defaultValue = "1") Integer pageNum,
                                                   @RequestParam(defaultValue = "10") Integer pageSize,
                                                   @RequestParam(required = false) String title) {
        Page<CampusTalk> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<CampusTalk> wrapper = new LambdaQueryWrapper<CampusTalk>()
                .like(title != null && !title.isEmpty(), CampusTalk::getTitle, title)
                .orderByDesc(CampusTalk::getCreateTime);
        campusTalkService.page(page, wrapper);
        return Result.success(PageResult.of(page.getTotal(), page.getRecords()));
    }

    @PostMapping("/talk")
    public Result<Void> saveTalk(@RequestBody CampusTalk talk) {
        if (talk.getId() == null) {
            if (talk.getStatus() == null) talk.setStatus(1);
            if (talk.getSignCount() == null) talk.setSignCount(0);
            campusTalkService.save(talk);
        } else {
            campusTalkService.updateById(talk);
        }
        return Result.success("保存成功", null);
    }

    @DeleteMapping("/talk/{id}")
    public Result<Void> delTalk(@PathVariable Long id) {
        campusTalkService.removeById(id);
        return Result.success("删除成功", null);
    }

    // ==================== 招聘会 ====================

    @GetMapping("/fair")
    public Result<PageResult<JobFair>> fairPage(@RequestParam(defaultValue = "1") Integer pageNum,
                                                @RequestParam(defaultValue = "10") Integer pageSize,
                                                @RequestParam(required = false) String title) {
        Page<JobFair> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<JobFair> wrapper = new LambdaQueryWrapper<JobFair>()
                .like(title != null && !title.isEmpty(), JobFair::getTitle, title)
                .orderByDesc(JobFair::getCreateTime);
        jobFairService.page(page, wrapper);
        return Result.success(PageResult.of(page.getTotal(), page.getRecords()));
    }

    @PostMapping("/fair")
    public Result<Void> saveFair(@RequestBody JobFair fair) {
        if (fair.getId() == null) {
            if (fair.getStatus() == null) fair.setStatus(1);
            if (fair.getSignCount() == null) fair.setSignCount(0);
            jobFairService.save(fair);
        } else {
            jobFairService.updateById(fair);
        }
        return Result.success("保存成功", null);
    }

    @DeleteMapping("/fair/{id}")
    public Result<Void> delFair(@PathVariable Long id) {
        jobFairService.removeById(id);
        return Result.success("删除成功", null);
    }
}
