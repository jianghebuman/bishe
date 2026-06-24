package com.campus.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.entity.Banner;

import java.util.List;

/**
 * 轮播图服务
 *
 * @author campus
 */
public interface BannerService extends IService<Banner> {

    /** 前台展示的轮播图（status=1，按 sort 升序） */
    List<Banner> listShow();
}
