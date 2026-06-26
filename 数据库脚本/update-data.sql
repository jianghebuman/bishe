USE campus_recruitment;

-- New tables introduced after the original server-side seed snapshot.
CREATE TABLE IF NOT EXISTS `job_seeker_post` (
  `id`             bigint       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `student_id`     bigint       NOT NULL COMMENT '学生ID',
  `resume_id`      bigint                DEFAULT NULL COMMENT '关联在线简历ID',
  `title`          varchar(120) NOT NULL COMMENT '求职标题',
  `expect_post`    varchar(80)           DEFAULT NULL COMMENT '期望岗位',
  `expect_city`    varchar(80)           DEFAULT NULL COMMENT '期望城市',
  `expect_salary`  varchar(40)           DEFAULT NULL COMMENT '期望薪资',
  `intro`          text                  COMMENT '自我介绍',
  `status`         tinyint      NOT NULL DEFAULT 1 COMMENT '状态：1展示0下架',
  `view_count`     int          NOT NULL DEFAULT 0 COMMENT '浏览量',
  `create_time`    datetime              DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`    datetime              DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`        tinyint      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_seeker_student` (`student_id`),
  KEY `idx_seeker_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='求职栏信息表';

CREATE TABLE IF NOT EXISTS `chat_message` (
  `id`              bigint        NOT NULL AUTO_INCREMENT COMMENT '主键',
  `from_user_id`    bigint        NOT NULL COMMENT '发送方用户ID',
  `from_role`       varchar(20)   NOT NULL COMMENT '发送方角色：STUDENT/ENTERPRISE',
  `to_user_id`      bigint        NOT NULL COMMENT '接收方用户ID',
  `to_role`         varchar(20)   NOT NULL COMMENT '接收方角色：STUDENT/ENTERPRISE',
  `job_id`          bigint                 DEFAULT NULL COMMENT '关联职位ID',
  `seeker_post_id`  bigint                 DEFAULT NULL COMMENT '关联求职信息ID',
  `content`         varchar(1000) NOT NULL COMMENT '消息内容',
  `is_read`         tinyint       NOT NULL DEFAULT 0 COMMENT '是否已读：0否1是',
  `create_time`     datetime               DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`     datetime               DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`         tinyint       NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_chat_from` (`from_role`,`from_user_id`),
  KEY `idx_chat_to` (`to_role`,`to_user_id`),
  KEY `idx_chat_pair_time` (`from_user_id`,`to_user_id`,`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='在线沟通消息表';

-- New permissions and role mappings.
INSERT INTO `permission` (`id`,`perm_code`,`perm_name`,`perm_type`,`parent_id`,`path`,`sort`)
SELECT * FROM (
  SELECT 33 AS `id`,'admin:seeker-post' AS `perm_code`,'求职信息管理' AS `perm_name`,'MENU' AS `perm_type`,0 AS `parent_id`,'/admin/seeker-post' AS `path`,14 AS `sort`
  UNION ALL
  SELECT 34,'enterprise:chat','在线沟通','MENU',0,'/enterprise/chat',9
  UNION ALL
  SELECT 35,'student:seeker-post','我的求职信息','MENU',0,'/student/seeker-post',12
  UNION ALL
  SELECT 36,'student:chat','在线沟通','MENU',0,'/student/chat',13
) AS src
WHERE NOT EXISTS (SELECT 1 FROM `permission` p WHERE p.`id` = src.`id`);

INSERT INTO `role_permission` (`role_id`,`permission_id`)
SELECT * FROM (
  SELECT 1 AS role_id, 33 AS permission_id
  UNION ALL SELECT 2,34
  UNION ALL SELECT 3,35
  UNION ALL SELECT 3,36
) AS src
WHERE NOT EXISTS (
  SELECT 1
  FROM `role_permission` rp
  WHERE rp.`role_id` = src.`role_id` AND rp.`permission_id` = src.`permission_id`
);

-- Additional job categories and dictionary items.
INSERT INTO `job_category` (`id`,`name`,`parent_id`,`sort`)
SELECT * FROM (
  SELECT 27 AS `id`,'客户服务' AS `name`,3 AS `parent_id`,3 AS `sort`
  UNION ALL SELECT 28,'生活服务',3,4
  UNION ALL SELECT 29,'新媒体运营',2,6
  UNION ALL SELECT 30,'门店零售',3,5
) AS src
WHERE NOT EXISTS (SELECT 1 FROM `job_category` jc WHERE jc.`id` = src.`id`);

INSERT INTO `sys_dict` (`dict_type`,`dict_label`,`dict_value`,`sort`)
SELECT * FROM (
  SELECT 'industry' AS `dict_type`,'生活服务' AS `dict_label`,'生活服务' AS `dict_value`,10 AS `sort`
  UNION ALL SELECT 'industry','酒店餐饮','酒店餐饮',11
  UNION ALL SELECT 'industry','零售连锁','零售连锁',12
  UNION ALL SELECT 'city','天津','天津',13
  UNION ALL SELECT 'city','厦门','厦门',14
  UNION ALL SELECT 'city','青岛','青岛',15
  UNION ALL SELECT 'welfare','包吃','包吃',11
  UNION ALL SELECT 'welfare','住宿补贴','住宿补贴',12
  UNION ALL SELECT 'welfare','晋升培训','晋升培训',13
) AS src
WHERE NOT EXISTS (
  SELECT 1
  FROM `sys_dict` d
  WHERE d.`dict_type` = src.`dict_type`
    AND d.`dict_label` = src.`dict_label`
    AND d.`dict_value` = src.`dict_value`
);

-- New seed records keyed by explicit ids.
INSERT INTO `job_seeker_post` (`id`,`student_id`,`resume_id`,`title`,`expect_post`,`expect_city`,`expect_salary`,`intro`,`status`,`view_count`)
SELECT * FROM (
  SELECT 1 AS `id`,1 AS `student_id`,1 AS `resume_id`,'计算机本科求Java后端开发实习' AS `title`,'Java后端开发' AS `expect_post`,'北京,杭州' AS `expect_city`,'8K-12K' AS `expect_salary`,'熟悉Spring Boot、MySQL和Redis，有校园招聘系统和论坛项目经验，希望参与真实业务后端开发。' AS `intro`,1 AS `status`,42 AS `view_count`
  UNION ALL SELECT 2,4,4,'人工智能方向学生寻找算法实习','机器学习算法实习','深圳,广州','10K-15K','关注机器学习、数据挖掘和大模型应用，做过文本分类和推荐系统课程项目。',1,31
  UNION ALL SELECT 3,7,7,'视觉传达专业求UI/交互设计岗位','UI设计师','上海,杭州','6K-10K','擅长Figma、PS和移动端界面设计，可提供作品集，期待参与产品设计与交互优化。',1,18
  UNION ALL SELECT 4,2,2,'软件工程学生求前端开发实习','前端开发实习生','北京,深圳','7K-11K','熟悉Vue 3、Element Plus和数据可视化，参与过校园招聘系统前端页面开发，期望加入业务前端团队。',1,27
  UNION ALL SELECT 5,3,3,'市场营销本科寻找用户运营岗位','用户运营专员','上海,广州','6K-9K','做过校园品牌推广和社群活动策划，擅长活动复盘、用户调研和内容运营。',1,36
  UNION ALL SELECT 6,5,5,'电子信息学生求测试开发实习','测试开发实习生','北京,深圳','7K-12K','掌握Python、接口测试和基础嵌入式开发，做过接口自动化测试平台课程项目。',1,22
  UNION ALL SELECT 7,6,6,'工商管理学生求产品运营/HR方向','产品运营/人力资源','成都,武汉','5K-8K','有就业服务社群运营经历，熟悉活动组织、用户沟通和招聘流程，期望从事运营或HR方向。',1,19
  UNION ALL SELECT 8,8,8,'软件工程大二寻找后端暑期实习','后端开发实习生','南京,苏州','3K-5K','熟悉Java基础、Spring Boot和MySQL，完成过图书管理系统，希望获得暑期实习机会。',1,24
) AS src
WHERE NOT EXISTS (SELECT 1 FROM `job_seeker_post` jsp WHERE jsp.`id` = src.`id`);

INSERT INTO `chat_message` (`id`,`from_user_id`,`from_role`,`to_user_id`,`to_role`,`job_id`,`seeker_post_id`,`content`,`is_read`)
SELECT * FROM (
  SELECT 1 AS `id`,2 AS `from_user_id`,'ENTERPRISE' AS `from_role`,1 AS `to_user_id`,'STUDENT' AS `to_role`,NULL AS `job_id`,1 AS `seeker_post_id`,'你好，我们看到你的求职信息，想了解一下你最近是否方便参加线上沟通？' AS `content`,0 AS `is_read`
  UNION ALL
  SELECT 2,1,'STUDENT',2,'ENTERPRISE',1,NULL,'您好，我想咨询腾讯后端开发工程师岗位，对实习时长有要求吗？',1
) AS src
WHERE NOT EXISTS (SELECT 1 FROM `chat_message` cm WHERE cm.`id` = src.`id`);

INSERT INTO `announcement` (`id`,`category_id`,`title`,`summary`,`content`,`author`,`view_count`,`is_top`,`status`,`publish_time`)
SELECT * FROM (
  SELECT 9 AS `id`,3 AS `category_id`,'简历门诊与一对一求职辅导预约开放' AS `title`,'针对秋招同学开放简历一对一优化服务。' AS `summary`,'<p>本周起，校就业指导中心开放简历门诊预约，帮助同学梳理项目亮点与岗位匹配度。</p>' AS `content`,'就业指导中心' AS `author`,128 AS `view_count`,0 AS `is_top`,1 AS `status`,'2026-03-09 10:00:00' AS `publish_time`
  UNION ALL SELECT 10,2,'校企联合开展Java后端专场招聘','多家企业面向后端开发岗位集中放出需求。','<p>本轮专场招聘覆盖Java后端、测试开发与中间件开发方向，欢迎相关专业同学投递。</p>','就业办',144,0,1,'2026-03-10 10:00:00'
  UNION ALL SELECT 11,4,'学院组织毕业生模拟面试活动','邀请企业HR现场点评表达与答辩。','<p>学院将组织模拟面试与群面训练，帮助毕业生提升现场表达和临场反应能力。</p>','校园新闻中心',88,0,1,'2026-03-11 10:00:00'
  UNION ALL SELECT 12,1,'基层就业与西部计划政策说明','解读基层就业、三支一扶和西部计划支持。','<p>就业办整理了基层就业支持政策、补贴方向及报名时间，建议有意向的同学关注。</p>','就业办',104,1,1,'2026-03-12 10:00:00'
) AS src
WHERE NOT EXISTS (SELECT 1 FROM `announcement` a WHERE a.`id` = src.`id`);

INSERT INTO `campus_talk` (`id`,`title`,`enterprise_id`,`company_name`,`talk_time`,`location`,`content`,`sign_count`,`status`)
SELECT * FROM (
  SELECT 7 AS `id`,'字节跳动产品与后端宣讲会' AS `title`,1 AS `enterprise_id`,'字节跳动科技有限公司' AS `company_name`,'2026-04-20 19:00:00' AS `talk_time`,'大学生活动中心A厅' AS `location`,'围绕产品协作、后端服务和成长路径展开。' AS `content`,58 AS `sign_count`,1 AS `status`
  UNION ALL SELECT 8,'腾讯数据分析与算法分享',2,'腾讯科技有限公司','2026-04-24 19:00:00','信息楼三楼报告厅','聚焦数据平台、推荐系统与校招流程。',52,1
  UNION ALL SELECT 9,'海纳金融科技校招说明会',7,'海纳金融科技有限公司','2026-04-26 19:00:00','线上会议室','介绍风控、数据产品与研发岗位。',27,1
  UNION ALL SELECT 10,'美团设计与前端联合宣讲',5,'美团科技有限公司','2026-05-02 19:00:00','艺术设计学院报告厅','覆盖设计、前端与产品岗位。',33,1
  UNION ALL SELECT 11,'灵犀数据科技 AI 应用宣讲会',16,'灵犀数据科技有限公司','2026-05-08 19:00:00','信息楼三楼报告厅','聚焦数据中台、AI 应用和产品成长路径。',29,1
  UNION ALL SELECT 12,'清和校园服务运营宣讲会',17,'清和校园服务有限公司','2026-05-15 19:00:00','大学生活动中心B厅','介绍校园运营、活动执行与客户服务岗位。',21,1
  UNION ALL SELECT 13,'星桥零售校园管培生说明会',15,'星桥零售服务有限公司','2026-05-21 19:00:00','经管学院阶梯教室','讲解门店管理、零售数据分析和储备店长培养计划。',34,1
) AS src
WHERE NOT EXISTS (SELECT 1 FROM `campus_talk` ct WHERE ct.`id` = src.`id`);

INSERT INTO `job_fair` (`id`,`title`,`fair_time`,`location`,`host`,`content`,`company_count`,`job_count`,`sign_count`,`status`)
SELECT * FROM (
  SELECT 7 AS `id`,'2026春季互联网与人工智能双选会' AS `title`,'2026-04-20 09:00:00' AS `fair_time`,'学校体育馆主馆' AS `location`,'校就业指导中心' AS `host`,'聚焦前端、后端、算法、测试等技术岗位。' AS `content`,95 AS `company_count`,2600 AS `job_count`,540 AS `sign_count`,1 AS `status`
  UNION ALL SELECT 8,'教育科技与内容产品专场招聘会','2026-04-26 09:00:00','经管学院大厅','教育学院','面向课程产品、运营、教务与内容岗位。',48,860,240,1
  UNION ALL SELECT 9,'设计与新媒体校企对接会','2026-05-06 09:00:00','艺术设计学院展厅','艺术设计学院','覆盖视觉、交互、品牌与新媒体岗位。',36,520,180,1
  UNION ALL SELECT 10,'金融科技与数据分析招聘会','2026-05-12 09:00:00','信息楼一楼大厅','校就业指导中心','聚焦数据分析、风控、产品和后端岗位。',62,980,300,1
  UNION ALL SELECT 11,'人工智能与数据产品专场招聘会','2026-05-20 09:00:00','信息楼二楼大厅','校就业指导中心','聚焦数据分析、数据产品、AI 应用与运维岗位。',40,720,220,1
  UNION ALL SELECT 12,'生活服务与校园运营招聘会','2026-05-26 09:00:00','大学生活动中心前广场','后勤与就业办','面向校园服务、活动运营、客户支持等岗位。',28,360,156,1
  UNION ALL SELECT 13,'零售管理与新消费专场招聘会','2026-06-02 09:00:00','经管学院一楼大厅','经济管理学院','面向储备店长、零售运营、会员运营和数据分析岗位。',35,480,190,1
) AS src
WHERE NOT EXISTS (SELECT 1 FROM `job_fair` jf WHERE jf.`id` = src.`id`);

INSERT INTO `forum_post` (`id`,`student_id`,`author_name`,`title`,`content`,`category`,`view_count`,`like_count`,`comment_count`,`audit_status`,`status`)
SELECT * FROM (
  SELECT 9 AS `id`,1 AS `student_id`,'张三' AS `author_name`,'简历完整度提升了，分享下我的修改思路' AS `title`,'最近把简历从 68% 补到 92%，主要做了项目量化和成果提炼。' AS `content`,'经验分享' AS `category`,74 AS `view_count`,14 AS `like_count`,3 AS `comment_count`,1 AS `audit_status`,1 AS `status`
  UNION ALL SELECT 10,2,'李四','前端实习面试最常问哪些题','想整理一份面试题清单，欢迎大家补充。','求职交流',83,11,2,1,1
  UNION ALL SELECT 11,4,'赵六','算法岗二面复盘','把二面问到的动态规划和机器学习问题记下来，供大家参考。','经验分享',58,16,2,1,1
  UNION ALL SELECT 12,5,'孙七','Offer选择纠结中','两家 Offer 都不错，想听听大家怎么做决策。','Offer捷报',91,19,4,1,1
) AS src
WHERE NOT EXISTS (SELECT 1 FROM `forum_post` fp WHERE fp.`id` = src.`id`);

INSERT INTO `forum_comment` (`post_id`,`student_id`,`author_name`,`content`,`like_count`,`status`)
SELECT * FROM (
  SELECT 9 AS `post_id`,2 AS `student_id`,'李四' AS `author_name`,'量化成果这一步真的很关键，尤其是项目描述。' AS `content`,4 AS `like_count`,1 AS `status`
  UNION ALL SELECT 9,3,'王五','可以把简历关键词和岗位 JD 对齐一下。',2,1
  UNION ALL SELECT 10,1,'张三','基础题、浏览器原理、Vue 生态都要准备。',3,1
  UNION ALL SELECT 10,4,'赵六','补充一个常见题：前端性能优化怎么做。',2,1
  UNION ALL SELECT 11,2,'李四','动态规划题一定要结合题型分类整理。',2,1
  UNION ALL SELECT 11,5,'孙七','机器学习基础可以先过一遍概念再刷题。',3,1
  UNION ALL SELECT 12,1,'张三','建议从成长性、城市、团队和薪资四个维度看。',5,1
  UNION ALL SELECT 12,3,'王五','别忘了看转正概率和项目匹配度。',4,1
) AS src
WHERE NOT EXISTS (
  SELECT 1
  FROM `forum_comment` fc
  WHERE fc.`post_id` = src.`post_id`
    AND fc.`student_id` = src.`student_id`
    AND fc.`content` = src.`content`
);

INSERT INTO `message_feedback` (`user_id`,`user_type`,`user_name`,`content`,`contact`,`reply`,`reply_time`,`status`)
SELECT * FROM (
  SELECT 4 AS `user_id`,'STUDENT' AS `user_type`,'赵六' AS `user_name`,'希望增加算法岗专场筛选。' AS `content`,'zhaoliu@stu.com' AS `contact`,NULL AS `reply`,NULL AS `reply_time`,0 AS `status`
  UNION ALL SELECT 5,'STUDENT','孙七','附件简历上传后列表展示很直观。','sunqi@stu.com','感谢反馈，我们会持续优化体验。','2026-03-10 11:00:00',1
  UNION ALL SELECT 4,'ENTERPRISE','阿里云计算有限公司','企业端希望支持批量刷新岗位。','campus@aliyun.com',NULL,NULL,0
  UNION ALL SELECT NULL,'GUEST','访客','请问往届生是否可以参加招聘会？','guest@example.com','可以关注学校就业办后续通知。','2026-03-11 15:00:00',1
) AS src
WHERE NOT EXISTS (
  SELECT 1
  FROM `message_feedback` mf
  WHERE IFNULL(mf.`user_name`,'') = IFNULL(src.`user_name`,'')
    AND mf.`content` = src.`content`
);

UPDATE `message_feedback`
SET `reply`='感谢支持，简历预览功能后续会继续优化。',
    `reply_time`='2026-03-09 10:00:00'
WHERE `user_name`='李四'
  AND (`reply` IS NULL OR `reply` = '');

INSERT INTO `system_notice` (`receiver_id`,`receiver_type`,`title`,`content`,`notice_type`,`is_read`)
SELECT * FROM (
  SELECT 2 AS `receiver_id`,'STUDENT' AS `receiver_type`,'收藏岗位提醒' AS `title`,'您收藏的Java开发工程师岗位仍在招聘中。' AS `content`,'SYSTEM' AS `notice_type`,0 AS `is_read`
  UNION ALL SELECT 4,'STUDENT','投递状态更新','您投递的机器学习算法工程师简历已被查看。','APPLY',0
  UNION ALL SELECT 5,'STUDENT','面试邀请','美团邀请您参加UI视觉设计师线上面试。','INTERVIEW',0
  UNION ALL SELECT 7,'STUDENT','Offer通知','您收到美团测试开发工程师Offer。','OFFER',1
  UNION ALL SELECT 4,'ENTERPRISE','岗位审核通过','机器学习算法工程师岗位已通过审核。','AUDIT',0
  UNION ALL SELECT 5,'ENTERPRISE','新的简历投递','您发布的UI视觉设计师岗位收到新的投递。','APPLY',0
  UNION ALL SELECT 1,'ADMIN','待审核提醒','当前有企业认证和岗位待审核，请及时处理。','SYSTEM',0
  UNION ALL SELECT 3,'ADMIN','异常日志提醒','系统检测到一次登录失败记录，请关注。','SYSTEM',1
) AS src
WHERE NOT EXISTS (
  SELECT 1
  FROM `system_notice` sn
  WHERE sn.`receiver_id` = src.`receiver_id`
    AND sn.`receiver_type` = src.`receiver_type`
    AND sn.`title` = src.`title`
    AND sn.`content` = src.`content`
);

INSERT INTO `operation_log` (`user_id`,`user_type`,`user_name`,`log_type`,`module`,`operation`,`method`,`params`,`ip`,`status`,`error_msg`,`cost_time`)
SELECT * FROM (
  SELECT 1 AS `user_id`,'ADMIN' AS `user_type`,'admin' AS `user_name`,'OPERATION' AS `log_type`,'岗位审核' AS `module`,'审核通过岗位：Java开发工程师' AS `operation`,'PUT /admin/job/1/audit' AS `method`,'status=1' AS `params`,'127.0.0.1' AS `ip`,1 AS `status`,NULL AS `error_msg`,48 AS `cost_time`
  UNION ALL SELECT 4,'ENTERPRISE','alibaba','OPERATION','职位管理','发布岗位：机器学习算法工程师','POST /enterprise/job','title=机器学习算法工程师','127.0.0.1',1,NULL,66
  UNION ALL SELECT 4,'STUDENT','zhaoliu','LOGIN','登录','学生登录系统','POST /auth/login','role=STUDENT','127.0.0.1',1,NULL,31
  UNION ALL SELECT 9,'STUDENT','disabled_stu','LOGIN','登录','停用学生登录失败','POST /auth/login','role=STUDENT','127.0.0.1',0,'账号已被禁用，请联系管理员',29
  UNION ALL SELECT 1,'ADMIN','admin','ERROR','导出','导出岗位数据异常示例','GET /admin/export/job','{}','127.0.0.1',0,'演示异常日志',103
) AS src
WHERE NOT EXISTS (
  SELECT 1
  FROM `operation_log` ol
  WHERE ol.`user_id` <=> src.`user_id`
    AND ol.`user_type` = src.`user_type`
    AND ol.`module` = src.`module`
    AND ol.`operation` = src.`operation`
    AND ol.`method` = src.`method`
    AND ol.`params` <=> src.`params`
    AND ol.`status` = src.`status`
);

INSERT INTO `enterprise` (`id`,`username`,`password`,`company_name`,`credit_code`,`industry`,`scale`,`nature`,`address`,`city`,`logo`,`intro`,`welfare`,`contact_name`,`contact_phone`,`email`,`website`,`audit_status`,`status`)
SELECT * FROM (
  SELECT 13 AS `id`,'orangecafe' AS `username`,'$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO' AS `password`,'青橙餐饮管理有限公司' AS `company_name`,'913101001234567903' AS `credit_code`,'酒店餐饮' AS `industry`,'500-999人' AS `scale`,'民营企业' AS `nature`,'上海市徐汇区龙华中路' AS `address`,'上海' AS `city`,'/upload/image/seed/enterprise-company-logo-v2.png' AS `logo`,'经营校园周边轻食、咖啡和连锁餐饮门店，提供管培生与兼职岗位。' AS `intro`,'包吃,节日福利,晋升培训' AS `welfare`,'林店长' AS `contact_name`,'021-66112233' AS `contact_phone`,'hr@orangecafe.com' AS `email`,'https://www.orangecafe.com' AS `website`,2 AS `audit_status`,1 AS `status`
  UNION ALL SELECT 14,'haiyuehotel','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','海悦酒店集团有限公司','913502001234567904','生活服务','1000人以上','民营企业','厦门市思明区环岛路','厦门','/upload/image/seed/enterprise-fintech-logo-v2.png','覆盖酒店前厅、会务接待、客户服务和数字化运营岗位。','五险一金,住宿补贴,带薪年假,晋升培训','陈经理','0592-88776655','campus@haiyuehotel.com','https://www.haiyuehotel.com',2,1
  UNION ALL SELECT 15,'starretail','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','星桥零售服务有限公司','913702001234567905','零售连锁','1000人以上','民营企业','青岛市市南区香港中路','青岛','/upload/image/seed/enterprise-eduonline-logo-v2.png','提供便利零售、会员运营、门店管理和线上客服岗位。','五险一金,绩效奖金,节日福利,晋升培训','赵主管','0532-88996677','join@starretail.com','https://www.starretail.com',2,1
  UNION ALL SELECT 16,'lingxi','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','灵犀数据科技有限公司','913301001234567906','人工智能','100-499人','民营企业','杭州市余杭区人工智能小镇','杭州','/upload/image/seed/enterprise-greenmaker-logo-v2.png','专注行业数据中台、AI 应用和知识检索产品研发。','五险一金,年终奖,弹性工作,补充医疗','周经理','0571-66889977','campus@lingxi-data.com','https://www.lingxi-data.com',2,1
  UNION ALL SELECT 17,'qinghe','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','清和校园服务有限公司','914201001234567907','生活服务','100-499人','民营企业','武汉市洪山区珞喻路','武汉','/upload/image/seed/enterprise-oldcorp-logo-v2.png','面向高校提供就业服务、活动执行和校园运营支持。','五险一金,节日福利,晋升培训,带薪年假','陈主管','027-88997766','hr@qinghe-campus.com','https://www.qinghe-campus.com',2,1
  UNION ALL SELECT 18,'yunfan','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','云帆数字科技有限公司','913101001234567908','互联网','100-499人','民营企业','上海市浦东新区张江','上海','/upload/image/seed/enterprise-newcorp-logo-v2.png','专注校园 SaaS、数据看板和企业协同工具研发。','五险一金,弹性工作,年终奖,补充医疗','吴经理','021-55667788','campus@yunfan.com','https://www.yunfan.com',2,1
  UNION ALL SELECT 19,'lanqiao','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','蓝桥教育科技有限公司','913301001234567909','教育培训','500-999人','民营企业','杭州市滨江区物联网街','杭州','/upload/image/seed/enterprise-eduonline-logo-v2.png','面向高校提供在线课程、就业培训和实训平台。','五险一金,带薪年假,节日福利,晋升培训','沈经理','0571-12346678','campus@lanqiao-edu.com','https://www.lanqiao-edu.com',2,1
  UNION ALL SELECT 20,'qingmu','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','青木零售科技有限公司','911101001234567910','零售连锁','100-499人','民营企业','北京市丰台区总部基地','北京','/upload/image/seed/enterprise-company-logo-v2.png','专注连锁零售数字化运营和门店会员服务。','包吃,节日福利,绩效奖金,晋升培训','赵主管','010-77889966','hr@qingmu-retail.com','https://www.qingmu-retail.com',2,1
) AS src
WHERE NOT EXISTS (SELECT 1 FROM `enterprise` e WHERE e.`id` = src.`id`);

INSERT INTO `student` (`id`,`username`,`password`,`real_name`,`student_no`,`gender`,`college`,`major`,`grade`,`education`,`phone`,`email`,`status`)
SELECT * FROM (
  SELECT 10 AS `id`,'chenjie' AS `username`,'$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO' AS `password`,'陈洁' AS `real_name`,'2021007001' AS `student_no`,2 AS `gender`,'软件学院' AS `college`,'软件工程' AS `major`,'2021级' AS `grade`,'本科' AS `education`,'13900000010' AS `phone`,'chenjie@stu.com' AS `email`,1 AS `status`
  UNION ALL SELECT 11,'dengyi','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','邓一','2021008001',1,'人工智能学院','人工智能','2021级','本科','13900000011','dengyi@stu.com',1
  UNION ALL SELECT 12,'linyue','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','林悦','2021009001',2,'艺术设计学院','视觉传达设计','2021级','本科','13900000012','linyue@stu.com',1
  UNION ALL SELECT 13,'xuhao','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','许昊','2022001002',1,'电子信息学院','电子信息工程','2022级','本科','13900000013','xuhao@stu.com',1
  UNION ALL SELECT 14,'hanqing','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','韩晴','2020006001',2,'经济管理学院','工商管理','2020级','本科','13900000014','hanqing@stu.com',1
  UNION ALL SELECT 15,'yuchen','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','于晨','2021002002',1,'经济管理学院','市场营销','2021级','本科','13900000015','yuchen@stu.com',1
  UNION ALL SELECT 16,'wangjue','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','王觉','2021006002',1,'计算机学院','网络工程','2021级','本科','13900000016','wangjue@stu.com',1
  UNION ALL SELECT 17,'zhouxin','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','周欣','2021003003',2,'经济管理学院','信息管理与信息系统','2021级','本科','13900000017','zhouxin@stu.com',1
) AS src
WHERE NOT EXISTS (SELECT 1 FROM `student` s WHERE s.`id` = src.`id`);

INSERT INTO `resume` (`id`,`student_id`,`name`,`gender`,`birth`,`phone`,`email`,`college`,`major`,`education`,`skill_cert`,`award`,`self_eval`,`complete_rate`,`is_public`)
SELECT * FROM (
  SELECT 9 AS `id`,10 AS `student_id`,'陈洁' AS `name`,2 AS `gender`,'2003-06' AS `birth`,'13900000010' AS `phone`,'chenjie@stu.com' AS `email`,'软件学院' AS `college`,'软件工程' AS `major`,'本科' AS `education`,'CET-4、Java基础认证' AS `skill_cert`,'校级程序设计实践优秀奖' AS `award`,'熟悉 Spring Boot 和 Vue 生态，期待在真实业务中继续成长。' AS `self_eval`,83 AS `complete_rate`,1 AS `is_public`
  UNION ALL SELECT 10,11,'邓一',1,'2003-04','13900000011','dengyi@stu.com','人工智能学院','人工智能','本科','Python数据分析证书、CET-6','数学建模竞赛校级二等奖','关注机器学习和推荐系统，喜欢把模型落到产品里。',88,1
  UNION ALL SELECT 11,12,'林悦',2,'2003-08','13900000012','linyue@stu.com','艺术设计学院','视觉传达设计','本科','Figma、Photoshop认证','校园品牌视觉设计二等奖','擅长界面设计、交互表达和作品集整理。',79,1
  UNION ALL SELECT 12,13,'许昊',1,'2004-01','13900000013','xuhao@stu.com','电子信息学院','电子信息工程','本科','嵌入式开发实训证书','电子设计竞赛校赛一等奖','熟悉测试流程和基础运维，做事细致稳定。',81,1
  UNION ALL SELECT 13,14,'韩晴',2,'2002-10','13900000014','hanqing@stu.com','经济管理学院','工商管理','本科','人力资源管理师三级','优秀学生干部','有活动组织和社群运营经验，也希望接触产品和运营岗位。',76,1
  UNION ALL SELECT 14,15,'于晨',1,'2003-09','13900000015','yuchen@stu.com','经济管理学院','市场营销','本科','新媒体运营实训证书','校园新媒体传播大赛二等奖','擅长内容策划、活动传播和社群运营，愿意从运营岗位做起。',77,1
  UNION ALL SELECT 15,16,'王觉',1,'2003-05','13900000016','wangjue@stu.com','计算机学院','网络工程','本科','Linux基础认证、CET-4','校园服务器运维实践优秀奖','熟悉 Linux、Docker 和基础网络维护，期待在运维开发方向积累真实项目经验。',80,1
  UNION ALL SELECT 16,17,'周欣',2,'2003-11','13900000017','zhouxin@stu.com','经济管理学院','信息管理与信息系统','本科','Excel高级应用、SQL基础','数据分析课程设计一等奖','熟悉 Excel、SQL 和基础 Python 数据处理，做过用户调研和报表分析。',78,1
) AS src
WHERE NOT EXISTS (SELECT 1 FROM `resume` r WHERE r.`id` = src.`id`);

INSERT INTO `resume_education` (`resume_id`,`school`,`major`,`degree`,`start_date`,`end_date`,`description`)
SELECT * FROM (
  SELECT 9 AS `resume_id`,'某某大学' AS `school`,'软件工程' AS `major`,'本科' AS `degree`,'2021-09' AS `start_date`,'2025-06' AS `end_date`,'主修软件工程、数据库系统、Web开发和软件项目管理。' AS `description`
  UNION ALL SELECT 10,'某某大学','人工智能','本科','2021-09','2025-06','主修机器学习、深度学习、Python数据分析与推荐系统。'
  UNION ALL SELECT 11,'某某大学','视觉传达设计','本科','2021-09','2025-06','主修界面设计、品牌视觉、用户体验和交互原型。'
  UNION ALL SELECT 12,'某某大学','电子信息工程','本科','2022-09','2026-06','主修数字电路、单片机、嵌入式系统和测试基础。'
  UNION ALL SELECT 13,'某某大学','工商管理','本科','2020-09','2024-06','主修组织行为学、运营管理、人力资源管理等课程。'
  UNION ALL SELECT 14,'某某大学','市场营销','本科','2021-09','2025-06','主修市场调研、品牌策划、消费者行为和新媒体营销。'
  UNION ALL SELECT 15,'某某大学','网络工程','本科','2021-09','2025-06','主修计算机网络、操作系统、Linux 运维和网络安全基础。'
  UNION ALL SELECT 16,'某某大学','信息管理与信息系统','本科','2021-09','2025-06','主修信息系统分析、数据统计、商业分析和项目管理。'
) AS src
WHERE NOT EXISTS (
  SELECT 1
  FROM `resume_education` re
  WHERE re.`resume_id` = src.`resume_id`
    AND re.`school` = src.`school`
    AND re.`major` = src.`major`
);

INSERT INTO `job_seeker_post` (`id`,`student_id`,`resume_id`,`title`,`expect_post`,`expect_city`,`expect_salary`,`intro`,`status`,`view_count`)
SELECT * FROM (
  SELECT 9 AS `id`,10 AS `student_id`,9 AS `resume_id`,'软件工程学生求后端开发实习' AS `title`,'后端开发实习生' AS `expect_post`,'杭州,武汉' AS `expect_city`,'7K-12K' AS `expect_salary`,'熟悉 Spring Boot、MySQL 和接口开发，做过校园服务平台后端模块。' AS `intro`,1 AS `status`,23 AS `view_count`
  UNION ALL SELECT 10,11,10,'人工智能学生寻找算法实习','机器学习算法实习','杭州,深圳','12K-18K','关注机器学习、推荐系统和大模型应用，希望参与算法研发。',1,29
  UNION ALL SELECT 11,12,11,'视觉传达学生求UI设计岗位','UI设计师','上海,杭州','6K-10K','擅长 Figma 与 PS，能够独立完成移动端界面和活动视觉稿。',1,16
  UNION ALL SELECT 12,13,12,'电子信息学生求测试开发实习','测试开发实习生','北京,深圳','7K-11K','掌握 Python 基础和接口测试方法，希望进入测试开发方向。',1,21
  UNION ALL SELECT 13,14,13,'经管学生求运营/产品岗位','运营/产品','上海,成都','5K-9K','做过社群运营和活动策划，沟通能力和执行力都比较强。',1,25
  UNION ALL SELECT 14,15,14,'市场营销学生求新媒体运营实习','新媒体运营','广州,长沙','5K-8K','熟悉内容策划、活动传播和用户互动，愿意从运营岗位做起。',1,18
  UNION ALL SELECT 15,16,15,'计算机学生求运维开发实习','运维开发实习生','北京,杭州','7K-11K','熟悉 Linux、Docker 和基础网络配置，做过校园服务器维护与部署实践。',1,17
  UNION ALL SELECT 16,17,16,'经管学生寻找数据分析岗位','数据分析实习生','上海,深圳','8K-12K','熟悉 Excel、SQL 和基础 Python 数据处理，做过用户调研和报表分析。',1,14
) AS src
WHERE NOT EXISTS (SELECT 1 FROM `job_seeker_post` jsp WHERE jsp.`id` = src.`id`);

INSERT INTO `job_post` (`id`,`enterprise_id`,`category_id`,`title`,`job_type`,`recruit_num`,`city`,`salary_min`,`salary_max`,`education`,`major_require`,`experience`,`duty`,`requirement`,`welfare`,`audit_status`,`audit_remark`,`status`,`view_count`,`apply_count`,`publish_time`)
SELECT * FROM (
  SELECT 29 AS `id`,13 AS `enterprise_id`,28 AS `category_id`,'校园咖啡店服务员' AS `title`,2 AS `job_type`,12 AS `recruit_num`,'上海' AS `city`,3 AS `salary_min`,5 AS `salary_max`,'不限' AS `education`,'不限' AS `major_require`,'在校生' AS `experience`,'负责点单、出品协助、门店卫生和顾客引导。' AS `duty`,'沟通自然，能接受排班，每周到岗3天以上。' AS `requirement`,'包吃,节日福利,晋升培训' AS `welfare`,1 AS `audit_status`,NULL AS `audit_remark`,1 AS `status`,188 AS `view_count`,12 AS `apply_count`,'2026-03-29 09:00:00' AS `publish_time`
  UNION ALL SELECT 30,13,28,'餐饮门店管培生',1,8,'上海',5,8,'大专','不限','应届','轮岗学习门店运营、排班管理、成本控制和服务标准。','责任心强，愿意从一线岗位学习门店管理。','五险一金,包吃,晋升培训',1,NULL,1,176,10,'2026-03-30 09:00:00'
  UNION ALL SELECT 31,13,29,'新媒体运营实习生',2,5,'上海',3,5,'本科','新闻传播/市场营销/不限','在校生','负责短视频脚本、图文内容、账号互动和活动复盘。','熟悉常见内容平台，有拍摄剪辑或文案经验优先。','实习津贴,节日福利,弹性工作',1,NULL,1,168,9,'2026-03-31 09:00:00'
  UNION ALL SELECT 32,14,27,'前台接待实习生',2,10,'厦门',3,4,'大专','旅游管理/酒店管理/不限','在校生','负责入住接待、咨询答复、会务引导和客户信息录入。','形象良好，普通话标准，服务意识强。','实习津贴,住宿补贴,晋升培训',1,NULL,1,160,8,'2026-04-01 09:00:00'
  UNION ALL SELECT 33,14,27,'客服专员',1,8,'厦门',5,8,'大专','不限','应届','负责客户咨询、投诉记录、服务回访和工单跟进。','表达清晰，情绪稳定，能熟练使用办公软件。','五险一金,住宿补贴,带薪年假',1,NULL,1,152,7,'2026-04-02 09:00:00'
  UNION ALL SELECT 34,14,11,'会务运营助理',1,4,'厦门',5,8,'本科','会展/旅游/工商管理相关','应届','协助会场布置、嘉宾接待、物料统筹和现场执行。','执行力强，能适应活动期间弹性排班。','五险一金,绩效奖金,晋升培训',1,NULL,1,146,6,'2026-04-03 09:00:00'
  UNION ALL SELECT 35,15,30,'便利店储备店长',1,10,'青岛',6,9,'大专','不限','应届','负责门店商品陈列、库存盘点、班次管理和销售达成。','愿意从门店一线成长，数据意识和责任心强。','五险一金,绩效奖金,晋升培训',1,NULL,1,182,11,'2026-04-04 09:00:00'
  UNION ALL SELECT 36,15,30,'门店兼职导购',2,15,'青岛',2,4,'不限','不限','在校生','负责顾客接待、商品补货、收银协助和活动推广。','时间稳定，服务态度好，每周可到岗3天以上。','实习津贴,节日福利,晋升培训',1,NULL,1,170,10,'2026-04-05 09:00:00'
  UNION ALL SELECT 37,15,27,'线上客服实习生',2,8,'青岛',3,4,'大专','不限','在校生','负责线上咨询回复、订单问题记录和客户满意度回访。','打字熟练，耐心细致，能接受早晚班轮换。','实习津贴,弹性工作,节日福利',1,NULL,1,156,8,'2026-04-06 09:00:00'
  UNION ALL SELECT 38,15,16,'零售数据分析助理',1,4,'青岛',6,10,'本科','统计学/市场营销/计算机相关','应届','负责门店销售报表、会员数据分析和运营建议输出。','熟悉Excel和SQL基础，有数据分析项目经验优先。','五险一金,绩效奖金,带薪年假',1,NULL,1,148,7,'2026-04-07 09:00:00'
  UNION ALL SELECT 39,16,26,'数据产品运营专员',1,3,'杭州',8,12,'本科','计算机/统计学/不限','应届','负责数据产品需求跟进、报表分析和运营支持。','熟悉Excel和SQL基础，对数据产品有兴趣。','五险一金,年终奖,弹性工作',1,NULL,1,92,4,'2026-04-08 09:00:00'
  UNION ALL SELECT 40,17,28,'校园服务运营专员',1,4,'武汉',5,8,'本科','不限','应届','负责校园活动报名、社群支持和现场执行。','沟通细致，能适应活动期出勤。','五险一金,节日福利,晋升培训',1,NULL,1,84,3,'2026-04-09 09:00:00'
  UNION ALL SELECT 41,18,26,'数据产品运营专员',1,4,'上海',8,12,'本科','计算机/统计学/数据科学','应届','负责需求梳理、数据报表整理和产品上线跟进。','熟悉 SQL 和 Excel，沟通理解能力好。','五险一金,弹性工作,年终奖',1,NULL,1,98,5,'2026-04-10 09:00:00'
  UNION ALL SELECT 42,19,29,'学习运营专员',1,4,'杭州',7,10,'本科','不限','应届','负责课程活动、学员社群和内容推广。','细致耐心，能做活动统筹。','五险一金,带薪年假,晋升培训',1,NULL,1,86,4,'2026-04-11 09:00:00'
  UNION ALL SELECT 43,20,30,'门店运营专员',1,5,'北京',6,9,'本科','不限','应届','负责门店数据整理、活动执行和会员服务。','表达沟通顺畅，能适应门店轮岗。','包吃,节日福利,晋升培训',1,NULL,1,82,3,'2026-04-12 09:00:00'
) AS src
WHERE NOT EXISTS (SELECT 1 FROM `job_post` jp WHERE jp.`id` = src.`id`);

-- Normalize avatars and logos for seeded demo accounts.
UPDATE `admin_user` SET `avatar` = '/upload/image/seed/admin-admin.png' WHERE `id` = 1;
UPDATE `admin_user` SET `avatar` = '/upload/image/seed/admin-jiuyeban.png' WHERE `id` = 2;
UPDATE `admin_user` SET `avatar` = '/upload/image/seed/admin-auditor.png' WHERE `id` = 3;
UPDATE `admin_user` SET `avatar` = '/upload/image/seed/admin-disabled-admin.png' WHERE `id` = 4;

UPDATE `student` SET `avatar` = '/upload/image/seed/student-student.png' WHERE `id` = 1;
UPDATE `student` SET `avatar` = '/upload/image/seed/student-lisi.png' WHERE `id` = 2;
UPDATE `student` SET `avatar` = '/upload/image/seed/student-wangwu.png' WHERE `id` = 3;
UPDATE `student` SET `avatar` = '/upload/image/seed/student-zhaoliu.png' WHERE `id` = 4;
UPDATE `student` SET `avatar` = '/upload/image/seed/student-sunqi.png' WHERE `id` = 5;
UPDATE `student` SET `avatar` = '/upload/image/seed/student-zhouba.png' WHERE `id` = 6;
UPDATE `student` SET `avatar` = '/upload/image/seed/student-wuyue.png' WHERE `id` = 7;
UPDATE `student` SET `avatar` = '/upload/image/seed/student-qianjiu.png' WHERE `id` = 8;
UPDATE `student` SET `avatar` = '/upload/image/seed/student-disabled-stu.png' WHERE `id` = 9;

UPDATE `enterprise` SET `logo` = '/upload/image/seed/enterprise-company-logo-v2.png' WHERE `id` = 1;
UPDATE `enterprise` SET `logo` = '/upload/image/seed/enterprise-tencent-logo-v2.png' WHERE `id` = 2;
UPDATE `enterprise` SET `logo` = '/upload/image/seed/enterprise-newcorp-logo-v2.png' WHERE `id` = 3;
UPDATE `enterprise` SET `logo` = '/upload/image/seed/enterprise-alibaba-logo-v2.png' WHERE `id` = 4;
UPDATE `enterprise` SET `logo` = '/upload/image/seed/enterprise-meituan-logo-v2.png' WHERE `id` = 5;
UPDATE `enterprise` SET `logo` = '/upload/image/seed/enterprise-eduonline-logo-v2.png' WHERE `id` = 6;
UPDATE `enterprise` SET `logo` = '/upload/image/seed/enterprise-fintech-logo-v2.png' WHERE `id` = 7;
UPDATE `enterprise` SET `logo` = '/upload/image/seed/enterprise-greenmaker-logo-v2.png' WHERE `id` = 8;
UPDATE `enterprise` SET `logo` = '/upload/image/seed/enterprise-oldcorp-logo-v2.png' WHERE `id` = 9;

-- Keep derived counters in sync with the richer seed set.
UPDATE `job_post` jp
SET `apply_count` = (
  SELECT COUNT(*)
  FROM `job_apply` ja
  WHERE ja.`job_id` = jp.`id`
    AND ja.`deleted` = 0
);

UPDATE `forum_post` fp
SET `comment_count` = (
  SELECT COUNT(*)
  FROM `forum_comment` fc
  WHERE fc.`post_id` = fp.`id`
    AND fc.`deleted` = 0
    AND fc.`status` = 1
);

UPDATE `campus_talk` ct
SET `sign_count` = GREATEST(
  ct.`sign_count`,
  (
    SELECT COUNT(*)
    FROM `activity_sign` s
    WHERE s.`activity_type` = 1
      AND s.`activity_id` = ct.`id`
      AND s.`deleted` = 0
      AND s.`sign_status` <> 3
  )
);

UPDATE `job_fair` jf
SET `sign_count` = GREATEST(
  jf.`sign_count`,
  (
    SELECT COUNT(*)
    FROM `activity_sign` s
    WHERE s.`activity_type` = 2
      AND s.`activity_id` = jf.`id`
      AND s.`deleted` = 0
      AND s.`sign_status` <> 3
  )
);
