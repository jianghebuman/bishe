package com.campus.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.common.PageResult;
import com.campus.entity.FavoriteEnterprise;

/**
 * 企业收藏服务
 *
 * @author campus
 */
public interface FavoriteEnterpriseService extends IService<FavoriteEnterprise> {

    /** 收藏企业（已收藏则忽略） */
    void addFavorite(Long studentId, Long enterpriseId);

    /** 取消收藏 */
    void cancelFavorite(Long studentId, Long enterpriseId);

    /** 是否已收藏 */
    boolean isFavorite(Long studentId, Long enterpriseId);

    /** 我的企业收藏分页（带企业信息） */
    PageResult<?> pageMyFavorite(Long studentId, Integer pageNum, Integer pageSize);
}
