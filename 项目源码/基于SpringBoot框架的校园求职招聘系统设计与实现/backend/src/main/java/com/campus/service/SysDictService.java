package com.campus.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.entity.SysDict;

import java.util.List;

/**
 * 数据字典服务
 *
 * @author campus
 */
public interface SysDictService extends IService<SysDict> {

    /** 按类型查询字典项 */
    List<SysDict> listByType(String dictType);
}
