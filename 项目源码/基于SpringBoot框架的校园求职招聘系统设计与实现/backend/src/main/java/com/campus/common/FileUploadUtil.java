package com.campus.common;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.nio.file.Files;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

/**
 * 文件上传工具
 *
 * @author campus
 */
@Slf4j
@Component
public class FileUploadUtil {

    @Value("${campus.upload.path}")
    private String uploadPath;

    @Value("${campus.upload.prefix}")
    private String uploadPrefix;

    /** 允许的图片类型 */
    private static final List<String> IMAGE_TYPES = Arrays.asList("jpg", "jpeg", "png", "gif", "bmp", "webp");

    /** 允许的文档/简历类型 */
    private static final List<String> DOC_TYPES = Arrays.asList("pdf", "doc", "docx");

    /** 单文件最大 20MB */
    private static final long MAX_SIZE = 20 * 1024 * 1024L;

    /** 上传图片 */
    public String uploadImage(MultipartFile file) {
        return upload(file, IMAGE_TYPES, "image");
    }

    /** 上传简历附件 */
    public String uploadDoc(MultipartFile file) {
        return upload(file, DOC_TYPES, "resume");
    }

    private String upload(MultipartFile file, List<String> allowTypes, String subDir) {
        if (file == null || file.isEmpty()) {
            throw new BusinessException("上传文件不能为空");
        }
        if (file.getSize() > MAX_SIZE) {
            throw new BusinessException("文件大小不能超过20MB");
        }
        String originName = file.getOriginalFilename();
        String suffix = StringUtils.getFilenameExtension(originName);
        if (suffix == null || !allowTypes.contains(suffix.toLowerCase(Locale.ROOT))) {
            throw new BusinessException("不支持的文件类型，仅支持：" + allowTypes);
        }
        // 新文件名
        String fileName = UUID.randomUUID().toString().replace("-", "") + "." + suffix;
        File dest = new File(uploadPath + subDir + File.separator + fileName);
        try {
            Files.createDirectories(dest.getParentFile().toPath());
            file.transferTo(dest);
        } catch (Exception e) {
            log.error("文件上传失败", e);
            throw new BusinessException("文件上传失败");
        }
        // 返回可访问的相对路径
        return uploadPrefix + subDir + "/" + fileName;
    }
}
