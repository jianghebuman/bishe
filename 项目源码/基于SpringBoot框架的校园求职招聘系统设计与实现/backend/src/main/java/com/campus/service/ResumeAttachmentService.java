package com.campus.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.entity.ResumeAttachment;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

/**
 * 附件简历服务
 *
 * @author campus
 */
public interface ResumeAttachmentService extends IService<ResumeAttachment> {

    /** 当前学生的附件列表 */
    List<ResumeAttachment> listByStudent(Long studentId);

    /** 上传附件简历，返回保存后的记录 */
    ResumeAttachment upload(Long studentId, MultipartFile file);

    /** 删除当前学生的某个附件 */
    void deleteOwn(Long studentId, Long id);
}
