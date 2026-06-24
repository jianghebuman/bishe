package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.common.BusinessException;
import com.campus.common.PageResult;
import com.campus.common.UserContext;
import com.campus.entity.JobApply;
import com.campus.entity.JobPost;
import com.campus.entity.OfferRecord;
import com.campus.entity.SystemNotice;
import com.campus.mapper.JobApplyMapper;
import com.campus.mapper.JobPostMapper;
import com.campus.mapper.OfferRecordMapper;
import com.campus.mapper.SystemNoticeMapper;
import com.campus.service.OfferService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Offer 服务实现（企业HR端）
 *
 * @author campus
 */
@Service
public class OfferServiceImpl extends ServiceImpl<OfferRecordMapper, OfferRecord> implements OfferService {

    @Autowired
    private JobApplyMapper jobApplyMapper;

    @Autowired
    private SystemNoticeMapper systemNoticeMapper;

    @Autowired
    private JobPostMapper jobPostMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long sendOffer(OfferRecord offer) {
        Long enterpriseId = UserContext.getUserId();
        if (offer.getApplyId() == null) {
            throw new BusinessException("缺少投递记录ID");
        }
        JobApply apply = jobApplyMapper.selectById(offer.getApplyId());
        if (apply == null || !enterpriseId.equals(apply.getEnterpriseId())) {
            throw new BusinessException("投递记录不存在或无权操作");
        }
        // 强制归属与冗余字段从投递记录回填，offer_status=0 待确认
        offer.setId(null);
        offer.setEnterpriseId(enterpriseId);
        offer.setStudentId(apply.getStudentId());
        offer.setJobId(apply.getJobId());
        offer.setOfferStatus(0);
        this.save(offer);
        // 同步把投递状态置 4 已录用
        JobApply applyUpdate = new JobApply();
        applyUpdate.setId(apply.getId());
        applyUpdate.setStatus(4);
        jobApplyMapper.updateById(applyUpdate);
        // 给学生发系统通知
        String jobTitle = "";
        JobPost job = jobPostMapper.selectById(apply.getJobId());
        if (job != null) {
            jobTitle = job.getTitle();
        }
        SystemNotice sn = new SystemNotice();
        sn.setReceiverId(apply.getStudentId());
        sn.setReceiverType("STUDENT");
        sn.setTitle("收到 Offer");
        sn.setContent("恭喜！您收到职位「" + jobTitle + "」的录用 Offer，请及时确认。");
        sn.setNoticeType("OFFER");
        sn.setIsRead(0);
        systemNoticeMapper.insert(sn);
        return offer.getId();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void revoke(Long offerId) {
        Long enterpriseId = UserContext.getUserId();
        OfferRecord db = this.getById(offerId);
        if (db == null || !enterpriseId.equals(db.getEnterpriseId())) {
            throw new BusinessException("Offer 不存在或无权操作");
        }
        if (Integer.valueOf(1).equals(db.getOfferStatus())) {
            throw new BusinessException("学生已接受，无法撤回");
        }
        if (Integer.valueOf(3).equals(db.getOfferStatus())) {
            throw new BusinessException("该 Offer 已撤回");
        }
        // offer_status=3 已撤回
        OfferRecord update = new OfferRecord();
        update.setId(offerId);
        update.setOfferStatus(3);
        this.updateById(update);
        // 通知学生
        SystemNotice sn = new SystemNotice();
        sn.setReceiverId(db.getStudentId());
        sn.setReceiverType("STUDENT");
        sn.setTitle("Offer 撤回");
        sn.setContent("很抱歉，企业已撤回向您发出的 Offer。");
        sn.setNoticeType("OFFER");
        sn.setIsRead(0);
        systemNoticeMapper.insert(sn);
    }

    @Override
    public Integer getConfirmStatus(Long offerId) {
        Long enterpriseId = UserContext.getUserId();
        OfferRecord db = this.getById(offerId);
        if (db == null || !enterpriseId.equals(db.getEnterpriseId())) {
            throw new BusinessException("Offer 不存在或无权查看");
        }
        return db.getOfferStatus();
    }

    @Override
    public PageResult<OfferRecord> myOfferPage(Integer pageNum, Integer pageSize, Integer offerStatus) {
        Long enterpriseId = UserContext.getUserId();
        Page<OfferRecord> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<OfferRecord> wrapper = new LambdaQueryWrapper<OfferRecord>()
                .eq(OfferRecord::getEnterpriseId, enterpriseId)
                .eq(offerStatus != null, OfferRecord::getOfferStatus, offerStatus)
                .orderByDesc(OfferRecord::getCreateTime);
        this.page(page, wrapper);
        return PageResult.of(page.getTotal(), page.getRecords());
    }
}
