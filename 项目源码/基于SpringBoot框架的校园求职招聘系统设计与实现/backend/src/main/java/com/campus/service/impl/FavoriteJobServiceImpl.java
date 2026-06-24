package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.common.PageResult;
import com.campus.entity.FavoriteJob;
import com.campus.entity.JobPost;
import com.campus.mapper.FavoriteJobMapper;
import com.campus.mapper.JobPostMapper;
import com.campus.service.FavoriteJobService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 职位收藏服务实现
 *
 * @author campus
 */
@Service
public class FavoriteJobServiceImpl extends ServiceImpl<FavoriteJobMapper, FavoriteJob>
        implements FavoriteJobService {

    @Autowired
    private JobPostMapper jobPostMapper;

    @Override
    public void addFavorite(Long studentId, Long jobId) {
        // 已收藏则忽略，保证 studentId+jobId 唯一
        if (isFavorite(studentId, jobId)) {
            return;
        }
        FavoriteJob favorite = new FavoriteJob();
        favorite.setStudentId(studentId);
        favorite.setJobId(jobId);
        this.save(favorite);
    }

    @Override
    public void cancelFavorite(Long studentId, Long jobId) {
        this.remove(new LambdaQueryWrapper<FavoriteJob>()
                .eq(FavoriteJob::getStudentId, studentId)
                .eq(FavoriteJob::getJobId, jobId));
    }

    @Override
    public boolean isFavorite(Long studentId, Long jobId) {
        return this.count(new LambdaQueryWrapper<FavoriteJob>()
                .eq(FavoriteJob::getStudentId, studentId)
                .eq(FavoriteJob::getJobId, jobId)) > 0;
    }

    @Override
    public PageResult<?> pageMyFavorite(Long studentId, Integer pageNum, Integer pageSize) {
        Page<FavoriteJob> page = new Page<>(pageNum, pageSize);
        Page<FavoriteJob> result = this.page(page, new LambdaQueryWrapper<FavoriteJob>()
                .eq(FavoriteJob::getStudentId, studentId)
                .orderByDesc(FavoriteJob::getCreateTime));

        List<FavoriteJob> records = result.getRecords();
        if (records.isEmpty()) {
            return PageResult.of(result.getTotal(), new ArrayList<>());
        }
        // 批量查出关联职位，填充到结果中
        List<Long> jobIds = records.stream().map(FavoriteJob::getJobId).collect(Collectors.toList());
        Map<Long, JobPost> jobMap = jobPostMapper.selectBatchIds(jobIds).stream()
                .collect(Collectors.toMap(JobPost::getId, j -> j, (a, b) -> a));

        List<Map<String, Object>> list = new ArrayList<>();
        for (FavoriteJob fav : records) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("id", fav.getId());
            item.put("jobId", fav.getJobId());
            item.put("createTime", fav.getCreateTime());
            item.put("job", jobMap.get(fav.getJobId()));
            list.add(item);
        }
        return PageResult.of(result.getTotal(), list);
    }
}
