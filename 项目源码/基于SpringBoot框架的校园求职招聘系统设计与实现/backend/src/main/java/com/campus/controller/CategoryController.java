package com.campus.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.campus.common.RequireRole;
import com.campus.common.Result;
import com.campus.entity.JobCategory;
import com.campus.service.impl.JobCategoryServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 管理员-岗位类别管理
 *
 * @author campus
 */
@RestController
@RequestMapping("/admin/category")
@RequireRole("ADMIN")
public class CategoryController {

    @Autowired
    private JobCategoryServiceImpl jobCategoryService;

    @GetMapping
    public Result<List<JobCategory>> list() {
        return Result.success(jobCategoryService.list(
                new LambdaQueryWrapper<JobCategory>().orderByAsc(JobCategory::getSort)));
    }

    @PostMapping
    public Result<Void> save(@RequestBody JobCategory category) {
        if (category.getId() == null) {
            jobCategoryService.save(category);
        } else {
            jobCategoryService.updateById(category);
        }
        return Result.success("保存成功", null);
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        jobCategoryService.removeById(id);
        return Result.success("删除成功", null);
    }
}
