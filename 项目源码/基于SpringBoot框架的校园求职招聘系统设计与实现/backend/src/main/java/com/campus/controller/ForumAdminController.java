package com.campus.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.common.PageResult;
import com.campus.common.RequireRole;
import com.campus.common.Result;
import com.campus.entity.ForumComment;
import com.campus.entity.ForumPost;
import com.campus.service.ForumCommentService;
import com.campus.service.ForumPostService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 管理员-论坛社区管理
 *
 * @author campus
 */
@RestController
@RequestMapping("/admin/forum")
@RequireRole("ADMIN")
public class ForumAdminController {

    @Autowired
    private ForumPostService forumPostService;
    @Autowired
    private ForumCommentService forumCommentService;

    @GetMapping("/posts")
    public Result<PageResult<ForumPost>> postPage(@RequestParam(defaultValue = "1") Integer pageNum,
                                                  @RequestParam(defaultValue = "10") Integer pageSize,
                                                  @RequestParam(required = false) Integer auditStatus,
                                                  @RequestParam(required = false) String title) {
        Page<ForumPost> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<ForumPost> wrapper = new LambdaQueryWrapper<ForumPost>()
                .eq(auditStatus != null, ForumPost::getAuditStatus, auditStatus)
                .like(title != null && !title.isEmpty(), ForumPost::getTitle, title)
                .orderByDesc(ForumPost::getCreateTime);
        forumPostService.page(page, wrapper);
        return Result.success(PageResult.of(page.getTotal(), page.getRecords()));
    }

    /** 审核帖子：status=1通过 2驳回 */
    @PutMapping("/posts/{id}/audit")
    public Result<Void> audit(@PathVariable Long id, @RequestParam Integer status) {
        ForumPost post = new ForumPost();
        post.setId(id);
        post.setAuditStatus(status);
        forumPostService.updateById(post);
        return Result.success(status == 1 ? "已通过" : "已驳回", null);
    }

    @DeleteMapping("/posts/{id}")
    public Result<Void> delPost(@PathVariable Long id) {
        forumPostService.removeById(id);
        return Result.success("删除成功", null);
    }

    @GetMapping("/posts/{postId}/comments")
    public Result<List<ForumComment>> comments(@PathVariable Long postId) {
        return Result.success(forumCommentService.list(
                new LambdaQueryWrapper<ForumComment>()
                        .eq(ForumComment::getPostId, postId)
                        .orderByDesc(ForumComment::getCreateTime)));
    }

    @DeleteMapping("/comments/{id}")
    public Result<Void> delComment(@PathVariable Long id) {
        forumCommentService.removeById(id);
        return Result.success("删除成功", null);
    }
}
