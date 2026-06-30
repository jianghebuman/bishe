package com.campus.vo;

import com.campus.entity.JobApply;
import com.campus.entity.Resume;
import com.campus.entity.ResumeAttachment;
import com.campus.entity.ResumeEducation;
import com.campus.entity.ResumeExperience;
import com.campus.entity.ResumeProject;
import lombok.Data;

import java.util.List;

/**
 * 企业端查看学生投递详情。
 *
 * @author campus
 */
@Data
public class EnterpriseApplyDetailVO {

    private JobApply apply;

    private String applicantName;

    private Resume resume;

    private List<ResumeEducation> educations;

    private List<ResumeProject> projects;

    private List<ResumeExperience> experiences;

    private List<ResumeAttachment> attachments;
}
