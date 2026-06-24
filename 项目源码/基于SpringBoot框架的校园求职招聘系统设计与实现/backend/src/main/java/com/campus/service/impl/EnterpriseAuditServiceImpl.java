package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.common.BusinessException;
import com.campus.common.UserContext;
import com.campus.entity.Enterprise;
import com.campus.entity.EnterpriseAudit;
import com.campus.mapper.EnterpriseAuditMapper;
import com.campus.mapper.EnterpriseMapper;
import com.campus.service.EnterpriseAuditService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 企业认证审核服务实现
 *
 * @author campus
 */
@Service
public class EnterpriseAuditServiceImpl extends ServiceImpl<EnterpriseAuditMapper, EnterpriseAudit>
        implements EnterpriseAuditService {

    @Autowired
    private EnterpriseMapper enterpriseMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void submitAudit(String licenseNo, String licenseImg, String extraImg) {
        Long enterpriseId = UserContext.getUserId();
        Enterprise enterprise = enterpriseMapper.selectById(enterpriseId);
        if (enterprise == null) {
            throw new BusinessException("企业信息不存在");
        }
        // 已通过认证不允许重复提交
        if (Integer.valueOf(2).equals(enterprise.getAuditStatus())) {
            throw new BusinessException("企业已通过认证，无需重复提交");
        }
        // 待审核中不允许重复提交
        if (Integer.valueOf(1).equals(enterprise.getAuditStatus())) {
            throw new BusinessException("认证申请审核中，请耐心等待");
        }
        if (licenseNo == null || licenseNo.trim().isEmpty()) {
            throw new BusinessException("营业执照编号不能为空");
        }
        if (licenseImg == null || licenseImg.trim().isEmpty()) {
            throw new BusinessException("营业执照图片不能为空");
        }
        // 新增一条审核记录，auditStatus=1 待审核
        EnterpriseAudit audit = new EnterpriseAudit();
        audit.setEnterpriseId(enterpriseId);
        audit.setLicenseNo(licenseNo);
        audit.setLicenseImg(licenseImg);
        audit.setExtraImg(extraImg);
        audit.setAuditStatus(1);
        this.save(audit);
        // 把企业认证状态置 1（待审核）
        Enterprise update = new Enterprise();
        update.setId(enterpriseId);
        update.setAuditStatus(1);
        enterpriseMapper.updateById(update);
    }

    @Override
    public EnterpriseAudit getLatest() {
        Long enterpriseId = UserContext.getUserId();
        return this.getOne(new LambdaQueryWrapper<EnterpriseAudit>()
                .eq(EnterpriseAudit::getEnterpriseId, enterpriseId)
                .orderByDesc(EnterpriseAudit::getCreateTime)
                .last("LIMIT 1"), false);
    }
}
