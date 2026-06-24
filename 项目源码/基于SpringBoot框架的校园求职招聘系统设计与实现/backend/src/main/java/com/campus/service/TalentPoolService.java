package com.campus.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.common.PageResult;
import com.campus.entity.Resume;
import com.campus.entity.TalentPool;

/**
 * 人才库服务（企业HR端）
 *
 * @author campus
 */
public interface TalentPoolService extends IService<TalentPool> {

    /**
     * 收藏候选人到当前企业人才库（enterpriseId + studentId）。
     *
     * @param studentId 学生ID
     * @param resumeId  简历ID（可空）
     * @param tag       标签
     * @param remark    备注
     */
    void addTalent(Long studentId, Long resumeId, String tag, String remark);

    /** 从当前企业人才库移除候选人 */
    void removeTalent(Long talentId);

    /**
     * 人才库分页（按当前企业，可按标签 / 关键词筛选）
     *
     * @param pageNum  页码
     * @param pageSize 每页数量
     * @param tag      标签（可空）
     * @param keyword  关键词（匹配备注，可空）
     */
    PageResult<TalentPool> talentPage(Integer pageNum, Integer pageSize, String tag, String keyword);

    /**
     * 按条件检索候选人简历（查 Resume，可按 major / education / 关键词），
     * 仅检索公开简历（is_public=1）。
     *
     * @param pageNum   页码
     * @param pageSize  每页数量
     * @param major     专业（可空，模糊）
     * @param education 学历（可空）
     * @param keyword   关键词（匹配姓名/院校/技能/自我评价，可空）
     */
    PageResult<Resume> searchResume(Integer pageNum, Integer pageSize, String major, String education, String keyword);
}
