package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.entity.Banner;
import com.campus.mapper.BannerMapper;
import com.campus.service.BannerService;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 轮播图服务实现
 *
 * @author campus
 */
@Service
public class BannerServiceImpl extends ServiceImpl<BannerMapper, Banner> implements BannerService {

    @Override
    public List<Banner> listShow() {
        return this.list(new LambdaQueryWrapper<Banner>()
                .eq(Banner::getStatus, 1)
                .orderByAsc(Banner::getSort));
    }
}
