package com.campus.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.entity.NewsCategory;
import com.campus.mapper.NewsCategoryMapper;
import com.campus.service.NewsCategoryService;
import org.springframework.stereotype.Service;

/**
 * 资讯分类服务实现
 *
 * @author campus
 */
@Service
public class NewsCategoryServiceImpl extends ServiceImpl<NewsCategoryMapper, NewsCategory> implements NewsCategoryService {
}
