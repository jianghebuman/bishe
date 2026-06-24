package com.campus.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.entity.ForumPost;
import com.campus.mapper.ForumPostMapper;
import com.campus.service.ForumPostService;
import org.springframework.stereotype.Service;

/**
 * 论坛帖子服务实现
 *
 * @author campus
 */
@Service
public class ForumPostServiceImpl extends ServiceImpl<ForumPostMapper, ForumPost> implements ForumPostService {

    @Override
    public ForumPost detailAndIncrView(Long id) {
        ForumPost post = this.getById(id);
        if (post != null) {
            ForumPost update = new ForumPost();
            update.setId(id);
            update.setViewCount((post.getViewCount() == null ? 0 : post.getViewCount()) + 1);
            this.updateById(update);
            post.setViewCount(update.getViewCount());
        }
        return post;
    }
}
