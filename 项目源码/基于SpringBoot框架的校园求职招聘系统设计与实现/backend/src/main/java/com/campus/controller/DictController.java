package com.campus.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.common.PageResult;
import com.campus.common.RequireRole;
import com.campus.common.Result;
import com.campus.entity.SysDict;
import com.campus.service.SysDictService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 管理员-数据字典管理
 *
 * @author campus
 */
@RestController
@RequestMapping("/admin/dict")
@RequireRole("ADMIN")
public class DictController {

    @Autowired
    private SysDictService sysDictService;

    @GetMapping
    public Result<PageResult<SysDict>> page(@RequestParam(defaultValue = "1") Integer pageNum,
                                            @RequestParam(defaultValue = "10") Integer pageSize,
                                            @RequestParam(required = false) String dictType) {
        Page<SysDict> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<SysDict> wrapper = new LambdaQueryWrapper<SysDict>()
                .eq(dictType != null && !dictType.isEmpty(), SysDict::getDictType, dictType)
                .orderByAsc(SysDict::getDictType).orderByAsc(SysDict::getSort);
        sysDictService.page(page, wrapper);
        return Result.success(PageResult.of(page.getTotal(), page.getRecords()));
    }

    @PostMapping
    public Result<Void> save(@RequestBody SysDict dict) {
        sysDictService.save(dict);
        return Result.success("新增成功", null);
    }

    @PutMapping
    public Result<Void> update(@RequestBody SysDict dict) {
        sysDictService.updateById(dict);
        return Result.success("修改成功", null);
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        sysDictService.removeById(id);
        return Result.success("删除成功", null);
    }
}
