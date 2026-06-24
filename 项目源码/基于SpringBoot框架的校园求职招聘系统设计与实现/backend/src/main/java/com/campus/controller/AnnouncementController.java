package com.campus.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.common.PageResult;
import com.campus.common.RequireRole;
import com.campus.common.Result;
import com.campus.entity.Announcement;
import com.campus.service.AnnouncementService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Date;

/**
 * 管理员-公告资讯管理
 *
 * @author campus
 */
@RestController
@RequestMapping("/admin/announcement")
@RequireRole("ADMIN")
public class AnnouncementController {

    @Autowired
    private AnnouncementService announcementService;

    @GetMapping
    public Result<PageResult<Announcement>> page(@RequestParam(defaultValue = "1") Integer pageNum,
                                                 @RequestParam(defaultValue = "10") Integer pageSize,
                                                 @RequestParam(required = false) Long categoryId,
                                                 @RequestParam(required = false) String title) {
        Page<Announcement> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<Announcement> wrapper = new LambdaQueryWrapper<Announcement>()
                .eq(categoryId != null, Announcement::getCategoryId, categoryId)
                .like(title != null && !title.isEmpty(), Announcement::getTitle, title)
                .orderByDesc(Announcement::getCreateTime);
        announcementService.page(page, wrapper);
        return Result.success(PageResult.of(page.getTotal(), page.getRecords()));
    }

    @PostMapping
    public Result<Void> save(@RequestBody Announcement ann) {
        if (ann.getStatus() == null) {
            ann.setStatus(1);
        }
        if (ann.getViewCount() == null) {
            ann.setViewCount(0);
        }
        ann.setPublishTime(new Date());
        announcementService.save(ann);
        return Result.success("发布成功", null);
    }

    @PutMapping
    public Result<Void> update(@RequestBody Announcement ann) {
        announcementService.updateById(ann);
        return Result.success("修改成功", null);
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        announcementService.removeById(id);
        return Result.success("删除成功", null);
    }
}
