package com.campus.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.entity.Announcement;
import com.campus.mapper.AnnouncementMapper;
import com.campus.service.AnnouncementService;
import org.springframework.stereotype.Service;

/**
 * 公告资讯服务实现
 *
 * @author campus
 */
@Service
public class AnnouncementServiceImpl extends ServiceImpl<AnnouncementMapper, Announcement> implements AnnouncementService {

    @Override
    public Announcement detailAndIncrView(Long id) {
        Announcement ann = this.getById(id);
        if (ann != null) {
            Announcement update = new Announcement();
            update.setId(id);
            update.setViewCount((ann.getViewCount() == null ? 0 : ann.getViewCount()) + 1);
            this.updateById(update);
            ann.setViewCount(update.getViewCount());
        }
        return ann;
    }
}
