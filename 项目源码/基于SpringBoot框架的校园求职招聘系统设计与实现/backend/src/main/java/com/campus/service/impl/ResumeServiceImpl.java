package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.common.BusinessException;
import com.campus.entity.Resume;
import com.campus.entity.ResumeEducation;
import com.campus.entity.ResumeExperience;
import com.campus.entity.ResumeProject;
import com.campus.mapper.ResumeEducationMapper;
import com.campus.mapper.ResumeExperienceMapper;
import com.campus.mapper.ResumeMapper;
import com.campus.mapper.ResumeProjectMapper;
import com.campus.service.ResumeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;

/**
 * 简历服务实现
 *
 * @author campus
 */
@Service
public class ResumeServiceImpl extends ServiceImpl<ResumeMapper, Resume> implements ResumeService {

    @Autowired
    private ResumeEducationMapper resumeEducationMapper;

    @Autowired
    private ResumeProjectMapper resumeProjectMapper;

    @Autowired
    private ResumeExperienceMapper resumeExperienceMapper;

    @Override
    public Resume getByStudent(Long studentId) {
        return this.getOne(new LambdaQueryWrapper<Resume>()
                .eq(Resume::getStudentId, studentId)
                .last("limit 1"));
    }

    @Override
    public Long saveOrUpdateResume(Long studentId, Resume resume) {
        // 一个学生一份简历：存在则更新，否则新增
        Resume exist = getByStudent(studentId);
        resume.setStudentId(studentId);
        if (exist != null) {
            resume.setId(exist.getId());
            this.updateById(resume);
        } else {
            resume.setId(null);
            // 新建时完整度先按当前已填字段计算（仅基本信息与技能/自我评价部分）
            this.save(resume);
        }
        // 保存后重新计算完整度
        calcCompleteRate(resume.getId());
        return resume.getId();
    }

    @Override
    public Integer calcCompleteRate(Long resumeId) {
        Resume resume = this.getById(resumeId);
        if (resume == null) {
            return 0;
        }
        int rate = 0;
        // 1. 基本信息填全 +20（姓名、电话、邮箱、院校、专业、学历）
        if (StringUtils.hasText(resume.getName())
                && StringUtils.hasText(resume.getPhone())
                && StringUtils.hasText(resume.getEmail())
                && StringUtils.hasText(resume.getCollege())
                && StringUtils.hasText(resume.getMajor())
                && StringUtils.hasText(resume.getEducation())) {
            rate += 20;
        }
        // 2. 教育经历 ≥1 条 +20
        long eduCount = resumeEducationMapper.selectCount(new LambdaQueryWrapper<ResumeEducation>()
                .eq(ResumeEducation::getResumeId, resumeId));
        if (eduCount >= 1) {
            rate += 20;
        }
        // 3. 项目经历 ≥1 条 +20
        long projCount = resumeProjectMapper.selectCount(new LambdaQueryWrapper<ResumeProject>()
                .eq(ResumeProject::getResumeId, resumeId));
        if (projCount >= 1) {
            rate += 20;
        }
        // 4. 实习经历 ≥1 条 +20
        long expCount = resumeExperienceMapper.selectCount(new LambdaQueryWrapper<ResumeExperience>()
                .eq(ResumeExperience::getResumeId, resumeId));
        if (expCount >= 1) {
            rate += 20;
        }
        // 5. 技能证书 或 自我评价 +20
        if (StringUtils.hasText(resume.getSkillCert()) || StringUtils.hasText(resume.getSelfEval())) {
            rate += 20;
        }
        // 写回完整度
        Resume update = new Resume();
        update.setId(resumeId);
        update.setCompleteRate(rate);
        this.updateById(update);
        return rate;
    }

    @Override
    public Resume checkOwn(Long resumeId, Long studentId) {
        Resume resume = this.getById(resumeId);
        if (resume == null) {
            throw new BusinessException("简历不存在");
        }
        if (!resume.getStudentId().equals(studentId)) {
            throw new BusinessException("无权操作他人简历");
        }
        return resume;
    }

    // ===== 教育经历 =====

    @Override
    public List<ResumeEducation> listEducation(Long resumeId, Long studentId) {
        checkOwn(resumeId, studentId);
        return resumeEducationMapper.selectList(new LambdaQueryWrapper<ResumeEducation>()
                .eq(ResumeEducation::getResumeId, resumeId)
                .orderByAsc(ResumeEducation::getId));
    }

    @Override
    public void saveOrUpdateEducation(Long studentId, ResumeEducation education) {
        // 校验所属简历归属当前学生
        checkOwn(education.getResumeId(), studentId);
        if (education.getId() != null) {
            // 更新前确认该记录确实属于这份简历
            ResumeEducation old = resumeEducationMapper.selectById(education.getId());
            if (old == null || !old.getResumeId().equals(education.getResumeId())) {
                throw new BusinessException("教育经历不存在");
            }
            resumeEducationMapper.updateById(education);
        } else {
            resumeEducationMapper.insert(education);
        }
        // 教育经历变化会影响完整度
        calcCompleteRate(education.getResumeId());
    }

    @Override
    public void deleteEducation(Long studentId, Long id) {
        ResumeEducation edu = resumeEducationMapper.selectById(id);
        if (edu == null) {
            throw new BusinessException("教育经历不存在");
        }
        checkOwn(edu.getResumeId(), studentId);
        resumeEducationMapper.deleteById(id);
        calcCompleteRate(edu.getResumeId());
    }

    // ===== 项目经历 =====

    @Override
    public List<ResumeProject> listProject(Long resumeId, Long studentId) {
        checkOwn(resumeId, studentId);
        return resumeProjectMapper.selectList(new LambdaQueryWrapper<ResumeProject>()
                .eq(ResumeProject::getResumeId, resumeId)
                .orderByAsc(ResumeProject::getId));
    }

    @Override
    public void saveOrUpdateProject(Long studentId, ResumeProject project) {
        checkOwn(project.getResumeId(), studentId);
        if (project.getId() != null) {
            ResumeProject old = resumeProjectMapper.selectById(project.getId());
            if (old == null || !old.getResumeId().equals(project.getResumeId())) {
                throw new BusinessException("项目经历不存在");
            }
            resumeProjectMapper.updateById(project);
        } else {
            resumeProjectMapper.insert(project);
        }
        calcCompleteRate(project.getResumeId());
    }

    @Override
    public void deleteProject(Long studentId, Long id) {
        ResumeProject project = resumeProjectMapper.selectById(id);
        if (project == null) {
            throw new BusinessException("项目经历不存在");
        }
        checkOwn(project.getResumeId(), studentId);
        resumeProjectMapper.deleteById(id);
        calcCompleteRate(project.getResumeId());
    }

    // ===== 实习/工作经历 =====

    @Override
    public List<ResumeExperience> listExperience(Long resumeId, Long studentId) {
        checkOwn(resumeId, studentId);
        return resumeExperienceMapper.selectList(new LambdaQueryWrapper<ResumeExperience>()
                .eq(ResumeExperience::getResumeId, resumeId)
                .orderByAsc(ResumeExperience::getId));
    }

    @Override
    public void saveOrUpdateExperience(Long studentId, ResumeExperience experience) {
        checkOwn(experience.getResumeId(), studentId);
        if (experience.getId() != null) {
            ResumeExperience old = resumeExperienceMapper.selectById(experience.getId());
            if (old == null || !old.getResumeId().equals(experience.getResumeId())) {
                throw new BusinessException("实习经历不存在");
            }
            resumeExperienceMapper.updateById(experience);
        } else {
            resumeExperienceMapper.insert(experience);
        }
        calcCompleteRate(experience.getResumeId());
    }

    @Override
    public void deleteExperience(Long studentId, Long id) {
        ResumeExperience exp = resumeExperienceMapper.selectById(id);
        if (exp == null) {
            throw new BusinessException("实习经历不存在");
        }
        checkOwn(exp.getResumeId(), studentId);
        resumeExperienceMapper.deleteById(id);
        calcCompleteRate(exp.getResumeId());
    }
}
