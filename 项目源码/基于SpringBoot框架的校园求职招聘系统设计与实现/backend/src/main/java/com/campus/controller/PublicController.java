package com.campus.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.common.PageResult;
import com.campus.common.Result;
import com.campus.entity.Announcement;
import com.campus.entity.Banner;
import com.campus.entity.CampusTalk;
import com.campus.entity.Enterprise;
import com.campus.entity.ForumComment;
import com.campus.entity.ForumPost;
import com.campus.entity.JobCategory;
import com.campus.entity.JobFair;
import com.campus.entity.JobPost;
import com.campus.entity.MessageFeedback;
import com.campus.entity.SysDict;
import com.campus.mapper.AnnouncementMapper;
import com.campus.mapper.BannerMapper;
import com.campus.mapper.CampusTalkMapper;
import com.campus.mapper.EnterpriseMapper;
import com.campus.mapper.ForumCommentMapper;
import com.campus.mapper.ForumPostMapper;
import com.campus.mapper.JobCategoryMapper;
import com.campus.mapper.JobFairMapper;
import com.campus.mapper.JobPostMapper;
import com.campus.mapper.MessageFeedbackMapper;
import com.campus.mapper.NewsCategoryMapper;
import com.campus.mapper.SysDictMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 公共门户接口（无需登录，配置在白名单放行）。
 * 为降低与并行模块的耦合，统一用 Mapper 直查实现。
 *
 * @author campus
 */
@RestController
@RequestMapping("/public")
public class PublicController {

    @Autowired
    private BannerMapper bannerMapper;

    @Autowired
    private JobPostMapper jobPostMapper;

    @Autowired
    private EnterpriseMapper enterpriseMapper;

    @Autowired
    private JobCategoryMapper jobCategoryMapper;

    @Autowired
    private SysDictMapper sysDictMapper;

    @Autowired
    private AnnouncementMapper announcementMapper;

    @Autowired
    private CampusTalkMapper campusTalkMapper;

    @Autowired
    private JobFairMapper jobFairMapper;

    @Autowired
    private ForumPostMapper forumPostMapper;

    @Autowired
    private ForumCommentMapper forumCommentMapper;

    @Autowired
    private MessageFeedbackMapper messageFeedbackMapper;

    @Autowired
    private NewsCategoryMapper newsCategoryMapper;

    /** 轮播图：仅启用(status=1)，按 sort 升序 */
    @GetMapping("/banners")
    public Result<List<Banner>> banners() {
        LambdaQueryWrapper<Banner> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Banner::getStatus, 1)
                .orderByAsc(Banner::getSort);
        return Result.success(bannerMapper.selectList(wrapper));
    }

    /**
     * 职位搜索分页：仅返回 审核通过(auditStatus=1) 且 招聘中(status=1) 的职位，
     * 结果附带企业名称。
     */
    @GetMapping("/jobs")
    public Result<PageResult<Map<String, Object>>> jobs(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String city,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String education,
            @RequestParam(required = false) Integer jobType,
            @RequestParam(required = false) Integer salaryMin) {
        LambdaQueryWrapper<JobPost> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(JobPost::getAuditStatus, 1)
                .eq(JobPost::getStatus, 1)
                .like(keyword != null && !keyword.isEmpty(), JobPost::getTitle, keyword)
                .eq(city != null && !city.isEmpty(), JobPost::getCity, city)
                .eq(categoryId != null, JobPost::getCategoryId, categoryId)
                .eq(education != null && !education.isEmpty(), JobPost::getEducation, education)
                .eq(jobType != null, JobPost::getJobType, jobType)
                .ge(salaryMin != null, JobPost::getSalaryMin, salaryMin)
                .orderByDesc(JobPost::getPublishTime)
                .orderByDesc(JobPost::getCreateTime);
        Page<JobPost> page = jobPostMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);

        // 批量查企业名称
        List<JobPost> postList = page.getRecords();
        Map<Long, String> companyNameMap = batchEnterpriseName(
                postList.stream().map(JobPost::getEnterpriseId).collect(Collectors.toList()));

        List<Map<String, Object>> records = postList.stream().map(post -> {
            Map<String, Object> item = beanToMap(post);
            item.put("companyName", companyNameMap.get(post.getEnterpriseId()));
            return item;
        }).collect(Collectors.toList());

        return Result.success(PageResult.of(page.getTotal(), records));
    }

    /** 职位详情：浏览量+1，返回职位+企业信息 */
    @GetMapping("/jobs/{id}")
    public Result<Map<String, Object>> jobDetail(@PathVariable Long id) {
        JobPost post = jobPostMapper.selectById(id);
        if (post == null) {
            return Result.error("职位不存在");
        }
        // 浏览量 +1
        JobPost update = new JobPost();
        update.setId(id);
        update.setViewCount((post.getViewCount() == null ? 0 : post.getViewCount()) + 1);
        jobPostMapper.updateById(update);
        post.setViewCount(update.getViewCount());

        Map<String, Object> result = new HashMap<>(4);
        result.put("job", post);
        if (post.getEnterpriseId() != null) {
            Enterprise enterprise = enterpriseMapper.selectById(post.getEnterpriseId());
            // 脱敏：不返回密码
            if (enterprise != null) {
                enterprise.setPassword(null);
            }
            result.put("enterprise", enterprise);
        }
        return Result.success(result);
    }

    /** 岗位类别列表（树形可由前端按 parentId 自行组装），按 sort 升序 */
    @GetMapping("/job-categories")
    public Result<List<JobCategory>> jobCategories() {
        LambdaQueryWrapper<JobCategory> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByAsc(JobCategory::getSort);
        return Result.success(jobCategoryMapper.selectList(wrapper));
    }

    /** 按类型取字典，按 sort 升序 */
    @GetMapping("/dict/{type}")
    public Result<List<SysDict>> dict(@PathVariable String type) {
        LambdaQueryWrapper<SysDict> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysDict::getDictType, type)
                .orderByAsc(SysDict::getSort);
        return Result.success(sysDictMapper.selectList(wrapper));
    }

    /** 推荐企业：认证通过(auditStatus=2) 且 启用(status=1) 分页 */
    @GetMapping("/enterprises")
    public Result<PageResult<Enterprise>> enterprises(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String industry,
            @RequestParam(required = false) String city) {
        LambdaQueryWrapper<Enterprise> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Enterprise::getAuditStatus, 2)
                .eq(Enterprise::getStatus, 1)
                .like(keyword != null && !keyword.isEmpty(), Enterprise::getCompanyName, keyword)
                .eq(industry != null && !industry.isEmpty(), Enterprise::getIndustry, industry)
                .eq(city != null && !city.isEmpty(), Enterprise::getCity, city)
                .orderByDesc(Enterprise::getCreateTime);
        Page<Enterprise> page = enterpriseMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
        // 脱敏：清除密码
        page.getRecords().forEach(e -> e.setPassword(null));
        return Result.success(PageResult.of(page.getTotal(), page.getRecords()));
    }

    /** 企业详情：含该企业在招职位列表 */
    @GetMapping("/enterprises/{id}")
    public Result<Map<String, Object>> enterpriseDetail(@PathVariable Long id) {
        Enterprise enterprise = enterpriseMapper.selectById(id);
        if (enterprise == null) {
            return Result.error("企业不存在");
        }
        enterprise.setPassword(null);

        // 在招职位：审核通过且招聘中
        LambdaQueryWrapper<JobPost> jobWrapper = new LambdaQueryWrapper<>();
        jobWrapper.eq(JobPost::getEnterpriseId, id)
                .eq(JobPost::getAuditStatus, 1)
                .eq(JobPost::getStatus, 1)
                .orderByDesc(JobPost::getPublishTime);
        List<JobPost> jobs = jobPostMapper.selectList(jobWrapper);

        Map<String, Object> result = new HashMap<>(4);
        result.put("enterprise", enterprise);
        result.put("jobs", jobs);
        return Result.success(result);
    }

    /** 资讯分类列表 */
    @GetMapping("/news-categories")
    public Result<List<com.campus.entity.NewsCategory>> newsCategories() {
        LambdaQueryWrapper<com.campus.entity.NewsCategory> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByAsc(com.campus.entity.NewsCategory::getSort);
        return Result.success(newsCategoryMapper.selectList(wrapper));
    }

    /** 公告资讯分页（可按 categoryId），仅显示 status=1，置顶优先 */
    @GetMapping("/announcements")
    public Result<PageResult<Announcement>> announcements(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) Long categoryId) {
        LambdaQueryWrapper<Announcement> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Announcement::getStatus, 1)
                .eq(categoryId != null, Announcement::getCategoryId, categoryId)
                .orderByDesc(Announcement::getIsTop)
                .orderByDesc(Announcement::getPublishTime)
                .orderByDesc(Announcement::getCreateTime);
        Page<Announcement> page = announcementMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
        return Result.success(PageResult.of(page.getTotal(), page.getRecords()));
    }

    /** 公告详情：浏览量+1 */
    @GetMapping("/announcements/{id}")
    public Result<Announcement> announcementDetail(@PathVariable Long id) {
        Announcement announcement = announcementMapper.selectById(id);
        if (announcement == null) {
            return Result.error("公告不存在");
        }
        Announcement update = new Announcement();
        update.setId(id);
        update.setViewCount((announcement.getViewCount() == null ? 0 : announcement.getViewCount()) + 1);
        announcementMapper.updateById(update);
        announcement.setViewCount(update.getViewCount());
        return Result.success(announcement);
    }

    /** 宣讲会分页：仅显示 status=1，按宣讲时间倒序 */
    @GetMapping("/talks")
    public Result<PageResult<CampusTalk>> talks(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        LambdaQueryWrapper<CampusTalk> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CampusTalk::getStatus, 1)
                .orderByDesc(CampusTalk::getTalkTime);
        Page<CampusTalk> page = campusTalkMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
        return Result.success(PageResult.of(page.getTotal(), page.getRecords()));
    }

    /** 招聘会分页：仅显示 status=1，按举办时间倒序 */
    @GetMapping("/fairs")
    public Result<PageResult<JobFair>> fairs(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        LambdaQueryWrapper<JobFair> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(JobFair::getStatus, 1)
                .orderByDesc(JobFair::getFairTime);
        Page<JobFair> page = jobFairMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
        return Result.success(PageResult.of(page.getTotal(), page.getRecords()));
    }

    /** 论坛帖子分页：审核通过(auditStatus=1) 且 正常(status=1) */
    @GetMapping("/forum/posts")
    public Result<PageResult<ForumPost>> forumPosts(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String category) {
        LambdaQueryWrapper<ForumPost> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ForumPost::getAuditStatus, 1)
                .eq(ForumPost::getStatus, 1)
                .like(keyword != null && !keyword.isEmpty(), ForumPost::getTitle, keyword)
                .eq(category != null && !category.isEmpty(), ForumPost::getCategory, category)
                .orderByDesc(ForumPost::getCreateTime);
        Page<ForumPost> page = forumPostMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
        return Result.success(PageResult.of(page.getTotal(), page.getRecords()));
    }

    /** 帖子详情：浏览量+1 */
    @GetMapping("/forum/posts/{id}")
    public Result<ForumPost> forumPostDetail(@PathVariable Long id) {
        ForumPost post = forumPostMapper.selectById(id);
        if (post == null) {
            return Result.error("帖子不存在");
        }
        ForumPost update = new ForumPost();
        update.setId(id);
        update.setViewCount((post.getViewCount() == null ? 0 : post.getViewCount()) + 1);
        forumPostMapper.updateById(update);
        post.setViewCount(update.getViewCount());
        return Result.success(post);
    }

    /** 帖子评论列表：仅显示 status=1，按时间升序 */
    @GetMapping("/forum/posts/{id}/comments")
    public Result<List<ForumComment>> forumComments(@PathVariable Long id) {
        LambdaQueryWrapper<ForumComment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ForumComment::getPostId, id)
                .eq(ForumComment::getStatus, 1)
                .orderByAsc(ForumComment::getCreateTime);
        return Result.success(forumCommentMapper.selectList(wrapper));
    }

    /** 提交留言反馈（游客可用） */
    @PostMapping("/feedback")
    public Result<Void> feedback(@RequestBody MessageFeedback feedback) {
        if (feedback.getContent() == null || feedback.getContent().trim().isEmpty()) {
            return Result.error("留言内容不能为空");
        }
        MessageFeedback save = new MessageFeedback();
        save.setUserName(feedback.getUserName());
        save.setContent(feedback.getContent());
        save.setContact(feedback.getContact());
        // 游客留言：用户类型默认 GUEST
        save.setUserType(feedback.getUserType() == null || feedback.getUserType().isEmpty()
                ? "GUEST" : feedback.getUserType());
        save.setStatus(0);
        messageFeedbackMapper.insert(save);
        return Result.success("留言提交成功", null);
    }

    /** 首页聚合数据 */
    @GetMapping("/home")
    public Result<Map<String, Object>> home() {
        Map<String, Object> data = new HashMap<>(8);

        // 轮播图
        LambdaQueryWrapper<Banner> bannerWrapper = new LambdaQueryWrapper<>();
        bannerWrapper.eq(Banner::getStatus, 1).orderByAsc(Banner::getSort);
        data.put("banners", bannerMapper.selectList(bannerWrapper));

        // 热门职位：按浏览量、申请量取前 12（审核通过且招聘中），附带企业名称
        LambdaQueryWrapper<JobPost> hotWrapper = new LambdaQueryWrapper<>();
        hotWrapper.eq(JobPost::getAuditStatus, 1)
                .eq(JobPost::getStatus, 1)
                .orderByDesc(JobPost::getViewCount)
                .orderByDesc(JobPost::getApplyCount)
                .last("LIMIT 12");
        List<JobPost> hotJobs = jobPostMapper.selectList(hotWrapper);
        Map<Long, String> companyNameMap = batchEnterpriseName(
                hotJobs.stream().map(JobPost::getEnterpriseId).collect(Collectors.toList()));
        List<Map<String, Object>> hotJobList = hotJobs.stream().map(post -> {
            Map<String, Object> item = beanToMap(post);
            item.put("companyName", companyNameMap.get(post.getEnterpriseId()));
            return item;
        }).collect(Collectors.toList());
        data.put("hotJobs", hotJobList);

        // 推荐企业：认证通过且启用，前 8
        LambdaQueryWrapper<Enterprise> entWrapper = new LambdaQueryWrapper<>();
        entWrapper.eq(Enterprise::getAuditStatus, 2)
                .eq(Enterprise::getStatus, 1)
                .orderByDesc(Enterprise::getCreateTime)
                .last("LIMIT 8");
        List<Enterprise> recommendEnterprises = enterpriseMapper.selectList(entWrapper);
        recommendEnterprises.forEach(e -> e.setPassword(null));
        data.put("recommendEnterprises", recommendEnterprises);

        // 宣讲会前 5
        LambdaQueryWrapper<CampusTalk> talkWrapper = new LambdaQueryWrapper<>();
        talkWrapper.eq(CampusTalk::getStatus, 1)
                .orderByDesc(CampusTalk::getTalkTime)
                .last("LIMIT 5");
        data.put("talks", campusTalkMapper.selectList(talkWrapper));

        // 招聘会前 5
        LambdaQueryWrapper<JobFair> fairWrapper = new LambdaQueryWrapper<>();
        fairWrapper.eq(JobFair::getStatus, 1)
                .orderByDesc(JobFair::getFairTime)
                .last("LIMIT 5");
        data.put("fairs", jobFairMapper.selectList(fairWrapper));

        // 公告前 7
        LambdaQueryWrapper<Announcement> annWrapper = new LambdaQueryWrapper<>();
        annWrapper.eq(Announcement::getStatus, 1)
                .orderByDesc(Announcement::getIsTop)
                .orderByDesc(Announcement::getPublishTime)
                .orderByDesc(Announcement::getCreateTime)
                .last("LIMIT 7");
        data.put("announcements", announcementMapper.selectList(annWrapper));

        return Result.success(data);
    }

    /* ====================== 私有辅助方法 ====================== */

    /** 批量查询企业名称，返回 企业ID -> 企业名称 映射 */
    private Map<Long, String> batchEnterpriseName(List<Long> enterpriseIds) {
        List<Long> ids = enterpriseIds.stream()
                .filter(java.util.Objects::nonNull)
                .distinct()
                .collect(Collectors.toList());
        if (ids.isEmpty()) {
            return Collections.emptyMap();
        }
        LambdaQueryWrapper<Enterprise> wrapper = new LambdaQueryWrapper<>();
        wrapper.in(Enterprise::getId, ids)
                .select(Enterprise::getId, Enterprise::getCompanyName);
        List<Enterprise> list = enterpriseMapper.selectList(wrapper);
        Map<Long, String> map = new HashMap<>(list.size());
        for (Enterprise e : list) {
            map.put(e.getId(), e.getCompanyName());
        }
        return map;
    }

    /** 将职位实体转为可扩展的 Map，便于附带企业名称等冗余字段 */
    private Map<String, Object> beanToMap(JobPost post) {
        Map<String, Object> map = new HashMap<>(24);
        map.put("id", post.getId());
        map.put("enterpriseId", post.getEnterpriseId());
        map.put("categoryId", post.getCategoryId());
        map.put("title", post.getTitle());
        map.put("jobType", post.getJobType());
        map.put("recruitNum", post.getRecruitNum());
        map.put("city", post.getCity());
        map.put("salaryMin", post.getSalaryMin());
        map.put("salaryMax", post.getSalaryMax());
        map.put("education", post.getEducation());
        map.put("majorRequire", post.getMajorRequire());
        map.put("experience", post.getExperience());
        map.put("welfare", post.getWelfare());
        map.put("viewCount", post.getViewCount());
        map.put("applyCount", post.getApplyCount());
        map.put("publishTime", post.getPublishTime());
        map.put("createTime", post.getCreateTime());
        return map;
    }
}
