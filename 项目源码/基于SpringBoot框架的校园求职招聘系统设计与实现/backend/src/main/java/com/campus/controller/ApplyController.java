package com.campus.controller;

import com.campus.common.PageResult;
import com.campus.common.RequireRole;
import com.campus.common.Result;
import com.campus.common.UserContext;
import com.campus.service.FavoriteEnterpriseService;
import com.campus.service.FavoriteJobService;
import com.campus.service.JobApplyService;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 学生端：职位收藏与投递
 *
 * @author campus
 */
@RestController
@RequestMapping("/student")
@RequireRole("STUDENT")
public class ApplyController {

    @Autowired
    private FavoriteJobService favoriteJobService;

    @Autowired
    private FavoriteEnterpriseService favoriteEnterpriseService;

    @Autowired
    private JobApplyService jobApplyService;

    // ===== 收藏 =====

    /** 我的收藏分页 */
    @GetMapping("/favorite")
    public Result<PageResult<?>> myFavorite(@RequestParam(defaultValue = "1") Integer pageNum,
                                            @RequestParam(defaultValue = "10") Integer pageSize) {
        return Result.success(favoriteJobService.pageMyFavorite(UserContext.getUserId(), pageNum, pageSize));
    }

    /** 收藏职位 */
    @PostMapping("/favorite/{jobId}")
    public Result<Void> addFavorite(@PathVariable Long jobId) {
        favoriteJobService.addFavorite(UserContext.getUserId(), jobId);
        return Result.success("收藏成功", null);
    }

    /** 取消收藏 */
    @DeleteMapping("/favorite/{jobId}")
    public Result<Void> cancelFavorite(@PathVariable Long jobId) {
        favoriteJobService.cancelFavorite(UserContext.getUserId(), jobId);
        return Result.success("已取消收藏", null);
    }

    /** 是否已收藏 */
    @GetMapping("/favorite/check/{jobId}")
    public Result<Map<String, Object>> checkFavorite(@PathVariable Long jobId) {
        boolean favorite = favoriteJobService.isFavorite(UserContext.getUserId(), jobId);
        Map<String, Object> data = new HashMap<>(1);
        data.put("favorite", favorite);
        return Result.success(data);
    }

    /** 我的企业收藏分页 */
    @GetMapping("/favorite/enterprise")
    public Result<PageResult<?>> myEnterpriseFavorite(@RequestParam(defaultValue = "1") Integer pageNum,
                                                      @RequestParam(defaultValue = "10") Integer pageSize) {
        return Result.success(favoriteEnterpriseService.pageMyFavorite(UserContext.getUserId(), pageNum, pageSize));
    }

    /** 收藏企业 */
    @PostMapping("/favorite/enterprise/{enterpriseId}")
    public Result<Void> addEnterpriseFavorite(@PathVariable Long enterpriseId) {
        favoriteEnterpriseService.addFavorite(UserContext.getUserId(), enterpriseId);
        return Result.success("收藏成功", null);
    }

    /** 取消收藏企业 */
    @DeleteMapping("/favorite/enterprise/{enterpriseId}")
    public Result<Void> cancelEnterpriseFavorite(@PathVariable Long enterpriseId) {
        favoriteEnterpriseService.cancelFavorite(UserContext.getUserId(), enterpriseId);
        return Result.success("已取消收藏", null);
    }

    /** 企业是否已收藏 */
    @GetMapping("/favorite/enterprise/check/{enterpriseId}")
    public Result<Map<String, Object>> checkEnterpriseFavorite(@PathVariable Long enterpriseId) {
        boolean favorite = favoriteEnterpriseService.isFavorite(UserContext.getUserId(), enterpriseId);
        Map<String, Object> data = new HashMap<>(1);
        data.put("favorite", favorite);
        return Result.success(data);
    }

    // ===== 投递 =====

    /** 投递职位 */
    @PostMapping("/apply")
    public Result<Void> apply(@RequestBody ApplyRequest req) {
        jobApplyService.apply(UserContext.getUserId(), req.getJobId(), req.getResumeId(), req.getApplyRemark());
        return Result.success("投递成功", null);
    }

    /** 我的投递分页（可选 status 筛选） */
    @GetMapping("/apply")
    public Result<PageResult<?>> myApply(@RequestParam(defaultValue = "1") Integer pageNum,
                                         @RequestParam(defaultValue = "10") Integer pageSize,
                                         @RequestParam(required = false) Integer status) {
        return Result.success(jobApplyService.pageMyApply(UserContext.getUserId(), pageNum, pageSize, status));
    }

    /** 撤回投递 */
    @DeleteMapping("/apply/{id}")
    public Result<Void> withdraw(@PathVariable Long id) {
        jobApplyService.withdraw(UserContext.getUserId(), id);
        return Result.success("已撤回投递", null);
    }

    /** 投递请求体 */
    @Data
    public static class ApplyRequest {
        /** 职位ID */
        private Long jobId;
        /** 投递所用简历ID */
        private Long resumeId;
        /** 投递备注 */
        private String applyRemark;
    }
}
