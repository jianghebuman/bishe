package com.campus.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.campus.entity.JobApply;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface JobApplyMapper extends BaseMapper<JobApply> {

    @Select({
            "SELECT COALESCE(NULLIF(s.major, ''), '未知') AS name, COUNT(*) AS value",
            "FROM job_apply a",
            "LEFT JOIN student s ON s.id = a.student_id AND s.deleted = 0",
            "WHERE a.deleted = 0",
            "GROUP BY COALESCE(NULLIF(s.major, ''), '未知')",
            "ORDER BY value DESC"
    })
    List<Map<String, Object>> countApplyByMajor();

    @Select({
            "SELECT status, COUNT(*) AS value",
            "FROM job_apply",
            "WHERE deleted = 0 AND status IS NOT NULL",
            "GROUP BY status"
    })
    List<Map<String, Object>> countApplyByStatus();
}
