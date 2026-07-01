package com.campus.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.common.PageResult;
import com.campus.common.Result;
import com.campus.entity.Announcement;
import com.campus.entity.Banner;
import com.campus.entity.CampusTalk;
import com.campus.entity.Enterprise;
import com.campus.entity.EnterpriseHr;
import com.campus.entity.ForumComment;
import com.campus.entity.ForumPost;
import com.campus.entity.JobCategory;
import com.campus.entity.JobFair;
import com.campus.entity.JobPost;
import com.campus.entity.MessageFeedback;
import com.campus.entity.School;
import com.campus.entity.SysDict;
import com.campus.mapper.AnnouncementMapper;
import com.campus.mapper.BannerMapper;
import com.campus.mapper.CampusTalkMapper;
import com.campus.mapper.EnterpriseMapper;
import com.campus.mapper.EnterpriseHrMapper;
import com.campus.mapper.ForumCommentMapper;
import com.campus.mapper.ForumPostMapper;
import com.campus.mapper.JobCategoryMapper;
import com.campus.mapper.JobFairMapper;
import com.campus.mapper.JobPostMapper;
import com.campus.mapper.MessageFeedbackMapper;
import com.campus.mapper.NewsCategoryMapper;
import com.campus.mapper.SchoolMapper;
import com.campus.mapper.SysDictMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
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
    private EnterpriseHrMapper enterpriseHrMapper;

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

    @Autowired
    private SchoolMapper schoolMapper;

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
            @RequestParam(required = false) Long enterpriseId,
            @RequestParam(required = false) String city,
            @RequestParam(required = false) String categoryId,
            @RequestParam(required = false) String education,
            @RequestParam(required = false) String jobType,
            @RequestParam(required = false) String salaryMin,
            @RequestParam(required = false) String salaryMax) {
        int safePageNum = pageNum == null || pageNum < 1 ? 1 : pageNum;
        int safePageSize = pageSize == null || pageSize < 1 ? 10 : pageSize;
        String keywordText = trimToEmpty(keyword);
        List<String> cities = splitStrings(city);
        List<Long> categoryIds = expandCategoryIds(splitLongs(categoryId));
        List<String> educations = splitStrings(education);
        List<Integer> jobTypes = splitIntegers(jobType);
        List<Integer> salaryMins = splitIntegers(salaryMin);
        List<Integer> salaryMaxes = splitIntegers(salaryMax);
        Integer minSalary = salaryMins.isEmpty() ? null : Collections.min(salaryMins);
        Integer maxSalary = salaryMaxes.isEmpty() ? null : Collections.max(salaryMaxes);

        LambdaQueryWrapper<JobPost> wrapper = buildJobWrapper(
                keywordText, enterpriseId, cities, categoryIds, educations, jobTypes, minSalary, maxSalary);
        Page<JobPost> page = jobPostMapper.selectPage(new Page<>(safePageNum, safePageSize), wrapper);

        if (enterpriseId == null && page.getTotal() == 0 && hasJobCondition(keywordText, cities, categoryIds, educations, jobTypes,
                minSalary, maxSalary)) {
            return Result.success(recommendJobs(safePageNum, safePageSize, keywordText, cities, categoryIds,
                    educations, jobTypes, minSalary, maxSalary));
        }

        PageResult<Map<String, Object>> result = toJobResult(page.getTotal(), page.getRecords(), false,
                page.getTotal());
        return Result.success(result);
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

        Map<String, Object> result = new HashMap<>(6);
        result.put("job", post);
        if (post.getEnterpriseId() != null) {
            Enterprise enterprise = enterpriseMapper.selectById(post.getEnterpriseId());
            result.put("enterprise", enterprise);
        }
        result.put("hrId", post.getHrId());
        return Result.success(result);
    }

    /** 岗位类别列表（树形可由前端按 parentId 自行组装），按 sort 升序 */
    @GetMapping("/job-categories")
    public Result<List<JobCategory>> jobCategories() {
        LambdaQueryWrapper<JobCategory> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByAsc(JobCategory::getSort);
        return Result.success(jobCategoryMapper.selectList(wrapper));
    }

    /** 学校基础数据：学生注册和资料维护使用 */
    @GetMapping("/schools")
    public Result<List<School>> schools() {
        LambdaQueryWrapper<School> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(School::getStatus, 1)
                .orderByAsc(School::getSort)
                .orderByAsc(School::getId);
        return Result.success(schoolMapper.selectList(wrapper));
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
        return Result.success(PageResult.of(page.getTotal(), page.getRecords()));
    }

    /** 企业详情：含该企业在招职位列表 */
    @GetMapping("/enterprises/{id}")
    public Result<Map<String, Object>> enterpriseDetail(@PathVariable Long id) {
        Enterprise enterprise = enterpriseMapper.selectById(id);
        if (enterprise == null) {
            return Result.error("企业不存在");
        }
        // 在招职位：审核通过且招聘中
        LambdaQueryWrapper<JobPost> jobWrapper = new LambdaQueryWrapper<>();
        jobWrapper.eq(JobPost::getEnterpriseId, id)
                .eq(JobPost::getAuditStatus, 1)
                .eq(JobPost::getStatus, 1)
                .orderByDesc(JobPost::getPublishTime);
        List<JobPost> jobs = jobPostMapper.selectList(jobWrapper);

        Map<String, Object> result = new HashMap<>(6);
        result.put("enterprise", enterprise);
        result.put("jobs", jobs);
        result.put("hrId", defaultHrId(id));
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

    /** 宣讲会详情 */
    @GetMapping("/talks/{id}")
    public Result<CampusTalk> talkDetail(@PathVariable Long id) {
        CampusTalk talk = campusTalkMapper.selectById(id);
        if (talk == null || !Integer.valueOf(1).equals(talk.getStatus())) {
            return Result.error("宣讲会不存在");
        }
        return Result.success(talk);
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

    /** 招聘会详情 */
    @GetMapping("/fairs/{id}")
    public Result<JobFair> fairDetail(@PathVariable Long id) {
        JobFair fair = jobFairMapper.selectById(id);
        if (fair == null || !Integer.valueOf(1).equals(fair.getStatus())) {
            return Result.error("招聘会不存在");
        }
        return Result.success(fair);
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
        save.setUserId(feedback.getUserId());
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

        // 热门职位：按浏览量、申请量取前 15（审核通过且招聘中），附带企业名称
        LambdaQueryWrapper<JobPost> hotWrapper = new LambdaQueryWrapper<>();
        hotWrapper.eq(JobPost::getAuditStatus, 1)
                .eq(JobPost::getStatus, 1)
                .orderByDesc(JobPost::getViewCount)
                .orderByDesc(JobPost::getApplyCount)
                .last("LIMIT 15");
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
        data.put("recommendEnterprises", recommendEnterprises);

        // 宣讲会前 7
        LambdaQueryWrapper<CampusTalk> talkWrapper = new LambdaQueryWrapper<>();
        talkWrapper.eq(CampusTalk::getStatus, 1)
                .orderByDesc(CampusTalk::getTalkTime)
                .last("LIMIT 7");
        data.put("talks", campusTalkMapper.selectList(talkWrapper));

        // 招聘会前 7
        LambdaQueryWrapper<JobFair> fairWrapper = new LambdaQueryWrapper<>();
        fairWrapper.eq(JobFair::getStatus, 1)
                .orderByDesc(JobFair::getFairTime)
                .last("LIMIT 7");
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

    private Long defaultHrId(Long enterpriseId) {
        EnterpriseHr supervisor = enterpriseHrMapper.selectOne(new LambdaQueryWrapper<EnterpriseHr>()
                .eq(EnterpriseHr::getEnterpriseId, enterpriseId)
                .eq(EnterpriseHr::getHrRole, "SUPERVISOR")
                .eq(EnterpriseHr::getStatus, 1)
                .orderByAsc(EnterpriseHr::getId)
                .last("LIMIT 1"));
        if (supervisor != null) {
            return supervisor.getId();
        }
        EnterpriseHr hr = enterpriseHrMapper.selectOne(new LambdaQueryWrapper<EnterpriseHr>()
                .eq(EnterpriseHr::getEnterpriseId, enterpriseId)
                .eq(EnterpriseHr::getStatus, 1)
                .orderByAsc(EnterpriseHr::getId)
                .last("LIMIT 1"));
        return hr == null ? null : hr.getId();
    }

    private LambdaQueryWrapper<JobPost> buildJobWrapper(String keyword, Long enterpriseId, List<String> cities, List<Long> categoryIds,
                                                        List<String> educations, List<Integer> jobTypes,
                                                        Integer minSalary, Integer maxSalary) {
        LambdaQueryWrapper<JobPost> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(JobPost::getAuditStatus, 1)
                .eq(JobPost::getStatus, 1)
                .eq(enterpriseId != null, JobPost::getEnterpriseId, enterpriseId)
                .and(!keyword.isEmpty(), w -> w.like(JobPost::getTitle, keyword)
                        .or().like(JobPost::getMajorRequire, keyword)
                        .or().like(JobPost::getDuty, keyword)
                        .or().like(JobPost::getRequirement, keyword))
                .in(!cities.isEmpty(), JobPost::getCity, cities)
                .in(!categoryIds.isEmpty(), JobPost::getCategoryId, categoryIds)
                .in(!educations.isEmpty(), JobPost::getEducation, educations)
                .in(!jobTypes.isEmpty(), JobPost::getJobType, jobTypes)
                .ge(minSalary != null, JobPost::getSalaryMin, minSalary)
                .le(maxSalary != null, JobPost::getSalaryMax, maxSalary)
                .orderByDesc(JobPost::getPublishTime)
                .orderByDesc(JobPost::getCreateTime);
        return wrapper;
    }

    private PageResult<Map<String, Object>> recommendJobs(int pageNum, int pageSize, String keyword,
                                                          List<String> cities, List<Long> categoryIds,
                                                          List<String> educations, List<Integer> jobTypes,
                                                          Integer minSalary, Integer maxSalary) {
        LambdaQueryWrapper<JobPost> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(JobPost::getAuditStatus, 1)
                .eq(JobPost::getStatus, 1);
        List<JobPost> all = jobPostMapper.selectList(wrapper);
        Map<Long, Integer> scoreMap = new HashMap<>(all.size());
        for (JobPost post : all) {
            scoreMap.put(post.getId(), jobScore(post, keyword, cities, categoryIds, educations, jobTypes,
                    minSalary, maxSalary));
        }

        List<JobPost> ranked = all.stream()
                .filter(post -> scoreMap.get(post.getId()) > 0)
                .sorted((a, b) -> {
                    int scoreDiff = scoreMap.get(b.getId()) - scoreMap.get(a.getId());
                    if (scoreDiff != 0) {
                        return scoreDiff;
                    }
                    return compareDateDesc(a.getPublishTime(), b.getPublishTime());
                })
                .collect(Collectors.toList());
        if (ranked.isEmpty()) {
            ranked = all.stream()
                    .sorted((a, b) -> compareDateDesc(a.getPublishTime(), b.getPublishTime()))
                    .collect(Collectors.toList());
        }

        int fromIndex = Math.min((pageNum - 1) * pageSize, ranked.size());
        int toIndex = Math.min(fromIndex + pageSize, ranked.size());
        return toJobResult((long) ranked.size(), ranked.subList(fromIndex, toIndex), true, 0L);
    }

    private int jobScore(JobPost post, String keyword, List<String> cities, List<Long> categoryIds,
                         List<String> educations, List<Integer> jobTypes, Integer minSalary, Integer maxSalary) {
        int score = 0;
        String searchable = (trimToEmpty(post.getTitle()) + " " + trimToEmpty(post.getMajorRequire())
                + " " + trimToEmpty(post.getDuty()) + " " + trimToEmpty(post.getRequirement())).toLowerCase();
        for (String part : keywordParts(keyword)) {
            if (searchable.contains(part)) {
                score += part.equals(keyword.toLowerCase()) ? 80 : 18;
            }
        }
        if (!cities.isEmpty() && cities.contains(post.getCity())) {
            score += 24;
        }
        if (!categoryIds.isEmpty() && post.getCategoryId() != null && categoryIds.contains(post.getCategoryId())) {
            score += 28;
        }
        if (!educations.isEmpty()) {
            if (educations.contains(post.getEducation())) {
                score += 8;
            } else if ("不限".equals(post.getEducation())) {
                score += 4;
            }
        }
        if (!jobTypes.isEmpty() && post.getJobType() != null && jobTypes.contains(post.getJobType())) {
            score += 16;
        }
        if (minSalary != null && post.getSalaryMax() != null) {
            score += post.getSalaryMax() >= minSalary ? 10 : Math.max(0, 4 - (minSalary - post.getSalaryMax()));
        }
        if (maxSalary != null && post.getSalaryMin() != null) {
            score += post.getSalaryMin() <= maxSalary ? 10 : Math.max(0, 4 - (post.getSalaryMin() - maxSalary));
        }
        return score;
    }

    private PageResult<Map<String, Object>> toJobResult(Long total, List<JobPost> postList, boolean recommended,
                                                        Long strictTotal) {
        Map<Long, String> companyNameMap = batchEnterpriseName(
                postList.stream().map(JobPost::getEnterpriseId).collect(Collectors.toList()));
        List<Map<String, Object>> records = postList.stream().map(post -> {
            Map<String, Object> item = beanToMap(post);
            item.put("companyName", companyNameMap.get(post.getEnterpriseId()));
            return item;
        }).collect(Collectors.toList());
        PageResult<Map<String, Object>> result = PageResult.of(total, records);
        result.setRecommended(recommended);
        result.setStrictTotal(strictTotal);
        return result;
    }

    private boolean hasJobCondition(String keyword, List<String> cities, List<Long> categoryIds,
                                    List<String> educations, List<Integer> jobTypes,
                                    Integer minSalary, Integer maxSalary) {
        return !keyword.isEmpty() || !cities.isEmpty() || !categoryIds.isEmpty() || !educations.isEmpty()
                || !jobTypes.isEmpty() || minSalary != null || maxSalary != null;
    }

    private List<Long> expandCategoryIds(List<Long> categoryIds) {
        if (categoryIds.isEmpty()) {
            return categoryIds;
        }
        Set<Long> expanded = new LinkedHashSet<>(categoryIds);
        List<JobCategory> all = jobCategoryMapper.selectList(new LambdaQueryWrapper<JobCategory>()
                .select(JobCategory::getId, JobCategory::getParentId));
        boolean changed;
        do {
            changed = false;
            for (JobCategory category : all) {
                if (category.getParentId() != null && expanded.contains(category.getParentId())
                        && expanded.add(category.getId())) {
                    changed = true;
                }
            }
        } while (changed);
        return new ArrayList<>(expanded);
    }

    private List<String> keywordParts(String keyword) {
        String value = trimToEmpty(keyword).toLowerCase();
        if (value.isEmpty()) {
            return Collections.emptyList();
        }
        Set<String> parts = new LinkedHashSet<>();
        parts.add(value);
        String shortName = value.replace("工程师", "").replace("实习生", "")
                .replace("岗位", "").replace("职位", "").trim();
        if (!shortName.isEmpty()) {
            parts.add(shortName);
        }
        for (String token : Arrays.asList("java", "后端", "前端", "开发", "测试", "算法", "数据", "产品",
                "运营", "设计", "ui", "市场", "销售", "财务", "人力", "客服", "运维", "安全")) {
            if (value.contains(token)) {
                parts.add(token);
            }
        }
        return new ArrayList<>(parts);
    }

    private List<String> splitStrings(String text) {
        String value = trimToEmpty(text);
        if (value.isEmpty()) {
            return Collections.emptyList();
        }
        return Arrays.stream(value.split("[,，]"))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .distinct()
                .collect(Collectors.toList());
    }

    private List<Long> splitLongs(String text) {
        List<Long> list = new ArrayList<>();
        for (String part : splitStrings(text)) {
            try {
                list.add(Long.valueOf(part));
            } catch (NumberFormatException ignored) {
            }
        }
        return list;
    }

    private List<Integer> splitIntegers(String text) {
        List<Integer> list = new ArrayList<>();
        for (String part : splitStrings(text)) {
            try {
                list.add(Integer.valueOf(part));
            } catch (NumberFormatException ignored) {
            }
        }
        return list;
    }

    private String trimToEmpty(String text) {
        return text == null ? "" : text.trim();
    }

    private int compareDateDesc(Date a, Date b) {
        if (a == null && b == null) {
            return 0;
        }
        if (a == null) {
            return 1;
        }
        if (b == null) {
            return -1;
        }
        return b.compareTo(a);
    }

    /** 将职位实体转为可扩展的 Map，便于附带企业名称等冗余字段 */
    private Map<String, Object> beanToMap(JobPost post) {
        Map<String, Object> map = new HashMap<>(24);
        map.put("id", post.getId());
        map.put("enterpriseId", post.getEnterpriseId());
        map.put("hrId", post.getHrId());
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
