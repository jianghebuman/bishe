package com.campus.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.common.PageResult;
import com.campus.common.RequireRole;
import com.campus.common.Result;
import com.campus.common.UserContext;
import com.campus.entity.ForumComment;
import com.campus.entity.ForumPost;
import com.campus.entity.Student;
import com.campus.mapper.ForumCommentMapper;
import com.campus.mapper.ForumPostMapper;
import com.campus.mapper.StudentMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * 学生社区论坛接口：仅学生可发帖、评论、点赞、管理自己的帖子。
 *
 * @author campus
 */
@RestController
@RequestMapping("/forum")
@RequireRole("STUDENT")
public class ForumController {

    @Autowired
    private ForumPostMapper forumPostMapper;

    @Autowired
    private ForumCommentMapper forumCommentMapper;

    @Autowired
    private StudentMapper studentMapper;

    /** 发帖：归属当前学生，作者名取学生真实姓名，审核状态默认 1（通过） */
    @PostMapping("/posts")
    public Result<Void> publish(@RequestBody ForumPost dto) {
        if (dto.getTitle() == null || dto.getTitle().trim().isEmpty()) {
            return Result.error("帖子标题不能为空");
        }
        if (dto.getContent() == null || dto.getContent().trim().isEmpty()) {
            return Result.error("帖子内容不能为空");
        }
        Long studentId = UserContext.getUserId();
        Student student = studentMapper.selectById(studentId);
        String authorName = student != null ? student.getRealName() : UserContext.getUsername();

        ForumPost post = new ForumPost();
        post.setStudentId(studentId);
        post.setAuthorName(authorName);
        post.setTitle(dto.getTitle());
        post.setContent(dto.getContent());
        post.setCategory(dto.getCategory());
        post.setViewCount(0);
        post.setLikeCount(0);
        post.setCommentCount(0);
        // 审核状态默认 1（通过），状态正常
        post.setAuditStatus(1);
        post.setStatus(1);
        forumPostMapper.insert(post);
        return Result.success("发帖成功", null);
    }

    /** 删除自己的帖子 */
    @PostMapping("/posts/{id}/delete")
    public Result<Void> deletePost(@PathVariable Long id) {
        ForumPost post = forumPostMapper.selectById(id);
        if (post == null) {
            return Result.error("帖子不存在");
        }
        if (!UserContext.getUserId().equals(post.getStudentId())) {
            return Result.error("无权删除他人帖子");
        }
        forumPostMapper.deleteById(id);
        return Result.success("删除成功", null);
    }

    /** 发表评论：归属当前学生，作者名取学生真实姓名，并使帖子评论数 +1 */
    @PostMapping("/posts/{id}/comments")
    public Result<Void> comment(@PathVariable Long id, @RequestBody ForumComment dto) {
        if (dto.getContent() == null || dto.getContent().trim().isEmpty()) {
            return Result.error("评论内容不能为空");
        }
        ForumPost post = forumPostMapper.selectById(id);
        if (post == null) {
            return Result.error("帖子不存在");
        }
        Long studentId = UserContext.getUserId();
        Student student = studentMapper.selectById(studentId);
        String authorName = student != null ? student.getRealName() : UserContext.getUsername();

        ForumComment comment = new ForumComment();
        comment.setPostId(id);
        comment.setStudentId(studentId);
        comment.setAuthorName(authorName);
        comment.setContent(dto.getContent());
        comment.setLikeCount(0);
        comment.setStatus(1);
        forumCommentMapper.insert(comment);

        // 帖子评论数 +1
        ForumPost update = new ForumPost();
        update.setId(id);
        update.setCommentCount((post.getCommentCount() == null ? 0 : post.getCommentCount()) + 1);
        forumPostMapper.updateById(update);

        return Result.success("评论成功", null);
    }

    /** 点赞帖子：点赞数 +1 */
    @PostMapping("/posts/{id}/like")
    public Result<Void> like(@PathVariable Long id) {
        ForumPost post = forumPostMapper.selectById(id);
        if (post == null) {
            return Result.error("帖子不存在");
        }
        ForumPost update = new ForumPost();
        update.setId(id);
        update.setLikeCount((post.getLikeCount() == null ? 0 : post.getLikeCount()) + 1);
        forumPostMapper.updateById(update);
        return Result.success("点赞成功", null);
    }

    /** 我的帖子列表（分页） */
    @GetMapping("/my-posts")
    public Result<PageResult<ForumPost>> myPosts(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        LambdaQueryWrapper<ForumPost> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ForumPost::getStudentId, UserContext.getUserId())
                .orderByDesc(ForumPost::getCreateTime);
        Page<ForumPost> page = forumPostMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
        return Result.success(PageResult.of(page.getTotal(), page.getRecords()));
    }
}
