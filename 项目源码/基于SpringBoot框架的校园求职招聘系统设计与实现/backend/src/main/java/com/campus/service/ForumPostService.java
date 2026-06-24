package com.campus.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.entity.ForumPost;

/**
 * 论坛帖子服务
 *
 * @author campus
 */
public interface ForumPostService extends IService<ForumPost> {

    /** 查看详情并自增浏览量 */
    ForumPost detailAndIncrView(Long id);
}
