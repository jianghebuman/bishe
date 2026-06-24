package com.campus.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.common.PageResult;
import com.campus.entity.FavoriteJob;

/**
 * 职位收藏服务
 *
 * @author campus
 */
public interface FavoriteJobService extends IService<FavoriteJob> {

    /** 收藏职位（已收藏则忽略） */
    void addFavorite(Long studentId, Long jobId);

    /** 取消收藏 */
    void cancelFavorite(Long studentId, Long jobId);

    /** 是否已收藏 */
    boolean isFavorite(Long studentId, Long jobId);

    /** 我的收藏分页（带职位信息） */
    PageResult<?> pageMyFavorite(Long studentId, Integer pageNum, Integer pageSize);
}
