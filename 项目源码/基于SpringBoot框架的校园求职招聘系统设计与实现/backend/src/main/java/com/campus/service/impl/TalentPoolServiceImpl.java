package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.common.BusinessException;
import com.campus.common.PageResult;
import com.campus.common.UserContext;
import com.campus.entity.Resume;
import com.campus.entity.TalentPool;
import com.campus.mapper.ResumeMapper;
import com.campus.mapper.TalentPoolMapper;
import com.campus.service.TalentPoolService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * 人才库服务实现（企业HR端）
 *
 * @author campus
 */
@Service
public class TalentPoolServiceImpl extends ServiceImpl<TalentPoolMapper, TalentPool> implements TalentPoolService {

    @Autowired
    private ResumeMapper resumeMapper;

    @Override
    public void addTalent(Long studentId, Long resumeId, String tag, String remark) {
        Long enterpriseId = UserContext.getUserId();
        if (studentId == null) {
            throw new BusinessException("缺少候选人ID");
        }
        // 同一企业对同一学生只收藏一次
        Long count = this.count(new LambdaQueryWrapper<TalentPool>()
                .eq(TalentPool::getEnterpriseId, enterpriseId)
                .eq(TalentPool::getStudentId, studentId));
        if (count != null && count > 0) {
            throw new BusinessException("该候选人已在人才库中");
        }
        TalentPool talent = new TalentPool();
        talent.setEnterpriseId(enterpriseId);
        talent.setStudentId(studentId);
        talent.setResumeId(resumeId);
        talent.setTag(tag);
        talent.setRemark(remark);
        this.save(talent);
    }

    @Override
    public void removeTalent(Long talentId) {
        Long enterpriseId = UserContext.getUserId();
        TalentPool db = this.getById(talentId);
        if (db == null || !enterpriseId.equals(db.getEnterpriseId())) {
            throw new BusinessException("人才库记录不存在或无权操作");
        }
        this.removeById(talentId);
    }

    @Override
    public PageResult<TalentPool> talentPage(Integer pageNum, Integer pageSize, String tag, String keyword) {
        Long enterpriseId = UserContext.getUserId();
        Page<TalentPool> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<TalentPool> wrapper = new LambdaQueryWrapper<TalentPool>()
                .eq(TalentPool::getEnterpriseId, enterpriseId)
                .like(tag != null && !tag.trim().isEmpty(), TalentPool::getTag, tag)
                .like(keyword != null && !keyword.trim().isEmpty(), TalentPool::getRemark, keyword)
                .orderByDesc(TalentPool::getCreateTime);
        this.page(page, wrapper);
        return PageResult.of(page.getTotal(), page.getRecords());
    }

    @Override
    public PageResult<Resume> searchResume(Integer pageNum, Integer pageSize, String major, String education, String keyword) {
        Page<Resume> page = new Page<>(pageNum, pageSize);
        // 仅检索公开简历
        LambdaQueryWrapper<Resume> wrapper = new LambdaQueryWrapper<Resume>()
                .eq(Resume::getIsPublic, 1)
                .like(major != null && !major.trim().isEmpty(), Resume::getMajor, major)
                .eq(education != null && !education.trim().isEmpty(), Resume::getEducation, education);
        if (keyword != null && !keyword.trim().isEmpty()) {
            wrapper.and(w -> w.like(Resume::getName, keyword)
                    .or().like(Resume::getCollege, keyword)
                    .or().like(Resume::getSkillCert, keyword)
                    .or().like(Resume::getSelfEval, keyword));
        }
        wrapper.orderByDesc(Resume::getUpdateTime);
        resumeMapper.selectPage(page, wrapper);
        return PageResult.of(page.getTotal(), page.getRecords());
    }
}
