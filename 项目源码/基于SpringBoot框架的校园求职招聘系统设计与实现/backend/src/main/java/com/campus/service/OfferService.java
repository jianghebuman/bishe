package com.campus.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.common.PageResult;
import com.campus.entity.OfferRecord;

/**
 * Offer 服务（企业HR端）
 *
 * @author campus
 */
public interface OfferService extends IService<OfferRecord> {

    /**
     * 发 Offer：写 offer_record（offer_status=0 待确认），并给学生发系统通知。
     *
     * @return 新 Offer 记录ID
     */
    Long sendOffer(OfferRecord offer);

    /**
     * 撤回 Offer（offer_status=3 已撤回，仅限当前企业自己发出的 Offer）
     *
     * @param offerId Offer记录ID
     */
    void revoke(Long offerId);

    /**
     * 查看某条 Offer 的学生确认状态
     *
     * @param offerId Offer记录ID
     * @return offer_status：0待确认 1已接受 2已拒绝 3已撤回
     */
    Integer getConfirmStatus(Long offerId);

    /**
     * 我发出的 Offer 分页（按当前企业，可按 offerStatus 筛选）
     *
     * @param pageNum     页码
     * @param pageSize    每页数量
     * @param offerStatus Offer状态（可空）
     */
    PageResult<OfferRecord> myOfferPage(Integer pageNum, Integer pageSize, Integer offerStatus);
}
