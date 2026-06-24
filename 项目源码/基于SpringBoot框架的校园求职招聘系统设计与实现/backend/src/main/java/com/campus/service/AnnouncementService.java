package com.campus.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.entity.Announcement;

/**
 * 公告资讯服务
 *
 * @author campus
 */
public interface AnnouncementService extends IService<Announcement> {

    /** 查看详情并自增浏览量 */
    Announcement detailAndIncrView(Long id);
}
