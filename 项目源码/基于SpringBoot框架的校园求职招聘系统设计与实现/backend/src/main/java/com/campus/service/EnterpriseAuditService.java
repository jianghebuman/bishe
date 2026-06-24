package com.campus.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.entity.EnterpriseAudit;

/**
 * 企业认证审核服务
 *
 * @author campus
 */
public interface EnterpriseAuditService extends IService<EnterpriseAudit> {

    /**
     * 当前企业提交认证：新增一条 enterprise_audit（auditStatus=1 待审核），
     * 并把 enterprise.audit_status 置 1。
     *
     * @param licenseNo  营业执照编号
     * @param licenseImg 营业执照图片
     * @param extraImg   补充材料图片
     */
    void submitAudit(String licenseNo, String licenseImg, String extraImg);

    /** 查询当前企业最新一条认证记录 */
    EnterpriseAudit getLatest();
}
