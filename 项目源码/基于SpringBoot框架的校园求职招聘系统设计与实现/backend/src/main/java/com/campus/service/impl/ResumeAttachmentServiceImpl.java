package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.common.BusinessException;
import com.campus.common.FileUploadUtil;
import com.campus.entity.ResumeAttachment;
import com.campus.mapper.ResumeAttachmentMapper;
import com.campus.service.ResumeAttachmentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

/**
 * 附件简历服务实现
 *
 * @author campus
 */
@Service
public class ResumeAttachmentServiceImpl extends ServiceImpl<ResumeAttachmentMapper, ResumeAttachment>
        implements ResumeAttachmentService {

    @Autowired
    private FileUploadUtil fileUploadUtil;

    @Override
    public List<ResumeAttachment> listByStudent(Long studentId) {
        return this.list(new LambdaQueryWrapper<ResumeAttachment>()
                .eq(ResumeAttachment::getStudentId, studentId)
                .orderByDesc(ResumeAttachment::getCreateTime));
    }

    @Override
    public ResumeAttachment upload(Long studentId, MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BusinessException("请选择要上传的简历文件");
        }
        // 上传到 resume 子目录，返回可访问相对路径
        String url = fileUploadUtil.uploadDoc(file);
        ResumeAttachment attachment = new ResumeAttachment();
        attachment.setStudentId(studentId);
        attachment.setFileName(file.getOriginalFilename());
        attachment.setFileUrl(url);
        attachment.setFileSize(file.getSize());
        attachment.setFileType(file.getContentType());
        this.save(attachment);
        return attachment;
    }

    @Override
    public void deleteOwn(Long studentId, Long id) {
        ResumeAttachment attachment = this.getById(id);
        if (attachment == null) {
            throw new BusinessException("附件不存在");
        }
        if (!attachment.getStudentId().equals(studentId)) {
            throw new BusinessException("无权删除他人附件");
        }
        this.removeById(id);
    }
}
