package com.campus.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.campus.entity.JobPost;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface JobPostMapper extends BaseMapper<JobPost> {

    @Select({
            "SELECT COALESCE(c.name, '其他') AS name, COUNT(*) AS value",
            "FROM job_post j",
            "LEFT JOIN job_category c ON c.id = j.category_id AND c.deleted = 0",
            "WHERE j.deleted = 0",
            "GROUP BY COALESCE(c.name, '其他')",
            "ORDER BY value DESC"
    })
    List<Map<String, Object>> countJobsByCategory();

    @Select({
            "SELECT COALESCE(e.company_name, CONCAT('企业', j.enterprise_id), '企业未知') AS name, COUNT(*) AS value",
            "FROM job_post j",
            "LEFT JOIN enterprise e ON e.id = j.enterprise_id AND e.deleted = 0",
            "WHERE j.deleted = 0",
            "GROUP BY j.enterprise_id, e.company_name",
            "ORDER BY value DESC",
            "LIMIT 10"
    })
    List<Map<String, Object>> countTopEnterpriseActivity();
}
