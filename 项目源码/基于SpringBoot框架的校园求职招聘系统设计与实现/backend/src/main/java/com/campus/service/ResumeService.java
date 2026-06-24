package com.campus.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.entity.Resume;
import com.campus.entity.ResumeEducation;
import com.campus.entity.ResumeExperience;
import com.campus.entity.ResumeProject;

import java.util.List;

/**
 * 简历服务（含主表 CRUD、完整度计算、教育/项目/实习经历管理）
 *
 * @author campus
 */
public interface ResumeService extends IService<Resume> {

    /** 获取当前学生的简历（一个学生一份，可能为 null） */
    Resume getByStudent(Long studentId);

    /** 保存或更新当前学生的简历，返回简历ID */
    Long saveOrUpdateResume(Long studentId, Resume resume);

    /**
     * 计算简历完整度并写回 resume.completeRate。
     * 规则：基本信息填全+20、教育经历≥1条+20、项目经历≥1条+20、实习经历≥1条+20、技能或自我评价+20。
     *
     * @return 完整度（0-100）
     */
    Integer calcCompleteRate(Long resumeId);

    /** 校验简历归属当前学生，不属于则抛业务异常 */
    Resume checkOwn(Long resumeId, Long studentId);

    // ===== 教育经历 =====

    /** 查询某份简历的教育经历列表 */
    List<ResumeEducation> listEducation(Long resumeId, Long studentId);

    /** 新增或更新教育经历（按 id 是否存在判断） */
    void saveOrUpdateEducation(Long studentId, ResumeEducation education);

    /** 删除教育经历 */
    void deleteEducation(Long studentId, Long id);

    // ===== 项目经历 =====

    /** 查询某份简历的项目经历列表 */
    List<ResumeProject> listProject(Long resumeId, Long studentId);

    /** 新增或更新项目经历 */
    void saveOrUpdateProject(Long studentId, ResumeProject project);

    /** 删除项目经历 */
    void deleteProject(Long studentId, Long id);

    // ===== 实习/工作经历 =====

    /** 查询某份简历的实习经历列表 */
    List<ResumeExperience> listExperience(Long resumeId, Long studentId);

    /** 新增或更新实习经历 */
    void saveOrUpdateExperience(Long studentId, ResumeExperience experience);

    /** 删除实习经历 */
    void deleteExperience(Long studentId, Long id);
}
