package com.campus.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.entity.CampusTalk;
import com.campus.mapper.CampusTalkMapper;
import com.campus.service.CampusTalkService;
import org.springframework.stereotype.Service;

/**
 * 校园宣讲会服务实现
 *
 * @author campus
 */
@Service
public class CampusTalkServiceImpl extends ServiceImpl<CampusTalkMapper, CampusTalk> implements CampusTalkService {
}
