package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.entity.SysDict;
import com.campus.mapper.SysDictMapper;
import com.campus.service.SysDictService;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 数据字典服务实现
 *
 * @author campus
 */
@Service
public class SysDictServiceImpl extends ServiceImpl<SysDictMapper, SysDict> implements SysDictService {

    @Override
    public List<SysDict> listByType(String dictType) {
        return this.list(new LambdaQueryWrapper<SysDict>()
                .eq(SysDict::getDictType, dictType)
                .orderByAsc(SysDict::getSort));
    }
}
