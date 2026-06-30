package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.common.PageResult;
import com.campus.entity.Enterprise;
import com.campus.entity.FavoriteEnterprise;
import com.campus.mapper.EnterpriseMapper;
import com.campus.mapper.FavoriteEnterpriseMapper;
import com.campus.service.FavoriteEnterpriseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 企业收藏服务实现
 *
 * @author campus
 */
@Service
public class FavoriteEnterpriseServiceImpl extends ServiceImpl<FavoriteEnterpriseMapper, FavoriteEnterprise>
        implements FavoriteEnterpriseService {

    @Autowired
    private EnterpriseMapper enterpriseMapper;

    @Override
    public void addFavorite(Long studentId, Long enterpriseId) {
        if (isFavorite(studentId, enterpriseId)) {
            return;
        }
        FavoriteEnterprise favorite = new FavoriteEnterprise();
        favorite.setStudentId(studentId);
        favorite.setEnterpriseId(enterpriseId);
        this.save(favorite);
    }

    @Override
    public void cancelFavorite(Long studentId, Long enterpriseId) {
        this.remove(new LambdaQueryWrapper<FavoriteEnterprise>()
                .eq(FavoriteEnterprise::getStudentId, studentId)
                .eq(FavoriteEnterprise::getEnterpriseId, enterpriseId));
    }

    @Override
    public boolean isFavorite(Long studentId, Long enterpriseId) {
        return this.count(new LambdaQueryWrapper<FavoriteEnterprise>()
                .eq(FavoriteEnterprise::getStudentId, studentId)
                .eq(FavoriteEnterprise::getEnterpriseId, enterpriseId)) > 0;
    }

    @Override
    public PageResult<?> pageMyFavorite(Long studentId, Integer pageNum, Integer pageSize) {
        Page<FavoriteEnterprise> page = new Page<>(pageNum, pageSize);
        Page<FavoriteEnterprise> result = this.page(page, new LambdaQueryWrapper<FavoriteEnterprise>()
                .eq(FavoriteEnterprise::getStudentId, studentId)
                .orderByDesc(FavoriteEnterprise::getCreateTime));

        List<FavoriteEnterprise> records = result.getRecords();
        if (records.isEmpty()) {
            return PageResult.of(result.getTotal(), new ArrayList<>());
        }

        List<Long> enterpriseIds = records.stream()
                .map(FavoriteEnterprise::getEnterpriseId)
                .collect(Collectors.toList());
        Map<Long, Enterprise> enterpriseMap = enterpriseMapper.selectBatchIds(enterpriseIds).stream()
                .collect(Collectors.toMap(Enterprise::getId, e -> e, (a, b) -> a));

        List<Map<String, Object>> list = new ArrayList<>();
        for (FavoriteEnterprise fav : records) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("id", fav.getId());
            item.put("enterpriseId", fav.getEnterpriseId());
            item.put("createTime", fav.getCreateTime());
            item.put("enterprise", enterpriseMap.get(fav.getEnterpriseId()));
            list.add(item);
        }
        return PageResult.of(result.getTotal(), list);
    }
}
