package com.campus.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.campus.common.RequireRole;
import com.campus.common.Result;
import com.campus.entity.Banner;
import com.campus.service.BannerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 管理员-轮播图管理
 *
 * @author campus
 */
@RestController
@RequestMapping("/admin/banner")
@RequireRole("ADMIN")
public class BannerController {

    @Autowired
    private BannerService bannerService;

    @GetMapping
    public Result<List<Banner>> list() {
        return Result.success(bannerService.list(
                new LambdaQueryWrapper<Banner>().orderByAsc(Banner::getSort)));
    }

    @PostMapping
    public Result<Void> save(@RequestBody Banner banner) {
        if (banner.getId() == null) {
            if (banner.getStatus() == null) {
                banner.setStatus(1);
            }
            bannerService.save(banner);
        } else {
            bannerService.updateById(banner);
        }
        return Result.success("保存成功", null);
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        bannerService.removeById(id);
        return Result.success("删除成功", null);
    }
}
