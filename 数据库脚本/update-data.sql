USE campus_recruitment;

-- Enterprise HR account model and HR-scoped recruitment records.
CREATE TABLE IF NOT EXISTS `enterprise_hr` (
  `id`            bigint       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `enterprise_id` bigint       NOT NULL COMMENT '企业ID',
  `username`      varchar(50)  NOT NULL COMMENT '登录账号',
  `password`      varchar(100) NOT NULL COMMENT '密码(BCrypt)',
  `real_name`     varchar(50)           DEFAULT NULL COMMENT 'HR姓名',
  `phone`         varchar(20)           DEFAULT NULL COMMENT '联系电话',
  `email`         varchar(80)           DEFAULT NULL COMMENT '邮箱',
  `hr_role`       varchar(20)  NOT NULL DEFAULT 'STAFF' COMMENT 'HR角色：SUPERVISOR主管 STAFF普通',
  `status`        tinyint      NOT NULL DEFAULT 1 COMMENT '状态：1正常0禁用',
  `last_login`    datetime              DEFAULT NULL COMMENT '最后登录时间',
  `create_time`   datetime              DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`   datetime              DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`       tinyint      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_enterprise_hr_username` (`username`),
  KEY `idx_enterprise_hr_enterprise` (`enterprise_id`),
  KEY `idx_enterprise_hr_role` (`enterprise_id`,`hr_role`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='企业HR账号表';

ALTER TABLE `enterprise`
  MODIFY `username` varchar(50) DEFAULT NULL COMMENT '旧企业登录账号(兼容迁移)',
  MODIFY `password` varchar(100) DEFAULT NULL COMMENT '旧企业密码(兼容迁移)';

ALTER TABLE `job_post`
  ADD COLUMN IF NOT EXISTS `hr_id` bigint DEFAULT NULL COMMENT '负责HR账号ID' AFTER `enterprise_id`;
CREATE INDEX IF NOT EXISTS `idx_job_hr` ON `job_post` (`hr_id`);

ALTER TABLE `job_apply`
  ADD COLUMN IF NOT EXISTS `hr_id` bigint DEFAULT NULL COMMENT '负责HR账号ID' AFTER `enterprise_id`;
CREATE INDEX IF NOT EXISTS `idx_apply_hr` ON `job_apply` (`hr_id`);

ALTER TABLE `interview_notice`
  ADD COLUMN IF NOT EXISTS `hr_id` bigint DEFAULT NULL COMMENT '负责HR账号ID' AFTER `enterprise_id`;
CREATE INDEX IF NOT EXISTS `idx_notice_hr` ON `interview_notice` (`hr_id`);

ALTER TABLE `interview_feedback`
  ADD COLUMN IF NOT EXISTS `hr_id` bigint DEFAULT NULL COMMENT '负责HR账号ID' AFTER `enterprise_id`;

ALTER TABLE `offer_record`
  ADD COLUMN IF NOT EXISTS `hr_id` bigint DEFAULT NULL COMMENT '负责HR账号ID' AFTER `enterprise_id`;
CREATE INDEX IF NOT EXISTS `idx_offer_hr` ON `offer_record` (`hr_id`);

ALTER TABLE `talent_pool`
  ADD COLUMN IF NOT EXISTS `hr_id` bigint DEFAULT NULL COMMENT '负责HR账号ID' AFTER `enterprise_id`;
CREATE INDEX IF NOT EXISTS `idx_talent_hr` ON `talent_pool` (`hr_id`);

INSERT INTO `enterprise_hr` (`enterprise_id`,`username`,`password`,`real_name`,`phone`,`email`,`hr_role`,`status`)
SELECT e.`id`, e.`username`, e.`password`, e.`contact_name`, e.`contact_phone`, e.`email`, 'SUPERVISOR', e.`status`
FROM `enterprise` e
WHERE e.`username` IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM `enterprise_hr` hr WHERE hr.`enterprise_id` = e.`id`);

UPDATE `job_post` p
JOIN `enterprise_hr` hr ON hr.`enterprise_id` = p.`enterprise_id` AND hr.`hr_role` = 'SUPERVISOR' AND hr.`status` = 1
SET p.`hr_id` = hr.`id`
WHERE p.`hr_id` IS NULL;
UPDATE `job_apply` a
JOIN `enterprise_hr` hr ON hr.`enterprise_id` = a.`enterprise_id` AND hr.`hr_role` = 'SUPERVISOR' AND hr.`status` = 1
SET a.`hr_id` = hr.`id`
WHERE a.`hr_id` IS NULL;
UPDATE `interview_notice` n
JOIN `enterprise_hr` hr ON hr.`enterprise_id` = n.`enterprise_id` AND hr.`hr_role` = 'SUPERVISOR' AND hr.`status` = 1
SET n.`hr_id` = hr.`id`
WHERE n.`hr_id` IS NULL;
UPDATE `interview_feedback` f
JOIN `enterprise_hr` hr ON hr.`enterprise_id` = f.`enterprise_id` AND hr.`hr_role` = 'SUPERVISOR' AND hr.`status` = 1
SET f.`hr_id` = hr.`id`
WHERE f.`hr_id` IS NULL;
UPDATE `offer_record` o
JOIN `enterprise_hr` hr ON hr.`enterprise_id` = o.`enterprise_id` AND hr.`hr_role` = 'SUPERVISOR' AND hr.`status` = 1
SET o.`hr_id` = hr.`id`
WHERE o.`hr_id` IS NULL;
UPDATE `talent_pool` t
JOIN `enterprise_hr` hr ON hr.`enterprise_id` = t.`enterprise_id` AND hr.`hr_role` = 'SUPERVISOR' AND hr.`status` = 1
SET t.`hr_id` = hr.`id`
WHERE t.`hr_id` IS NULL;

-- Enterprise audit authority verification trace fields.
ALTER TABLE `enterprise_audit`
  ADD COLUMN IF NOT EXISTS `verify_source` varchar(120) DEFAULT NULL COMMENT '权威核验来源' AFTER `audit_time`,
  ADD COLUMN IF NOT EXISTS `verify_source_url` varchar(255) DEFAULT NULL COMMENT '权威核验来源地址' AFTER `verify_source`,
  ADD COLUMN IF NOT EXISTS `verify_time` datetime DEFAULT NULL COMMENT '权威核验时间' AFTER `verify_source_url`,
  ADD COLUMN IF NOT EXISTS `verify_company_name` varchar(120) DEFAULT NULL COMMENT '权威来源企业名称' AFTER `verify_time`,
  ADD COLUMN IF NOT EXISTS `verify_credit_code` varchar(60) DEFAULT NULL COMMENT '权威来源统一社会信用代码' AFTER `verify_company_name`,
  ADD COLUMN IF NOT EXISTS `verify_status` varchar(60) DEFAULT NULL COMMENT '权威来源登记状态' AFTER `verify_credit_code`,
  ADD COLUMN IF NOT EXISTS `verify_result` tinyint NOT NULL DEFAULT 0 COMMENT '核验结果：0未核验1一致2不一致3未接入或异常' AFTER `verify_status`,
  ADD COLUMN IF NOT EXISTS `verify_remark` varchar(255) DEFAULT NULL COMMENT '核验说明' AFTER `verify_result`,
  ADD COLUMN IF NOT EXISTS `verify_snapshot_hash` varchar(64) DEFAULT NULL COMMENT '权威返回快照SHA256' AFTER `verify_remark`;

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

CREATE TABLE IF NOT EXISTS `favorite_enterprise` (
  `id`            bigint   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `student_id`    bigint   NOT NULL COMMENT '学生ID',
  `enterprise_id` bigint   NOT NULL COMMENT '企业ID',
  `create_time`   datetime          DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  `update_time`   datetime          DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`       tinyint  NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_fav_enterprise_student` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='企业收藏表';

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

INSERT INTO `favorite_enterprise` (`student_id`,`enterprise_id`)
SELECT * FROM (
  SELECT 1 AS `student_id`,5 AS `enterprise_id`
  UNION ALL SELECT 1,13
  UNION ALL SELECT 2,4
  UNION ALL SELECT 2,6
  UNION ALL SELECT 3,8
  UNION ALL SELECT 3,16
  UNION ALL SELECT 4,7
  UNION ALL SELECT 5,10
  UNION ALL SELECT 6,12
  UNION ALL SELECT 7,14
  UNION ALL SELECT 8,9
) AS src
WHERE NOT EXISTS (
  SELECT 1
  FROM `favorite_enterprise` fe
  WHERE fe.`student_id` = src.`student_id`
    AND fe.`enterprise_id` = src.`enterprise_id`
    AND fe.`deleted` = 0
);

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

-- Portal list pagination data: keep enterprise, seeker, activity, news and forum pages filled through page 3.
INSERT INTO `enterprise` (`id`,`username`,`password`,`company_name`,`credit_code`,`industry`,`scale`,`nature`,`address`,`city`,`logo`,`intro`,`welfare`,`contact_name`,`contact_phone`,`email`,`website`,`audit_status`,`status`)
SELECT * FROM (
  SELECT 21 AS `id`,'zhiliancloud' AS `username`,'$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO' AS `password`,'智联云校园科技有限公司' AS `company_name`,'913201001234567921' AS `credit_code`,'互联网' AS `industry`,'100-499人' AS `scale`,'民营企业' AS `nature`,'南京市软件谷科创城' AS `address`,'南京' AS `city`,'/upload/image/seed/enterprise-newcorp-logo-v2.png' AS `logo`,'专注校园数字化、就业服务平台和实习协同系统研发。' AS `intro`,'五险一金,弹性工作,带薪年假' AS `welfare`,'顾经理' AS `contact_name`,'025-88220021' AS `contact_phone`,'campus@zhiliancloud.com' AS `email`,'https://www.zhiliancloud.com' AS `website`,2 AS `audit_status`,1 AS `status`
  UNION ALL SELECT 22,'envisioncampus','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','远景新能源科技有限公司','913205001234567922','新能源','500-999人','民营企业','苏州市工业园区星湖街','苏州','/upload/image/seed/enterprise-greenmaker-logo-v2.png','围绕新能源设备、储能系统和智能运维提供研发与现场工程岗位。','五险一金,年终奖,补充医疗','陆经理','0512-88002222','hr@envision-campus.com','https://www.envision-campus.com',2,1
  UNION ALL SELECT 23,'boyamedia','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','博雅传媒有限公司','914401001234567923','新媒体运营','100-499人','民营企业','广州市海珠区新港东路','广州','/upload/image/seed/enterprise-company-logo-v2.png','提供品牌内容、短视频运营、校园活动策划和账号增长服务。','绩效奖金,节日福利,带薪年假','梁主管','020-88002223','join@boyamedia.com','https://www.boyamedia.com',2,1
  UNION ALL SELECT 24,'tiangongim','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','天工智能制造有限公司','911201001234567924','制造业','1000人以上','民营企业','天津市滨海新区先进制造园','天津','/upload/image/seed/enterprise-oldcorp-logo-v2.png','面向智能产线、工业软件和设备测试提供校招岗位。','五险一金,住宿补贴,晋升培训','高经理','022-88002224','campus@tiangongim.com','https://www.tiangongim.com',2,1
  UNION ALL SELECT 25,'yinqiao','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','银桥金融服务有限公司','915001001234567925','金融','500-999人','民营企业','重庆市江北区金融街','重庆','/upload/image/seed/enterprise-fintech-logo-v2.png','专注普惠金融、支付风控、客户运营和数据分析服务。','五险一金,绩效奖金,补充医疗','杨经理','023-88002225','hr@yinqiao-fin.com','https://www.yinqiao-fin.com',2,1
  UNION ALL SELECT 26,'futurehealth','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','未来健康科技有限公司','913101001234567926','互联网','100-499人','民营企业','上海市杨浦区创智天地','上海','/upload/image/seed/enterprise-eduonline-logo-v2.png','建设健康管理SaaS、用户运营平台和医疗数据产品。','五险一金,弹性工作,带薪年假','蒋经理','021-88002226','campus@futurehealth.com','https://www.futurehealth.com',2,1
  UNION ALL SELECT 27,'huixue','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','慧学教育服务有限公司','915101001234567927','教育培训','500-999人','民营企业','成都市高新区天府三街','成都','/upload/image/seed/enterprise-eduonline-logo-v2.png','提供在线课程运营、教研产品和校园学习顾问岗位。','五险一金,节日福利,晋升培训','邱经理','028-88002227','join@huixue-edu.com','https://www.huixue-edu.com',2,1
  UNION ALL SELECT 28,'daguan','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','达观数据服务有限公司','913101001234567928','人工智能','100-499人','民营企业','上海市徐汇区漕河泾开发区','上海','/upload/image/seed/enterprise-greenmaker-logo-v2.png','围绕文档智能、企业知识库和数据标注平台开展研发。','五险一金,年终奖,弹性工作','许经理','021-88002228','campus@daguan-data.com','https://www.daguan-data.com',2,1
  UNION ALL SELECT 29,'nanhu','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','南湖软件有限公司','914201001234567929','计算机软件','100-499人','民营企业','武汉市东湖高新区软件园','武汉','/upload/image/seed/enterprise-newcorp-logo-v2.png','提供政企软件、移动应用和数据可视化项目交付岗位。','五险一金,带薪年假,补充医疗','冯经理','027-88002229','hr@nanhu-soft.com','https://www.nanhu-soft.com',2,1
  UNION ALL SELECT 30,'xinghetravel','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','星河文旅集团有限公司','913502001234567930','生活服务','1000人以上','民营企业','厦门市湖里区会展中心','厦门','/upload/image/seed/enterprise-company-logo-v2.png','覆盖文旅运营、酒店管理、活动策划和客户服务岗位。','五险一金,住宿补贴,节日福利','黄经理','0592-88002230','campus@xinghetravel.com','https://www.xinghetravel.com',2,1
  UNION ALL SELECT 31,'haiboec','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','海博电商科技有限公司','914401001234567931','电子商务','500-999人','民营企业','广州市天河区珠江新城','广州','/upload/image/seed/enterprise-meituan-logo-v2.png','面向跨境电商、内容运营、商家服务和数据运营招募新人。','五险一金,绩效奖金,带薪年假','宋经理','020-88002231','jobs@haiboec.com','https://www.haiboec.com',2,1
  UNION ALL SELECT 32,'robotworks','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','智造工坊机器人有限公司','914403001234567932','制造业','100-499人','民营企业','深圳市宝安区机器人产业园','深圳','/upload/image/seed/enterprise-greenmaker-logo-v2.png','研发协作机器人、自动化测试平台和产线数据采集系统。','五险一金,年终奖,免费班车','韩经理','0755-88002232','campus@robotworks.com','https://www.robotworks.com',2,1
  UNION ALL SELECT 33,'qingniaosec','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','青鸟安全科技有限公司','911101001234567933','计算机软件','100-499人','民营企业','北京市海淀区中关村软件园','北京','/upload/image/seed/enterprise-oldcorp-logo-v2.png','提供安全测试、等保咨询、攻防演练和安全开发岗位。','五险一金,补充医疗,弹性工作','马经理','010-88002233','hr@qingniaosec.com','https://www.qingniaosec.com',2,1
  UNION ALL SELECT 34,'lianghai','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','量海数据科技有限公司','913301001234567934','人工智能','100-499人','民营企业','杭州市滨江区物联网街','杭州','/upload/image/seed/enterprise-fintech-logo-v2.png','专注BI分析、数据治理和行业大模型评测平台。','五险一金,年终奖,带薪年假','叶经理','0571-88002234','campus@lianghai-data.com','https://www.lianghai-data.com',2,1
  UNION ALL SELECT 35,'qimingcs','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','启明星客户服务有限公司','911201001234567935','生活服务','500-999人','民营企业','天津市和平区南京路','天津','/upload/image/seed/enterprise-company-logo-v2.png','提供客户成功、售后支持、呼叫中心运营和服务质检岗位。','五险一金,绩效奖金,晋升培训','曹经理','022-88002235','join@qimingcs.com','https://www.qimingcs.com',2,1
  UNION ALL SELECT 36,'yunfanlogistics','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','云帆物流科技有限公司','913201001234567936','物流供应链','500-999人','民营企业','南京市江宁区空港物流园','南京','/upload/image/seed/enterprise-greenmaker-logo-v2.png','建设仓配调度、校园配送和供应链可视化平台。','五险一金,绩效奖金,交通补贴','程经理','025-88002236','campus@yunfan-logistics.com','https://www.yunfan-logistics.com',2,1
  UNION ALL SELECT 37,'huaxinchip','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','华芯微电子有限公司','913205001234567937','电子信息','1000人以上','民营企业','苏州市高新区科技城','苏州','/upload/image/seed/enterprise-oldcorp-logo-v2.png','面向芯片测试、嵌入式开发和工艺工程培养校招生。','五险一金,补充医疗,免费班车','周经理','0512-88002237','hr@huaxinchip.com','https://www.huaxinchip.com',2,1
  UNION ALL SELECT 38,'lanhaihealth','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','蓝海健康管理有限公司','913101001234567938','医疗健康','100-499人','民营企业','上海市浦东新区张江高科','上海','/upload/image/seed/enterprise-eduonline-logo-v2.png','提供健康数据运营、互联网医院产品和客户服务岗位。','五险一金,带薪年假,节日福利','沈经理','021-88002238','join@lanhaihealth.com','https://www.lanhaihealth.com',2,1
  UNION ALL SELECT 39,'haoranai','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','浩然智能科技有限公司','911101001234567939','人工智能','100-499人','民营企业','北京市朝阳区望京科技园','北京','/upload/image/seed/enterprise-newcorp-logo-v2.png','研发智能客服、知识检索和办公自动化产品。','五险一金,年终奖,弹性工作','魏经理','010-88002239','campus@haoran-ai.com','https://www.haoran-ai.com',2,1
  UNION ALL SELECT 40,'jinyuebank','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','金岳银行科技中心','913301001234567940','金融科技','1000人以上','国有企业','杭州市上城区钱江路','杭州','/upload/image/seed/enterprise-fintech-logo-v2.png','承担银行核心系统、移动金融和风控模型研发。','五险一金,年终奖,补充医疗','邵经理','0571-88002240','campus@jinyuebank.com','https://www.jinyuebank.com',2,1
  UNION ALL SELECT 41,'chengshiux','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','城市优选零售有限公司','914401001234567941','电子商务','500-999人','民营企业','广州市白云区云城西路','广州','/upload/image/seed/enterprise-meituan-logo-v2.png','面向社区零售、用户增长和商品运营招聘管培生。','五险一金,绩效奖金,餐补','潘经理','020-88002241','jobs@chengshiux.com','https://www.chengshiux.com',2,1
  UNION ALL SELECT 42,'mingdeedu','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','明德在线教育有限公司','915101001234567942','教育培训','100-499人','民营企业','成都市武侯区科华北路','成都','/upload/image/seed/enterprise-eduonline-logo-v2.png','开展职业教育课程、学习平台和校园社群运营。','五险一金,带薪年假,晋升培训','何经理','028-88002242','hr@mingdeedu.com','https://www.mingdeedu.com',2,1
  UNION ALL SELECT 43,'shuzhiurban','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','数智城市研究院有限公司','914201001234567943','计算机软件','500-999人','国有企业','武汉市洪山区光谷大道','武汉','/upload/image/seed/enterprise-newcorp-logo-v2.png','参与智慧园区、城市治理和公共服务平台建设。','五险一金,补充医疗,项目奖金','丁经理','027-88002243','campus@shuzhiurban.com','https://www.shuzhiurban.com',2,1
  UNION ALL SELECT 44,'beidoumap','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','北斗星图信息有限公司','914403001234567944','地理信息','100-499人','民营企业','深圳市南山区粤海街道','深圳','/upload/image/seed/enterprise-greenmaker-logo-v2.png','提供地图数据、位置服务和遥感应用研发岗位。','五险一金,弹性工作,带薪年假','罗经理','0755-88002244','join@beidoumap.com','https://www.beidoumap.com',2,1
  UNION ALL SELECT 45,'zhongyuanbuild','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','中原建科集团有限公司','914101001234567945','建筑工程','1000人以上','国有企业','郑州市郑东新区商务外环路','郑州','/upload/image/seed/enterprise-oldcorp-logo-v2.png','招募工程管理、BIM建模、造价咨询和安全管理方向学生。','五险一金,住宿补贴,项目津贴','袁经理','0371-88002245','campus@zybuild.com','https://www.zybuild.com',2,1
  UNION ALL SELECT 46,'haichuangbio','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','海创生物科技有限公司','913302001234567946','生物医药','100-499人','民营企业','宁波市高新区院士路','宁波','/upload/image/seed/enterprise-company-logo-v2.png','围绕体外诊断、实验室自动化和质量管理招募新人。','五险一金,补充医疗,带薪年假','孙经理','0574-88002246','hr@haichuangbio.com','https://www.haichuangbio.com',2,1
  UNION ALL SELECT 47,'rongshengauto','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','荣盛汽车电子有限公司','912201001234567947','汽车电子','500-999人','民营企业','长春市汽开区东风大街','长春','/upload/image/seed/enterprise-greenmaker-logo-v2.png','提供车载软件、测试验证和供应链质量工程岗位。','五险一金,免费班车,年终奖','崔经理','0431-88002247','campus@rongshengauto.com','https://www.rongshengauto.com',2,1
  UNION ALL SELECT 48,'xinyuegames','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','新跃互动娱乐有限公司','914401001234567948','互联网','100-499人','民营企业','广州市番禺区大学城','广州','/upload/image/seed/enterprise-company-logo-v2.png','面向游戏研发、运营发行、视觉设计和数据分析招募实习生。','弹性工作,绩效奖金,下午茶','曾经理','020-88002248','campus@xinyuegames.com','https://www.xinyuegames.com',2,1
  UNION ALL SELECT 49,'aoshengmaterials','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','奥盛新材料有限公司','913205001234567949','新材料','500-999人','民营企业','苏州市相城区高铁新城','苏州','/upload/image/seed/enterprise-oldcorp-logo-v2.png','聚焦高分子材料、质量检测和生产工艺优化。','五险一金,住宿补贴,餐补','余经理','0512-88002249','hr@aoshengmaterials.com','https://www.aoshengmaterials.com',2,1
  UNION ALL SELECT 50,'yuzhoucloud','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','宇舟云计算有限公司','913301001234567950','云计算','100-499人','民营企业','杭州市余杭区未来科技城','杭州','/upload/image/seed/enterprise-newcorp-logo-v2.png','提供云平台运维、DevOps、后端开发和售前工程岗位。','五险一金,弹性工作,认证补贴','金经理','0571-88002250','campus@yuzhoucloud.com','https://www.yuzhoucloud.com',2,1
  UNION ALL SELECT 51,'shengjingconsult','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','盛景管理咨询有限公司','911101001234567951','咨询服务','100-499人','民营企业','北京市西城区金融大街','北京','/upload/image/seed/enterprise-fintech-logo-v2.png','服务校园人才发展、组织诊断和数字化转型咨询项目。','五险一金,项目奖金,带薪年假','田经理','010-88002251','join@shengjingconsult.com','https://www.shengjingconsult.com',2,1
  UNION ALL SELECT 52,'qingchengenergy','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','清程能源科技有限公司','913101001234567952','新能源','100-499人','民营企业','上海市闵行区紫竹科学园','上海','/upload/image/seed/enterprise-greenmaker-logo-v2.png','从事充电运营、能源管理平台和碳资产数据服务。','五险一金,年终奖,补充医疗','贺经理','021-88002252','hr@qingchengenergy.com','https://www.qingchengenergy.com',2,1
  UNION ALL SELECT 53,'tengyunops','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','腾云运维服务有限公司','914403001234567953','IT服务','500-999人','民营企业','深圳市龙岗区坂田街道','深圳','/upload/image/seed/enterprise-newcorp-logo-v2.png','为政企客户提供运维监控、桌面支持和系统实施服务。','五险一金,值班补贴,晋升培训','戴经理','0755-88002253','campus@tengyunops.com','https://www.tengyunops.com',2,1
  UNION ALL SELECT 54,'pinzhiqa','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','品质云检测技术有限公司','913301001234567954','检测认证','100-499人','民营企业','杭州市萧山区信息港','杭州','/upload/image/seed/enterprise-company-logo-v2.png','提供软件测试、质量体系、自动化检测和客户交付岗位。','五险一金,项目奖金,带薪年假','方经理','0571-88002254','hr@pinzhiqa.com','https://www.pinzhiqa.com',2,1
  UNION ALL SELECT 55,'hejinghr','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','合景人力资源服务有限公司','913101001234567955','人力资源','100-499人','民营企业','上海市静安区南京西路','上海','/upload/image/seed/enterprise-company-logo-v2.png','提供招聘运营、员工关系、薪酬服务和校园项目助理岗位。','五险一金,节日福利,绩效奖金','许经理','021-88002255','jobs@hejinghr.com','https://www.hejinghr.com',2,1
  UNION ALL SELECT 56,'yuandaagri','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','远达智慧农业有限公司','914201001234567956','现代农业','500-999人','民营企业','武汉市东西湖区临空港大道','武汉','/upload/image/seed/enterprise-greenmaker-logo-v2.png','建设农业物联网、农产品供应链和数字农场解决方案。','五险一金,住宿补贴,餐补','卢经理','027-88002256','campus@yuandaagri.com','https://www.yuandaagri.com',2,1
  UNION ALL SELECT 57,'bailianretail','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','百联商业运营有限公司','913101001234567957','零售服务','1000人以上','国有企业','上海市黄浦区淮海中路','上海','/upload/image/seed/enterprise-meituan-logo-v2.png','招募门店运营、会员增长、采购管理和数据运营管培生。','五险一金,带薪年假,节日福利','顾经理','021-88002257','campus@bailianretail.com','https://www.bailianretail.com',2,1
  UNION ALL SELECT 58,'kunlunmedia','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','昆仑数字传媒有限公司','911101001234567958','新媒体运营','100-499人','民营企业','北京市通州区运河商务区','北京','/upload/image/seed/enterprise-company-logo-v2.png','开展品牌传播、直播电商、内容策划和短视频制作。','五险一金,绩效奖金,弹性工作','梁经理','010-88002258','join@kunlunmedia.com','https://www.kunlunmedia.com',2,1
  UNION ALL SELECT 59,'tianyuaviation','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','天宇航空服务有限公司','911201001234567959','交通运输','500-999人','民营企业','天津市东丽区空港经济区','天津','/upload/image/seed/enterprise-oldcorp-logo-v2.png','提供机场服务、运行调度、客户管理和安全保障岗位。','五险一金,交通补贴,晋升培训','侯经理','022-88002259','hr@tianyuaviation.com','https://www.tianyuaviation.com',2,1
  UNION ALL SELECT 60,'rongkeestate','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','融科产业园运营有限公司','913201001234567960','园区运营','500-999人','民营企业','南京市建邺区江东中路','南京','/upload/image/seed/enterprise-fintech-logo-v2.png','负责产业园招商运营、企业服务和活动策划。','五险一金,绩效奖金,通讯补贴','秦经理','025-88002260','campus@rongkeestate.com','https://www.rongkeestate.com',2,1
  UNION ALL SELECT 61,'juchenglegal','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','矩成法律科技有限公司','914401001234567961','法律科技','100-499人','民营企业','广州市越秀区东风中路','广州','/upload/image/seed/enterprise-newcorp-logo-v2.png','建设合同审查、案件管理和企业合规数字化工具。','五险一金,带薪年假,弹性工作','莫经理','020-88002261','jobs@juchenglegal.com','https://www.juchenglegal.com',2,1
  UNION ALL SELECT 62,'anxininsurance','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','安信保险服务有限公司','915001001234567962','金融','1000人以上','民营企业','重庆市渝中区解放碑','重庆','/upload/image/seed/enterprise-fintech-logo-v2.png','提供保险运营、理赔支持、数据分析和客户经理岗位。','五险一金,补充医疗,年终奖','夏经理','023-88002262','campus@anxininsurance.com','https://www.anxininsurance.com',2,1
  UNION ALL SELECT 63,'yihangrobot','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','翼航无人机科技有限公司','914403001234567963','智能制造','100-499人','民营企业','深圳市龙华区观澜科技园','深圳','/upload/image/seed/enterprise-greenmaker-logo-v2.png','研发行业无人机、飞控算法和巡检应用平台。','五险一金,项目奖金,免费班车','邓经理','0755-88002263','hr@yihangrobot.com','https://www.yihangrobot.com',2,1
  UNION ALL SELECT 64,'xingyanstudio','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','星岩设计工作室有限公司','913502001234567964','创意设计','100-499人','民营企业','厦门市思明区软件园二期','厦门','/upload/image/seed/enterprise-company-logo-v2.png','提供品牌设计、交互设计、空间视觉和项目执行岗位。','弹性工作,绩效奖金,带薪年假','叶经理','0592-88002264','join@xingyanstudio.com','https://www.xingyanstudio.com',2,1
) AS src
WHERE NOT EXISTS (SELECT 1 FROM `enterprise` e WHERE e.`id` = src.`id`);

INSERT INTO `student` (`id`,`username`,`password`,`real_name`,`student_no`,`gender`,`college`,`major`,`grade`,`education`,`phone`,`email`,`status`)
SELECT * FROM (
  SELECT 18 AS `id`,'liuyang' AS `username`,'$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO' AS `password`,'刘洋' AS `real_name`,'2021007018' AS `student_no`,1 AS `gender`,'计算机学院' AS `college`,'计算机科学与技术' AS `major`,'2021级' AS `grade`,'本科' AS `education`,'13900000018' AS `phone`,'liuyang@stu.com' AS `email`,1 AS `status`
  UNION ALL SELECT 19,'fangmin','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','方敏','2021007019',2,'软件学院','软件工程','2021级','本科','13900000019','fangmin@stu.com',1
  UNION ALL SELECT 20,'heyu','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','何宇','2021007020',1,'人工智能学院','人工智能','2021级','本科','13900000020','heyu@stu.com',1
  UNION ALL SELECT 21,'songke','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','宋可','2021007021',2,'艺术设计学院','视觉传达设计','2021级','本科','13900000021','songke@stu.com',1
  UNION ALL SELECT 22,'tangrui','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','唐睿','2021007022',1,'经济管理学院','市场营销','2021级','本科','13900000022','tangrui@stu.com',1
  UNION ALL SELECT 23,'guojia','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','郭佳','2021007023',2,'电子信息学院','电子信息工程','2021级','本科','13900000023','guojia@stu.com',1
  UNION ALL SELECT 24,'mazhe','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','马哲','2021007024',1,'计算机学院','网络工程','2021级','本科','13900000024','mazhe@stu.com',1
  UNION ALL SELECT 25,'xiaoran','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','肖然','2021007025',2,'经济管理学院','信息管理与信息系统','2021级','本科','13900000025','xiaoran@stu.com',1
  UNION ALL SELECT 26,'lvqing','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','吕晴','2021007026',2,'经济管理学院','工商管理','2021级','本科','13900000026','lvqing@stu.com',1
  UNION ALL SELECT 27,'penghao','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','彭浩','2021007027',1,'软件学院','软件工程','2021级','本科','13900000027','penghao@stu.com',1
  UNION ALL SELECT 28,'caixin','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','蔡欣','2021007028',2,'艺术设计学院','视觉传达设计','2021级','本科','13900000028','caixin@stu.com',1
  UNION ALL SELECT 29,'yuanbo','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','袁博','2021007029',1,'人工智能学院','人工智能','2021级','本科','13900000029','yuanbo@stu.com',1
  UNION ALL SELECT 30,'huzhe','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','胡哲','2021007030',1,'计算机学院','计算机科学与技术','2021级','本科','13900000030','huzhe@stu.com',1
  UNION ALL SELECT 31,'yinxin','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','尹欣','2021007031',2,'经济管理学院','市场营销','2021级','本科','13900000031','yinxin@stu.com',1
  UNION ALL SELECT 32,'luohan','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','罗瀚','2021007032',1,'电子信息学院','电子信息工程','2021级','本科','13900000032','luohan@stu.com',1
  UNION ALL SELECT 33,'shenyi','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','沈奕','2021007033',2,'软件学院','软件工程','2021级','本科','13900000033','shenyi@stu.com',1
  UNION ALL SELECT 34,'zhuoyu','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','卓雨','2021007034',2,'经济管理学院','信息管理与信息系统','2021级','本科','13900000034','zhuoyu@stu.com',1
  UNION ALL SELECT 35,'xiechen','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','谢晨','2021007035',1,'艺术设计学院','视觉传达设计','2021级','本科','13900000035','xiechen@stu.com',1
  UNION ALL SELECT 36,'duanlei','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','段磊','2021007036',1,'计算机学院','网络工程','2021级','本科','13900000036','duanlei@stu.com',1
) AS src
WHERE NOT EXISTS (SELECT 1 FROM `student` s WHERE s.`id` = src.`id`);

INSERT INTO `resume` (`id`,`student_id`,`name`,`gender`,`birth`,`phone`,`email`,`college`,`major`,`education`,`skill_cert`,`award`,`self_eval`,`complete_rate`,`is_public`)
SELECT * FROM (
  SELECT 17 AS `id`,18 AS `student_id`,'刘洋' AS `name`,1 AS `gender`,'2003-02' AS `birth`,'13900000018' AS `phone`,'liuyang@stu.com' AS `email`,'计算机学院' AS `college`,'计算机科学与技术' AS `major`,'本科' AS `education`,'CET-6、Java开发实训' AS `skill_cert`,'校级程序设计竞赛二等奖' AS `award`,'熟悉Java后端、接口设计和数据库建模，希望从后端开发岗位起步。' AS `self_eval`,84 AS `complete_rate`,1 AS `is_public`
  UNION ALL SELECT 18,19,'方敏',2,'2003-07','13900000019','fangmin@stu.com','软件学院','软件工程','本科','CET-4、Vue项目实训','软件工程课程设计优秀作品','熟悉Vue、Element Plus和前端工程化，关注用户体验。',82,1
  UNION ALL SELECT 19,20,'何宇',1,'2003-03','13900000020','heyu@stu.com','人工智能学院','人工智能','本科','Python数据分析、CET-6','数学建模校赛一等奖','关注NLP、推荐系统和数据挖掘，希望参与算法实习。',87,1
  UNION ALL SELECT 20,21,'宋可',2,'2003-09','13900000021','songke@stu.com','艺术设计学院','视觉传达设计','本科','Figma、Adobe认证','校园视觉设计大赛二等奖','擅长界面视觉、交互原型和活动页设计。',80,1
  UNION ALL SELECT 21,22,'唐睿',1,'2002-12','13900000022','tangrui@stu.com','经济管理学院','市场营销','本科','新媒体运营证书','市场调研课程优秀报告','熟悉内容策划、用户调研和活动复盘。',78,1
  UNION ALL SELECT 22,23,'郭佳',2,'2003-05','13900000023','guojia@stu.com','电子信息学院','电子信息工程','本科','接口测试实训、CET-4','电子设计竞赛校赛二等奖','做事细致，熟悉测试流程和基础自动化脚本。',81,1
  UNION ALL SELECT 23,24,'马哲',1,'2003-10','13900000024','mazhe@stu.com','计算机学院','网络工程','本科','Linux基础认证、Docker实训','校园网络维护优秀志愿者','熟悉Linux、容器和基础网络排障。',79,1
  UNION ALL SELECT 24,25,'肖然',2,'2003-01','13900000025','xiaoran@stu.com','经济管理学院','信息管理与信息系统','本科','SQL基础、Excel高级应用','商业分析课程设计一等奖','熟悉SQL、Excel和基础数据可视化。',80,1
  UNION ALL SELECT 25,26,'吕晴',2,'2002-11','13900000026','lvqing@stu.com','经济管理学院','工商管理','本科','人力资源管理师三级','优秀学生干部','有校园招聘协助和社团组织经验，期望HR方向。',77,1
  UNION ALL SELECT 26,27,'彭浩',1,'2003-06','13900000027','penghao@stu.com','软件学院','软件工程','本科','Java基础认证、CET-4','Web开发课程优秀项目','熟悉Spring Boot和MySQL，能独立完成小型管理系统。',83,1
  UNION ALL SELECT 27,28,'蔡欣',2,'2003-08','13900000028','caixin@stu.com','艺术设计学院','视觉传达设计','本科','Figma、Photoshop','校园海报设计一等奖','擅长视觉表达和组件化设计稿整理。',79,1
  UNION ALL SELECT 28,29,'袁博',1,'2003-04','13900000029','yuanbo@stu.com','人工智能学院','人工智能','本科','Python、机器学习实训','数据挖掘竞赛校级二等奖','希望在算法工程或数据分析方向积累实践。',86,1
  UNION ALL SELECT 29,30,'胡哲',1,'2003-02','13900000030','huzhe@stu.com','计算机学院','计算机科学与技术','本科','CET-6、Redis基础','蓝桥杯校赛二等奖','关注高并发后端和缓存系统。',85,1
  UNION ALL SELECT 30,31,'尹欣',2,'2003-12','13900000031','yinxin@stu.com','经济管理学院','市场营销','本科','短视频运营实训','校园营销策划三等奖','擅长内容运营、账号数据复盘和社群沟通。',76,1
  UNION ALL SELECT 31,32,'罗瀚',1,'2003-07','13900000032','luohan@stu.com','电子信息学院','电子信息工程','本科','嵌入式基础、接口测试','电子工艺实训优秀','希望进入测试开发或硬件测试方向。',78,1
  UNION ALL SELECT 32,33,'沈奕',2,'2003-05','13900000033','shenyi@stu.com','软件学院','软件工程','本科','Vue项目实训、CET-4','前端课程项目优秀奖','熟悉前端页面开发、组件封装和接口联调。',82,1
  UNION ALL SELECT 33,34,'卓雨',2,'2003-09','13900000034','zhuoyu@stu.com','经济管理学院','信息管理与信息系统','本科','SQL、Python数据处理','数据分析报告优秀奖','喜欢从业务问题出发做数据整理和分析。',81,1
  UNION ALL SELECT 34,35,'谢晨',1,'2003-11','13900000035','xiechen@stu.com','艺术设计学院','视觉传达设计','本科','Adobe认证、Figma','校园文创设计二等奖','关注交互体验和品牌视觉统一。',78,1
  UNION ALL SELECT 35,36,'段磊',1,'2003-06','13900000036','duanlei@stu.com','计算机学院','网络工程','本科','Linux、Shell脚本','校园机房维护优秀志愿者','熟悉基础运维、监控和脚本自动化。',79,1
) AS src
WHERE NOT EXISTS (SELECT 1 FROM `resume` r WHERE r.`id` = src.`id`);

INSERT INTO `resume_education` (`resume_id`,`school`,`major`,`degree`,`start_date`,`end_date`,`description`)
SELECT * FROM (
  SELECT 17 AS `resume_id`,'某某大学' AS `school`,'计算机科学与技术' AS `major`,'本科' AS `degree`,'2021-09' AS `start_date`,'2025-06' AS `end_date`,'主修Java程序设计、数据库系统、软件工程和计算机网络。' AS `description`
  UNION ALL SELECT 18,'某某大学','软件工程','本科','2021-09','2025-06','主修Web开发、软件测试、软件项目管理和前端框架。'
  UNION ALL SELECT 19,'某某大学','人工智能','本科','2021-09','2025-06','主修机器学习、自然语言处理、数据挖掘和概率统计。'
  UNION ALL SELECT 20,'某某大学','视觉传达设计','本科','2021-09','2025-06','主修界面设计、品牌视觉、交互原型和用户研究。'
  UNION ALL SELECT 21,'某某大学','市场营销','本科','2021-09','2025-06','主修市场调研、消费者行为、品牌策划和新媒体运营。'
  UNION ALL SELECT 22,'某某大学','电子信息工程','本科','2021-09','2025-06','主修数字电路、嵌入式系统、软件测试和信号处理。'
  UNION ALL SELECT 23,'某某大学','网络工程','本科','2021-09','2025-06','主修计算机网络、Linux运维、网络安全和云计算基础。'
  UNION ALL SELECT 24,'某某大学','信息管理与信息系统','本科','2021-09','2025-06','主修信息系统分析、SQL、数据统计和项目管理。'
) AS src
WHERE NOT EXISTS (
  SELECT 1 FROM `resume_education` re
  WHERE re.`resume_id` = src.`resume_id` AND re.`school` = src.`school` AND re.`major` = src.`major`
);

INSERT INTO `job_seeker_post` (`id`,`student_id`,`resume_id`,`title`,`expect_post`,`expect_city`,`expect_salary`,`intro`,`status`,`view_count`,`create_time`,`update_time`)
SELECT * FROM (
  SELECT 17 AS `id`,18 AS `student_id`,17 AS `resume_id`,'计算机学生求Java后端开发岗位' AS `title`,'Java后端开发' AS `expect_post`,'南京,杭州' AS `expect_city`,'8K-13K' AS `expect_salary`,'熟悉Spring Boot、MySQL和接口设计，期待参与企业级后端项目。' AS `intro`,1 AS `status`,26 AS `view_count`,'2026-04-21 09:00:00' AS `create_time`,'2026-04-21 09:00:00' AS `update_time`
  UNION ALL SELECT 18,19,18,'软件学院学生求前端开发实习','前端开发实习生','北京,深圳','7K-11K','熟悉Vue 3、组件化开发和Element Plus，能完成页面联调。',1,24,'2026-04-22 09:00:00','2026-04-22 09:00:00'
  UNION ALL SELECT 19,20,19,'人工智能学生寻找NLP算法实习','NLP算法实习生','上海,杭州','12K-18K','做过文本分类和知识库检索课程项目，希望参与算法研发。',1,31,'2026-04-23 09:00:00','2026-04-23 09:00:00'
  UNION ALL SELECT 20,21,20,'视觉传达学生求交互设计岗位','交互设计师','上海,广州','7K-12K','擅长界面视觉、交互流程和高保真原型设计。',1,19,'2026-04-24 09:00:00','2026-04-24 09:00:00'
  UNION ALL SELECT 21,22,21,'市场营销学生求内容运营岗位','内容运营','广州,深圳','6K-10K','有校园活动策划和短视频账号运营经验，执行力强。',1,22,'2026-04-25 09:00:00','2026-04-25 09:00:00'
  UNION ALL SELECT 22,23,22,'电子信息学生求测试开发岗位','测试开发','北京,天津','7K-12K','熟悉接口测试和Python脚本，希望进入测试开发方向。',1,20,'2026-04-26 09:00:00','2026-04-26 09:00:00'
  UNION ALL SELECT 23,24,23,'网络工程学生求运维开发实习','运维开发','杭州,南京','7K-11K','熟悉Linux、Docker和基础网络排障，愿意从运维开发做起。',1,18,'2026-04-27 09:00:00','2026-04-27 09:00:00'
  UNION ALL SELECT 24,25,24,'信管学生寻找数据分析实习','数据分析','上海,苏州','8K-12K','熟悉SQL、Excel和基础可视化，做过商业分析课程报告。',1,21,'2026-04-28 09:00:00','2026-04-28 09:00:00'
  UNION ALL SELECT 25,26,25,'工商管理学生求HR实习','人力资源','成都,重庆','5K-8K','有校园招聘协助和社团组织经历，沟通协调能力好。',1,16,'2026-04-29 09:00:00','2026-04-29 09:00:00'
  UNION ALL SELECT 26,27,26,'软件工程学生求后端实习','后端开发实习生','武汉,长沙','6K-10K','熟悉Java基础、Spring Boot和MySQL，完成过课程项目。',1,23,'2026-04-30 09:00:00','2026-04-30 09:00:00'
  UNION ALL SELECT 27,28,27,'设计学生求视觉设计岗位','视觉设计师','杭州,上海','6K-10K','擅长活动视觉、图标和移动端页面设计，可提供作品集。',1,17,'2026-05-01 09:00:00','2026-05-01 09:00:00'
  UNION ALL SELECT 28,29,28,'人工智能学生求数据分析岗位','数据分析实习生','北京,上海','9K-14K','熟悉Python数据处理和机器学习基础，愿意从数据岗位积累。',1,27,'2026-05-02 09:00:00','2026-05-02 09:00:00'
  UNION ALL SELECT 29,30,29,'计算机学生求高并发后端方向','后端开发','北京,杭州','10K-16K','关注缓存、消息队列和服务性能优化，项目基础扎实。',1,28,'2026-05-03 09:00:00','2026-05-03 09:00:00'
  UNION ALL SELECT 30,31,30,'营销学生求新媒体运营实习','新媒体运营','广州,厦门','5K-8K','熟悉内容策划和账号数据复盘，能稳定输出运营素材。',1,15,'2026-05-04 09:00:00','2026-05-04 09:00:00'
  UNION ALL SELECT 31,32,31,'电子信息学生求硬件测试岗位','硬件测试','深圳,苏州','6K-10K','了解嵌入式基础和测试流程，动手能力较强。',1,14,'2026-05-05 09:00:00','2026-05-05 09:00:00'
  UNION ALL SELECT 32,33,32,'软件学生求前端开发岗位','前端开发','上海,南京','8K-12K','熟悉Vue页面开发、接口联调和基础性能优化。',1,25,'2026-05-06 09:00:00','2026-05-06 09:00:00'
  UNION ALL SELECT 33,34,33,'信管学生寻找商业分析岗位','商业分析','杭州,上海','8K-13K','能从业务问题出发做数据整理、图表展示和分析结论。',1,18,'2026-05-07 09:00:00','2026-05-07 09:00:00'
  UNION ALL SELECT 34,35,34,'视觉设计学生求品牌设计岗位','品牌设计','北京,上海','6K-10K','关注品牌视觉一致性和活动页面表现，作品集完整。',1,13,'2026-05-08 09:00:00','2026-05-08 09:00:00'
  UNION ALL SELECT 35,36,35,'网络工程学生求运维岗位','运维工程师','天津,北京','6K-10K','熟悉Linux、Shell和监控基础，希望参与企业运维实践。',1,16,'2026-05-09 09:00:00','2026-05-09 09:00:00'
) AS src
WHERE NOT EXISTS (SELECT 1 FROM `job_seeker_post` jsp WHERE jsp.`id` = src.`id`);

INSERT INTO `announcement` (`id`,`category_id`,`title`,`summary`,`content`,`author`,`view_count`,`is_top`,`status`,`publish_time`)
SELECT * FROM (
  SELECT 13 AS `id`,2 AS `category_id`,'智能制造企业联合发布春招岗位' AS `title`,'多家智能制造企业开放研发、测试与工程岗位。' AS `summary`,'<p>本次岗位覆盖工业软件、设备测试、现场工程和质量管理方向，欢迎相关专业同学关注。</p>' AS `content`,'就业办' AS `author`,118 AS `view_count`,0 AS `is_top`,1 AS `status`,'2026-03-13 10:00:00' AS `publish_time`
  UNION ALL SELECT 14,3,'群面表达与角色分工训练报名','就业指导中心开放无领导小组训练。','<p>训练将模拟真实群面流程，重点练习信息梳理、观点表达和总结陈述。</p>','就业指导中心',96,0,1,'2026-03-14 10:00:00'
  UNION ALL SELECT 15,4,'学院就业服务月活动安排发布','各学院将陆续开展简历、笔试和面试辅导。','<p>就业服务月包含企业走访、校友分享、岗位推荐和困难帮扶。</p>','校园新闻中心',102,0,1,'2026-03-15 10:00:00'
  UNION ALL SELECT 16,1,'毕业生签约流程与材料说明','整理三方协议、网签与档案去向常见问题。','<p>请毕业生按时间节点完成就业去向登记，并妥善保管相关材料。</p>','就业办',176,1,1,'2026-03-16 10:00:00'
  UNION ALL SELECT 17,2,'金融科技与数据分析岗位合集','金融、风控、数据产品岗位集中更新。','<p>本期岗位适合计算机、统计、信管和经管相关专业同学投递。</p>','就业办',134,0,1,'2026-03-17 10:00:00'
  UNION ALL SELECT 18,3,'技术岗笔试复习路线建议','按基础题、项目题和场景题拆分复习计划。','<p>建议同学结合目标岗位建立错题本，并对项目经历进行结构化复盘。</p>','就业指导中心',158,0,1,'2026-03-18 10:00:00'
  UNION ALL SELECT 19,4,'校友企业回校开展就业分享','多位校友分享从实习到转正的成长路径。','<p>分享内容包括岗位选择、试用期适应和职业发展规划。</p>','校园新闻中心',91,0,1,'2026-03-19 10:00:00'
  UNION ALL SELECT 20,2,'生活服务与新消费岗位上新','门店管理、客户服务、运营岗位持续开放。','<p>适合经管、市场营销、旅游管理及不限专业同学关注。</p>','就业办',111,0,1,'2026-03-20 10:00:00'
  UNION ALL SELECT 21,3,'作品集投递前检查清单','设计类岗位作品集建议突出过程和结果。','<p>作品集应包含项目背景、设计目标、关键过程和上线反馈。</p>','就业指导中心',88,0,1,'2026-03-21 10:00:00'
  UNION ALL SELECT 22,1,'基层项目报名时间节点提醒','三支一扶、西部计划等基层项目陆续开放。','<p>有意向同学请关注官方报名时间，并提前准备资格材料。</p>','就业办',146,0,1,'2026-03-22 10:00:00'
  UNION ALL SELECT 23,2,'暑期实习岗位推荐专栏上线','面向低年级开放实习岗位和实践项目。','<p>专栏将持续整理技术、运营、设计和职能类暑期实习机会。</p>','就业办',165,0,1,'2026-03-23 10:00:00'
  UNION ALL SELECT 24,4,'就业困难学生帮扶通道开通','学校提供一对一岗位推荐和求职辅导。','<p>学院辅导员与就业指导中心将联合建立跟踪台账，提供精准服务。</p>','校园新闻中心',92,0,1,'2026-03-24 10:00:00'
  UNION ALL SELECT 25,3,'面试自我介绍三分钟模板','围绕背景、项目、能力和意向组织表达。','<p>自我介绍不宜复述简历，应突出与岗位相关的亮点和证据。</p>','就业指导中心',143,0,1,'2026-03-25 10:00:00'
  UNION ALL SELECT 26,2,'教育科技企业专场岗位开放','课程产品、社群运营、教务支持岗位集中发布。','<p>欢迎教育、经管、计算机及不限专业同学投递相关岗位。</p>','就业办',119,0,1,'2026-03-26 10:00:00'
  UNION ALL SELECT 27,1,'灵活就业登记与权益保障提示','说明灵活就业去向登记和常见权益问题。','<p>同学可根据实际就业状态完成登记，并关注劳动合同与社保权益。</p>','就业办',131,0,1,'2026-03-27 10:00:00'
  UNION ALL SELECT 28,3,'产品运营岗位项目经历怎么写','建议从目标、动作、数据和复盘四步展开。','<p>运营类简历要量化活动效果，体现用户理解和执行闭环。</p>','就业指导中心',127,0,1,'2026-03-28 10:00:00'
  UNION ALL SELECT 29,4,'校园招聘服务系统使用提示','提醒同学完善简历、意向和求职栏信息。','<p>完善个人资料有助于企业更准确地了解求职意向并发起沟通。</p>','就业办',84,0,1,'2026-03-29 10:00:00'
  UNION ALL SELECT 30,2,'人工智能与数据产品岗位精选','AI应用、数据产品和算法实习岗位持续更新。','<p>本期岗位适合人工智能、计算机、统计和信管相关专业同学。</p>','就业办',156,1,1,'2026-03-30 10:00:00'
  UNION ALL SELECT 31,3,'投递记录复盘表模板发布','帮助同学跟踪岗位、进度和面试反馈。','<p>建议记录投递渠道、岗位JD、简历版本和每轮反馈，便于持续优化。</p>','就业指导中心',103,0,1,'2026-03-31 10:00:00'
  UNION ALL SELECT 32,4,'企业HR进校园开展简历点评','就业办邀请企业HR进行现场简历点评。','<p>活动采用预约制，每位同学可获得约15分钟一对一反馈。</p>','校园新闻中心',97,0,1,'2026-04-01 10:00:00'
  UNION ALL SELECT 33,2,'网络安全岗位招聘信息汇总','安全测试、安全运营和开发岗位开放投递。','<p>建议网络空间安全、计算机和网络工程专业同学重点关注。</p>','就业办',121,0,1,'2026-04-02 10:00:00'
  UNION ALL SELECT 34,1,'离校手续与就业派遣说明','说明毕业离校前就业材料和派遣流程。','<p>请毕业生按学院通知完成离校手续，并核对就业派遣相关信息。</p>','就业办',137,0,1,'2026-04-03 10:00:00'
  UNION ALL SELECT 35,3,'如何判断岗位与自己的匹配度','从能力、兴趣、成长空间和城市成本综合判断。','<p>建议同学避免只看薪资，结合岗位职责和团队培养机制做选择。</p>','就业指导中心',148,0,1,'2026-04-04 10:00:00'
  UNION ALL SELECT 36,2,'本周新增校招岗位一览','整理本周新增企业、岗位和宣讲活动。','<p>本周新增岗位覆盖技术、运营、设计、职能和服务类方向。</p>','就业办',162,0,1,'2026-04-05 10:00:00'
) AS src
WHERE NOT EXISTS (SELECT 1 FROM `announcement` a WHERE a.`id` = src.`id`);

INSERT INTO `campus_talk` (`id`,`title`,`enterprise_id`,`company_name`,`talk_time`,`location`,`content`,`sign_count`,`status`)
SELECT * FROM (
  SELECT 14 AS `id`,'智联云校园技术开放日' AS `title`,21 AS `enterprise_id`,'智联云校园科技有限公司' AS `company_name`,'2026-05-28 19:00:00' AS `talk_time`,'信息楼一楼报告厅' AS `location`,'介绍校园数字化产品、后端研发和前端工程岗位。' AS `content`,26 AS `sign_count`,1 AS `status`
  UNION ALL SELECT 15,'远景新能源智能运维宣讲会',22,'远景新能源科技有限公司','2026-06-03 19:00:00','工程训练中心报告厅','围绕储能系统、设备测试和现场工程师培养展开。',32,1
  UNION ALL SELECT 16,'博雅传媒内容运营分享会',23,'博雅传媒有限公司','2026-06-08 19:00:00','经管学院报告厅','介绍内容策划、短视频运营和品牌活动岗位。',28,1
  UNION ALL SELECT 17,'天工智能制造校招说明会',24,'天工智能制造有限公司','2026-06-12 19:00:00','机械楼报告厅','介绍工业软件、质量测试和工程管理岗位。',36,1
  UNION ALL SELECT 18,'银桥金融数据分析宣讲',25,'银桥金融服务有限公司','2026-06-17 19:00:00','经管学院阶梯教室','聚焦金融运营、风控分析和客户成功岗位。',30,1
  UNION ALL SELECT 19,'未来健康产品运营宣讲会',26,'未来健康科技有限公司','2026-06-21 19:00:00','线上会议室','讲解健康SaaS产品、用户运营和数据产品岗位。',24,1
  UNION ALL SELECT 20,'慧学教育课程产品说明会',27,'慧学教育服务有限公司','2026-06-26 19:00:00','大学生活动中心B厅','介绍课程运营、教研产品和学习顾问成长路径。',34,1
  UNION ALL SELECT 21,'达观数据文档智能技术分享',28,'达观数据服务有限公司','2026-07-01 19:00:00','信息楼三楼报告厅','分享知识库、文本理解和数据标注平台项目。',29,1
  UNION ALL SELECT 22,'南湖软件政企项目宣讲会',29,'南湖软件有限公司','2026-07-06 19:00:00','软件学院报告厅','介绍政企软件交付、前端开发和测试岗位。',22,1
  UNION ALL SELECT 23,'星河文旅运营管培生宣讲',30,'星河文旅集团有限公司','2026-07-11 19:00:00','经管学院报告厅','面向活动运营、酒店管理和客户服务岗位。',31,1
  UNION ALL SELECT 24,'青鸟安全攻防实践分享',33,'青鸟安全科技有限公司','2026-07-16 19:00:00','信息楼安全实验室','介绍安全测试、渗透测试和安全运营岗位。',27,1
  UNION ALL SELECT 25,'量海数据BI与分析宣讲会',34,'量海数据科技有限公司','2026-07-21 19:00:00','信息楼二楼报告厅','介绍BI分析、数据治理和数据产品岗位。',33,1
) AS src
WHERE NOT EXISTS (SELECT 1 FROM `campus_talk` ct WHERE ct.`id` = src.`id`);

INSERT INTO `job_fair` (`id`,`title`,`fair_time`,`location`,`host`,`content`,`company_count`,`job_count`,`sign_count`,`status`)
SELECT * FROM (
  SELECT 14 AS `id`,'2026暑期实习双选会' AS `title`,'2026-06-08 09:00:00' AS `fair_time`,'学校体育馆主馆' AS `location`,'校就业指导中心' AS `host`,'面向低年级和毕业生开放技术、运营、设计实习岗位。' AS `content`,72 AS `company_count`,1260 AS `job_count`,360 AS `sign_count`,1 AS `status`
  UNION ALL SELECT 15,'智能制造与新能源专场招聘会','2026-06-14 09:00:00','工程训练中心一楼大厅','工程学院','聚焦设备测试、现场工程、工业软件和质量管理岗位。',46,680,210,1
  UNION ALL SELECT 16,'金融科技与风控运营招聘会','2026-06-20 09:00:00','经管学院一楼大厅','经济管理学院','覆盖金融运营、数据分析、风控策略和客户服务岗位。',52,760,238,1
  UNION ALL SELECT 17,'新媒体与品牌内容招聘会','2026-06-28 09:00:00','艺术设计学院展厅','艺术设计学院','面向内容策划、短视频运营、品牌视觉和活动执行岗位。',38,420,180,1
  UNION ALL SELECT 18,'软件服务与政企项目双选会','2026-07-04 09:00:00','软件学院大厅','软件学院','集中展示政企软件、测试交付、前端后端和实施岗位。',64,980,280,1
  UNION ALL SELECT 19,'教育培训与课程产品专场','2026-07-10 09:00:00','大学生活动中心A厅','校就业指导中心','覆盖课程产品、社群运营、教务支持和学习顾问岗位。',44,560,190,1
  UNION ALL SELECT 20,'网络安全与运维开发招聘会','2026-07-16 09:00:00','信息楼一楼大厅','计算机学院','聚焦安全测试、运维开发、云平台和网络工程岗位。',40,620,205,1
  UNION ALL SELECT 21,'文旅服务与客户成功招聘会','2026-07-22 09:00:00','大学生活动中心前广场','后勤与就业办','面向客户成功、文旅运营、酒店管理和服务质检岗位。',36,440,168,1
  UNION ALL SELECT 22,'数据产品与商业分析双选会','2026-07-30 09:00:00','信息楼二楼大厅','校就业指导中心','适合信管、统计、计算机和经管专业学生参加。',58,820,260,1
  UNION ALL SELECT 23,'城市服务与零售管理招聘会','2026-08-06 09:00:00','经管学院大厅','经济管理学院','提供储备店长、会员运营、门店数据和客服岗位。',42,520,176,1
  UNION ALL SELECT 24,'秋招提前批综合双选会','2026-08-16 09:00:00','学校体育馆东区','校就业指导中心','帮助同学提前接触秋招岗位和企业招聘节奏。',88,1680,430,1
  UNION ALL SELECT 25,'校友企业专场招聘会','2026-08-26 09:00:00','大学生活动中心多功能厅','校友会与就业办','邀请校友企业提供研发、运营、设计和职能岗位。',50,730,225,1
  UNION ALL SELECT 26,'秋季综合就业洽谈会','2026-09-05 09:00:00','学校体育馆主馆','校就业指导中心','面向秋招启动阶段集中开放技术、运营、职能和服务类岗位。',96,1860,468,1
) AS src
WHERE NOT EXISTS (SELECT 1 FROM `job_fair` jf WHERE jf.`id` = src.`id`);

INSERT INTO `forum_post` (`id`,`student_id`,`author_name`,`title`,`content`,`category`,`view_count`,`like_count`,`comment_count`,`audit_status`,`status`,`create_time`)
SELECT * FROM (
  SELECT 13 AS `id`,18 AS `student_id`,'刘洋' AS `author_name`,'后端实习项目经历怎么写更清楚' AS `title`,'我把课程项目拆成背景、职责、难点和结果四块，感觉表达清楚很多。' AS `content`,'经验分享' AS `category`,67 AS `view_count`,12 AS `like_count`,0 AS `comment_count`,1 AS `audit_status`,1 AS `status`,'2026-04-01 12:00:00' AS `create_time`
  UNION ALL SELECT 14,19,'方敏','前端面试被问到组件封装','记录一下组件通信、表单校验和权限按钮几个问题。','经验分享',74,15,0,1,1,'2026-04-02 12:00:00'
  UNION ALL SELECT 15,20,'何宇','算法实习需要准备哪些项目','NLP课程项目够不够，还是需要再补一个推荐系统项目？','求职交流',88,11,0,1,1,'2026-04-03 12:00:00'
  UNION ALL SELECT 16,21,'宋可','作品集页数控制在多少比较合适','想听听投设计岗的同学怎么安排作品集结构。','求职交流',52,8,0,1,1,'2026-04-04 12:00:00'
  UNION ALL SELECT 17,22,'唐睿','运营岗群面复盘','今天群面题是校园产品增长，数据意识真的很重要。','经验分享',63,13,0,1,1,'2026-04-05 12:00:00'
  UNION ALL SELECT 18,23,'郭佳','测试开发笔试复习清单','接口测试、数据库和Python基础都要看，分享一下我的复习表。','经验分享',71,16,0,1,1,'2026-04-06 12:00:00'
  UNION ALL SELECT 19,24,'马哲','运维开发岗位会问哪些Linux命令','准备面试时发现命令细节很多，欢迎补充高频题。','求职交流',49,7,0,1,1,'2026-04-07 12:00:00'
  UNION ALL SELECT 20,25,'肖然','数据分析作品怎么展示','课程报告能不能作为作品集，需要补哪些图表？','求职交流',58,9,0,1,1,'2026-04-08 12:00:00'
  UNION ALL SELECT 21,26,'吕晴','HR实习一面结束','主要问了校园活动经历和沟通冲突处理，整体比较贴近经历。','经验分享',45,10,0,1,1,'2026-04-09 12:00:00'
  UNION ALL SELECT 22,27,'彭浩','拿到后端实习offer了','感谢之前帮我看简历的同学，项目讲清楚后反馈好了很多。','offer捷报',96,24,0,1,1,'2026-04-10 12:00:00'
  UNION ALL SELECT 23,28,'蔡欣','设计岗作品集点评收获','企业老师建议我把每个项目的目标和约束写在前面。','经验分享',62,14,0,1,1,'2026-04-11 12:00:00'
  UNION ALL SELECT 24,29,'袁博','数据分析岗二面会问业务吗','一面偏技术，担心二面业务理解不足。','求职交流',53,8,0,1,1,'2026-04-12 12:00:00'
  UNION ALL SELECT 25,30,'胡哲','缓存项目怎么讲更有亮点','准备把缓存穿透和接口压测结果放进项目介绍。','求职交流',64,12,0,1,1,'2026-04-13 12:00:00'
  UNION ALL SELECT 26,31,'尹欣','新媒体运营面试复盘','问了账号定位、选题方法和数据复盘，分享几个问题。','经验分享',56,11,0,1,1,'2026-04-14 12:00:00'
  UNION ALL SELECT 27,32,'罗瀚','硬件测试岗位投递建议','电子信息专业转测试开发是否需要补项目？','求职交流',41,6,0,1,1,'2026-04-15 12:00:00'
  UNION ALL SELECT 28,33,'沈奕','前端简历终于有回音了','把项目截图和性能优化细节补上后，约面明显变多。','offer捷报',82,21,0,1,1,'2026-04-16 12:00:00'
  UNION ALL SELECT 29,34,'卓雨','商业分析岗位需要SQL到什么程度','想知道校招笔试里SQL会不会很难。','求职交流',57,9,0,1,1,'2026-04-17 12:00:00'
  UNION ALL SELECT 30,35,'谢晨','品牌设计岗位面试经历','面试官很关注设计动机和方案取舍，不只是看图好不好看。','经验分享',60,13,0,1,1,'2026-04-18 12:00:00'
  UNION ALL SELECT 31,36,'段磊','运维实习offer选择','一个偏现场运维，一个偏平台开发，想听听大家建议。','offer捷报',70,17,0,1,1,'2026-04-19 12:00:00'
  UNION ALL SELECT 32,18,'刘洋','三方签约前要注意什么','第一次签约有点紧张，想确认违约和档案相关问题。','求职交流',77,10,0,1,1,'2026-04-20 12:00:00'
  UNION ALL SELECT 33,19,'方敏','如何准备前端项目追问','面试官会一直追问为什么这么做，大家怎么训练表达？','求职交流',65,12,0,1,1,'2026-04-21 12:00:00'
  UNION ALL SELECT 34,20,'何宇','算法岗暑期实习投递节奏','现在投递还来得及吗，哪些公司反馈比较快？','求职交流',73,14,0,1,1,'2026-04-22 12:00:00'
  UNION ALL SELECT 35,21,'宋可','收到交互设计实习offer','作品集讲解练了很多遍，终于拿到一个满意的机会。','offer捷报',89,23,0,1,1,'2026-04-23 12:00:00'
  UNION ALL SELECT 36,22,'唐睿','运营岗数据题怎么准备','除了漏斗和留存，还需要准备哪些常见分析题？','求职交流',59,9,0,1,1,'2026-04-24 12:00:00'
) AS src
WHERE NOT EXISTS (SELECT 1 FROM `forum_post` fp WHERE fp.`id` = src.`id`);

-- Local demo data that exists in the current local database but not in the GitHub baseline.
-- Keep this section idempotent: servers may execute update-data.sql more than once.
-- BEGIN LOCAL DEMO DATA PATCH
-- enterprise_hr
INSERT IGNORE INTO `enterprise_hr` (`id`, `enterprise_id`, `username`, `password`, `real_name`, `phone`, `email`, `hr_role`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (128,1,'bytedance-recruit-a','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','王敏-后端招聘','13810001001','wangmin@bytedance.demo','STAFF',1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `enterprise_hr` (`id`, `enterprise_id`, `username`, `password`, `real_name`, `phone`, `email`, `hr_role`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (129,1,'bytedance-campus','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','赵倩-校招主管','13810001002','zhaoqian@bytedance.demo','SUPERVISOR',1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `enterprise_hr` (`id`, `enterprise_id`, `username`, `password`, `real_name`, `phone`, `email`, `hr_role`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (130,1,'bytedance-intern','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','陈晨-实习招聘','13810001003','chenchen@bytedance.demo','STAFF',1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `enterprise_hr` (`id`, `enterprise_id`, `username`, `password`, `real_name`, `phone`, `email`, `hr_role`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (131,2,'tencent-campus-a','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','林珊-校招HR','13810002001','linshan@tencent.demo','STAFF',1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `enterprise_hr` (`id`, `enterprise_id`, `username`, `password`, `real_name`, `phone`, `email`, `hr_role`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (132,2,'tencent-tech-lead','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','周宇-技术招聘','13810002002','zhouyu@tencent.demo','SUPERVISOR',1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `enterprise_hr` (`id`, `enterprise_id`, `username`, `password`, `real_name`, `phone`, `email`, `hr_role`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (133,2,'tencent-product','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','黄欣-产品招聘','13810002003','huangxin@tencent.demo','STAFF',1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `enterprise_hr` (`id`, `enterprise_id`, `username`, `password`, `real_name`, `phone`, `email`, `hr_role`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (134,4,'aliyun-platform','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','何雨-平台招聘','13810004001','heyu@aliyun.demo','STAFF',1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `enterprise_hr` (`id`, `enterprise_id`, `username`, `password`, `real_name`, `phone`, `email`, `hr_role`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (135,4,'aliyun-data','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','高远-数据招聘','13810004002','gaoyuan@aliyun.demo','STAFF',1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `enterprise_hr` (`id`, `enterprise_id`, `username`, `password`, `real_name`, `phone`, `email`, `hr_role`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (136,4,'aliyun-campus','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','丁宁-校招主管','13810004003','dingning@aliyun.demo','SUPERVISOR',1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `enterprise_hr` (`id`, `enterprise_id`, `username`, `password`, `real_name`, `phone`, `email`, `hr_role`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (137,5,'meituan-tech','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','宋洁-技术招聘','13810005001','songjie@meituan.demo','STAFF',1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `enterprise_hr` (`id`, `enterprise_id`, `username`, `password`, `real_name`, `phone`, `email`, `hr_role`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (138,5,'meituan-operation','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','马睿-运营招聘','13810005002','marui@meituan.demo','STAFF',1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `enterprise_hr` (`id`, `enterprise_id`, `username`, `password`, `real_name`, `phone`, `email`, `hr_role`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (139,10,'sparkai-algo','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','许诺-算法招聘','13810010001','xunuo@sparkai.demo','STAFF',1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `enterprise_hr` (`id`, `enterprise_id`, `username`, `password`, `real_name`, `phone`, `email`, `hr_role`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (140,10,'sparkai-campus','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','沈琳-校招主管','13810010002','shenlin@sparkai.demo','SUPERVISOR',1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);

-- student
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (37,'demo_stu37','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','顾晓晨','2022001037',1,'计算机学院','软件工程','2022级','本科','13920000037','demo_stu37@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (38,'demo_stu38','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','林雨薇','2022001038',2,'计算机学院','计算机科学与技术','2022级','本科','13920000038','demo_stu38@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (39,'demo_stu39','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','许嘉豪','2022001039',1,'人工智能学院','人工智能','2022级','本科','13920000039','demo_stu39@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (40,'demo_stu40','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','沈一诺','2022001040',2,'数据科学学院','数据科学与大数据技术','2022级','本科','13920000040','demo_stu40@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (41,'demo_stu41','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','陈景行','2022001041',1,'计算机学院','网络工程','2022级','本科','13920000041','demo_stu41@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (42,'demo_stu42','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','赵思琪','2022001042',2,'设计学院','视觉传达设计','2022级','本科','13920000042','demo_stu42@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (43,'demo_stu43','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','黄子昂','2022001043',1,'经济管理学院','市场营销','2022级','本科','13920000043','demo_stu43@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (44,'demo_stu44','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','吴清欢','2022001044',2,'经济管理学院','人力资源管理','2022级','本科','13920000044','demo_stu44@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (45,'demo_stu45','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','周明远','2022001045',1,'计算机学院','软件工程','2022级','本科','13920000045','demo_stu45@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (46,'demo_stu46','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','郑语桐','2022001046',2,'人工智能学院','智能科学与技术','2022级','本科','13920000046','demo_stu46@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (47,'demo_stu47','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','唐逸飞','2022001047',1,'计算机学院','物联网工程','2022级','本科','13920000047','demo_stu47@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (48,'demo_stu48','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','冯若溪','2022001048',2,'数据科学学院','信息管理与信息系统','2022级','本科','13920000048','demo_stu48@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (49,'demo_stu49','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','蒋承泽','2022001049',1,'计算机学院','软件工程','2021级','本科','13920000049','demo_stu49@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (50,'demo_stu50','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','苏芷晴','2022001050',2,'设计学院','数字媒体艺术','2021级','本科','13920000050','demo_stu50@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (51,'demo_stu51','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','邹凯文','2022001051',1,'电子信息学院','电子信息工程','2021级','本科','13920000051','demo_stu51@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (52,'demo_stu52','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','姜沐言','2022001052',2,'经济管理学院','电子商务','2021级','本科','13920000052','demo_stu52@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (53,'demo_stu53','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','程浩然','2022001053',1,'人工智能学院','人工智能','2021级','本科','13920000053','demo_stu53@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (54,'demo_stu54','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','罗诗涵','2022001054',2,'计算机学院','计算机科学与技术','2021级','本科','13920000054','demo_stu54@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (55,'demo_stu55','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','韩亦辰','2022001055',1,'数据科学学院','数据科学与大数据技术','2021级','本科','13920000055','demo_stu55@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (56,'demo_stu56','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','宋安然','2022001056',2,'经济管理学院','会计学','2021级','本科','13920000056','demo_stu56@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (57,'demo_stu57','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','梁峻熙','2022001057',1,'计算机学院','软件工程','2023级','硕士','13920000057','demo_stu57@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (58,'demo_stu58','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','叶知秋','2022001058',2,'人工智能学院','模式识别与智能系统','2023级','硕士','13920000058','demo_stu58@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (59,'demo_stu59','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','许星河','2022001059',1,'数据科学学院','统计学','2023级','硕士','13920000059','demo_stu59@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (60,'demo_stu60','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','白若宁','2022001060',2,'设计学院','工业设计','2023级','硕士','13920000060','demo_stu60@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (61,'demo_stu61','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','陆景川','2022001061',1,'计算机学院','网络空间安全','2023级','本科','13920000061','demo_stu61@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (62,'demo_stu62','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','乔欣然','2022001062',2,'经济管理学院','工商管理','2023级','本科','13920000062','demo_stu62@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (63,'demo_stu63','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','戴子墨','2022001063',1,'电子信息学院','通信工程','2023级','本科','13920000063','demo_stu63@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (64,'demo_stu64','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','夏晚晴','2022001064',2,'计算机学院','软件工程','2023级','本科','13920000064','demo_stu64@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (65,'demo_stu65','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','秦朗','2022001065',1,'经济管理学院','市场营销','2023级','本科','13920000065','demo_stu65@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (66,'demo_stu66','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','穆清越','2022001066',2,'数据科学学院','数据科学与大数据技术','2023级','本科','13920000066','demo_stu66@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (67,'demo_stu67','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','石天佑','2022001067',1,'计算机学院','计算机科学与技术','2023级','本科','13920000067','demo_stu67@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (68,'demo_stu68','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','季云舒','2022001068',2,'设计学院','视觉传达设计','2023级','本科','13920000068','demo_stu68@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (69,'demo_stu69','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','何以安','2022001069',1,'电子信息学院','电子信息工程','2023级','本科','13920000069','demo_stu69@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (70,'demo_stu70','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','郝思源','2022001070',1,'计算机学院','软件工程','2023级','本科','13920000070','demo_stu70@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (71,'demo_stu71','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','孟可欣','2022001071',2,'经济管理学院','人力资源管理','2023级','本科','13920000071','demo_stu71@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `student` (`id`, `username`, `password`, `real_name`, `student_no`, `gender`, `college`, `major`, `grade`, `education`, `phone`, `email`, `avatar`, `intro`, `status`, `last_login`, `create_time`, `update_time`, `deleted`) VALUES (72,'demo_stu72','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','杜若飞','2022001072',1,'人工智能学院','人工智能','2023级','本科','13920000072','demo_stu72@stu.demo',NULL,NULL,1,NULL,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);

-- resume
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (36,37,'顾晓晨',1,NULL,'13920000037','demo_stu37@stu.demo','计算机学院','软件工程','本科','Java,SpringBoot,Vue,MySQL,数据分析,软件工程','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的软件工程基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (37,38,'林雨薇',2,NULL,'13920000038','demo_stu38@stu.demo','计算机学院','计算机科学与技术','本科','Java,SpringBoot,Vue,MySQL,数据分析,计算机科学与技术','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的计算机科学与技术基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (38,39,'许嘉豪',1,NULL,'13920000039','demo_stu39@stu.demo','人工智能学院','人工智能','本科','Java,SpringBoot,Vue,MySQL,数据分析,人工智能','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的人工智能基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (39,40,'沈一诺',2,NULL,'13920000040','demo_stu40@stu.demo','数据科学学院','数据科学与大数据技术','本科','Java,SpringBoot,Vue,MySQL,数据分析,数据科学与大数据技术','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的数据科学与大数据技术基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (40,41,'陈景行',1,NULL,'13920000041','demo_stu41@stu.demo','计算机学院','网络工程','本科','Java,SpringBoot,Vue,MySQL,数据分析,网络工程','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的网络工程基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (41,42,'赵思琪',2,NULL,'13920000042','demo_stu42@stu.demo','设计学院','视觉传达设计','本科','Java,SpringBoot,Vue,MySQL,数据分析,视觉传达设计','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的视觉传达设计基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (42,43,'黄子昂',1,NULL,'13920000043','demo_stu43@stu.demo','经济管理学院','市场营销','本科','Java,SpringBoot,Vue,MySQL,数据分析,市场营销','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的市场营销基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (43,44,'吴清欢',2,NULL,'13920000044','demo_stu44@stu.demo','经济管理学院','人力资源管理','本科','Java,SpringBoot,Vue,MySQL,数据分析,人力资源管理','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的人力资源管理基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (44,45,'周明远',1,NULL,'13920000045','demo_stu45@stu.demo','计算机学院','软件工程','本科','Java,SpringBoot,Vue,MySQL,数据分析,软件工程','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的软件工程基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (45,46,'郑语桐',2,NULL,'13920000046','demo_stu46@stu.demo','人工智能学院','智能科学与技术','本科','Java,SpringBoot,Vue,MySQL,数据分析,智能科学与技术','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的智能科学与技术基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (46,47,'唐逸飞',1,NULL,'13920000047','demo_stu47@stu.demo','计算机学院','物联网工程','本科','Java,SpringBoot,Vue,MySQL,数据分析,物联网工程','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的物联网工程基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (47,48,'冯若溪',2,NULL,'13920000048','demo_stu48@stu.demo','数据科学学院','信息管理与信息系统','本科','Java,SpringBoot,Vue,MySQL,数据分析,信息管理与信息系统','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的信息管理与信息系统基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (48,49,'蒋承泽',1,NULL,'13920000049','demo_stu49@stu.demo','计算机学院','软件工程','本科','Java,SpringBoot,Vue,MySQL,数据分析,软件工程','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的软件工程基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (49,50,'苏芷晴',2,NULL,'13920000050','demo_stu50@stu.demo','设计学院','数字媒体艺术','本科','Java,SpringBoot,Vue,MySQL,数据分析,数字媒体艺术','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的数字媒体艺术基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (50,51,'邹凯文',1,NULL,'13920000051','demo_stu51@stu.demo','电子信息学院','电子信息工程','本科','Java,SpringBoot,Vue,MySQL,数据分析,电子信息工程','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的电子信息工程基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (51,52,'姜沐言',2,NULL,'13920000052','demo_stu52@stu.demo','经济管理学院','电子商务','本科','Java,SpringBoot,Vue,MySQL,数据分析,电子商务','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的电子商务基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (52,53,'程浩然',1,NULL,'13920000053','demo_stu53@stu.demo','人工智能学院','人工智能','本科','Java,SpringBoot,Vue,MySQL,数据分析,人工智能','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的人工智能基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (53,54,'罗诗涵',2,NULL,'13920000054','demo_stu54@stu.demo','计算机学院','计算机科学与技术','本科','Java,SpringBoot,Vue,MySQL,数据分析,计算机科学与技术','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的计算机科学与技术基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (54,55,'韩亦辰',1,NULL,'13920000055','demo_stu55@stu.demo','数据科学学院','数据科学与大数据技术','本科','Java,SpringBoot,Vue,MySQL,数据分析,数据科学与大数据技术','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的数据科学与大数据技术基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (55,56,'宋安然',2,NULL,'13920000056','demo_stu56@stu.demo','经济管理学院','会计学','本科','Java,SpringBoot,Vue,MySQL,数据分析,会计学','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的会计学基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (56,57,'梁峻熙',1,NULL,'13920000057','demo_stu57@stu.demo','计算机学院','软件工程','硕士','Java,SpringBoot,Vue,MySQL,数据分析,软件工程','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的软件工程基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (57,58,'叶知秋',2,NULL,'13920000058','demo_stu58@stu.demo','人工智能学院','模式识别与智能系统','硕士','Java,SpringBoot,Vue,MySQL,数据分析,模式识别与智能系统','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的模式识别与智能系统基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (58,59,'许星河',1,NULL,'13920000059','demo_stu59@stu.demo','数据科学学院','统计学','硕士','Java,SpringBoot,Vue,MySQL,数据分析,统计学','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的统计学基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (59,60,'白若宁',2,NULL,'13920000060','demo_stu60@stu.demo','设计学院','工业设计','硕士','Java,SpringBoot,Vue,MySQL,数据分析,工业设计','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的工业设计基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (60,61,'陆景川',1,NULL,'13920000061','demo_stu61@stu.demo','计算机学院','网络空间安全','本科','Java,SpringBoot,Vue,MySQL,数据分析,网络空间安全','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的网络空间安全基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (61,62,'乔欣然',2,NULL,'13920000062','demo_stu62@stu.demo','经济管理学院','工商管理','本科','Java,SpringBoot,Vue,MySQL,数据分析,工商管理','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的工商管理基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (62,63,'戴子墨',1,NULL,'13920000063','demo_stu63@stu.demo','电子信息学院','通信工程','本科','Java,SpringBoot,Vue,MySQL,数据分析,通信工程','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的通信工程基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (63,64,'夏晚晴',2,NULL,'13920000064','demo_stu64@stu.demo','计算机学院','软件工程','本科','Java,SpringBoot,Vue,MySQL,数据分析,软件工程','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的软件工程基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (64,65,'秦朗',1,NULL,'13920000065','demo_stu65@stu.demo','经济管理学院','市场营销','本科','Java,SpringBoot,Vue,MySQL,数据分析,市场营销','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的市场营销基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (65,66,'穆清越',2,NULL,'13920000066','demo_stu66@stu.demo','数据科学学院','数据科学与大数据技术','本科','Java,SpringBoot,Vue,MySQL,数据分析,数据科学与大数据技术','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的数据科学与大数据技术基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (66,67,'石天佑',1,NULL,'13920000067','demo_stu67@stu.demo','计算机学院','计算机科学与技术','本科','Java,SpringBoot,Vue,MySQL,数据分析,计算机科学与技术','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的计算机科学与技术基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (67,68,'季云舒',2,NULL,'13920000068','demo_stu68@stu.demo','设计学院','视觉传达设计','本科','Java,SpringBoot,Vue,MySQL,数据分析,视觉传达设计','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的视觉传达设计基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (68,69,'何以安',1,NULL,'13920000069','demo_stu69@stu.demo','电子信息学院','电子信息工程','本科','Java,SpringBoot,Vue,MySQL,数据分析,电子信息工程','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的电子信息工程基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (69,70,'郝思源',1,NULL,'13920000070','demo_stu70@stu.demo','计算机学院','软件工程','本科','Java,SpringBoot,Vue,MySQL,数据分析,软件工程','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的软件工程基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (70,71,'孟可欣',2,NULL,'13920000071','demo_stu71@stu.demo','经济管理学院','人力资源管理','本科','Java,SpringBoot,Vue,MySQL,数据分析,人力资源管理','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的人力资源管理基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);
INSERT IGNORE INTO `resume` (`id`, `student_id`, `name`, `gender`, `birth`, `phone`, `email`, `college`, `major`, `education`, `skill_cert`, `award`, `self_eval`, `complete_rate`, `is_public`, `create_time`, `update_time`, `deleted`) VALUES (71,72,'杜若飞',1,NULL,'13920000072','demo_stu72@stu.demo','人工智能学院','人工智能','本科','Java,SpringBoot,Vue,MySQL,数据分析,人工智能','校级项目实践奖、互联网+创新创业训练营优秀学员','具备扎实的人工智能基础，关注业务场景，沟通主动，适合校园招聘演示。',92,1,'2026-06-30 23:39:34','2026-06-30 23:39:34',0);

-- resume_education
INSERT IGNORE INTO `resume_education` (`id`, `resume_id`, `school`, `major`, `degree`, `start_date`, `end_date`, `description`, `create_time`, `update_time`, `deleted`) VALUES (17,16,'某某大学','信息管理与信息系统','本科','2021-09','2025-06','主修信息系统分析、数据统计、商业分析和项目管理。','2026-06-26 11:35:14','2026-06-26 11:35:14',0);
INSERT IGNORE INTO `resume_education` (`id`, `resume_id`, `school`, `major`, `degree`, `start_date`, `end_date`, `description`, `create_time`, `update_time`, `deleted`) VALUES (18,17,'某某大学','计算机科学与技术','本科','2021-09','2025-06','主修Java程序设计、数据库系统、软件工程和计算机网络。','2026-06-27 00:23:43','2026-06-27 00:23:43',0);
INSERT IGNORE INTO `resume_education` (`id`, `resume_id`, `school`, `major`, `degree`, `start_date`, `end_date`, `description`, `create_time`, `update_time`, `deleted`) VALUES (19,18,'某某大学','软件工程','本科','2021-09','2025-06','主修Web开发、软件测试、软件项目管理和前端框架。','2026-06-27 00:23:43','2026-06-27 00:23:43',0);
INSERT IGNORE INTO `resume_education` (`id`, `resume_id`, `school`, `major`, `degree`, `start_date`, `end_date`, `description`, `create_time`, `update_time`, `deleted`) VALUES (20,19,'某某大学','人工智能','本科','2021-09','2025-06','主修机器学习、自然语言处理、数据挖掘和概率统计。','2026-06-27 00:23:43','2026-06-27 00:23:43',0);
INSERT IGNORE INTO `resume_education` (`id`, `resume_id`, `school`, `major`, `degree`, `start_date`, `end_date`, `description`, `create_time`, `update_time`, `deleted`) VALUES (21,20,'某某大学','视觉传达设计','本科','2021-09','2025-06','主修界面设计、品牌视觉、交互原型和用户研究。','2026-06-27 00:23:43','2026-06-27 00:23:43',0);
INSERT IGNORE INTO `resume_education` (`id`, `resume_id`, `school`, `major`, `degree`, `start_date`, `end_date`, `description`, `create_time`, `update_time`, `deleted`) VALUES (22,21,'某某大学','市场营销','本科','2021-09','2025-06','主修市场调研、消费者行为、品牌策划和新媒体运营。','2026-06-27 00:23:43','2026-06-27 00:23:43',0);
INSERT IGNORE INTO `resume_education` (`id`, `resume_id`, `school`, `major`, `degree`, `start_date`, `end_date`, `description`, `create_time`, `update_time`, `deleted`) VALUES (23,22,'某某大学','电子信息工程','本科','2021-09','2025-06','主修数字电路、嵌入式系统、软件测试和信号处理。','2026-06-27 00:23:43','2026-06-27 00:23:43',0);

-- job_post
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (44,1,128,6,'推荐算法后端工程师（校招演示）',1,5,'北京',22,38,'本科及以上','计算机/软件工程/人工智能','不限','参与推荐系统服务端开发，负责召回、排序、特征服务与数据链路优化。','熟悉 Java 或 Go，了解 MySQL/Redis/消息队列，有算法工程化项目经验优先。','五险一金,餐补,弹性工作,导师带教',1,NULL,1,320,3,'2026-06-28 23:39:34','2026-06-30 23:39:34','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (45,1,129,7,'商业化前端开发工程师（校招演示）',1,4,'北京',18,32,'本科及以上','计算机/软件工程','不限','负责企业级增长产品前端工程建设，沉淀组件和数据看板能力。','熟悉 Vue/React、TypeScript、工程化构建，注重用户体验。','五险一金,年终奖,免费三餐,成长空间',1,NULL,1,278,3,'2026-06-27 23:39:34','2026-06-30 23:39:34','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (46,1,130,16,'数据平台实习生（校招演示）',2,8,'上海',5,8,'本科及以上','数据科学/统计/计算机','不限','参与数据指标体系建设、报表开发和数据质量治理。','熟悉 SQL/Python，理解常见数据分析方法，每周至少实习4天。','实习证明,导师带教,转正机会',1,NULL,1,198,2,'2026-06-29 23:39:34','2026-06-30 23:39:34','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (47,2,132,15,'微信生态小程序开发工程师（校招演示）',1,6,'深圳',20,35,'本科及以上','计算机/软件工程','不限','负责小程序基础能力、组件化和性能优化，支撑校园服务场景。','熟悉 JavaScript/TypeScript，了解前端性能优化和跨端开发。','五险一金,股票激励,班车,健身房',1,NULL,1,356,2,'2026-06-26 23:39:34','2026-06-30 23:39:34','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (48,2,133,10,'社交产品经理管培生（校招演示）',1,4,'深圳',18,30,'本科及以上','不限专业','不限','参与社交产品需求分析、竞品研究、用户增长和版本迭代。','逻辑清晰、数据敏感，有校园产品或社区运营经验优先。','导师制,年终奖,弹性工作',1,NULL,1,241,4,'2026-06-28 23:39:34','2026-06-30 23:39:34','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (49,2,131,18,'云安全工程师（校招演示）',1,3,'深圳',22,36,'本科及以上','网络空间安全/计算机','不限','参与云安全检测、风险处置、安全运营平台建设。','掌握网络协议、安全攻防基础，熟悉 Linux 和脚本开发。','五险一金,安全实验室,技术分享',1,NULL,1,188,2,'2026-06-25 23:39:34','2026-06-30 23:39:34','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (50,4,134,17,'云原生平台研发工程师（校招演示）',1,6,'杭州',21,36,'本科及以上','计算机/软件工程','不限','参与容器平台、服务治理和自动化运维产品研发。','熟悉 Java/Go/Linux，理解 Kubernetes 基础优先。','五险一金,技术培训,餐补,弹性工作',1,NULL,1,302,3,'2026-06-27 23:39:34','2026-06-30 23:39:34','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (51,4,135,16,'大数据开发工程师（校招演示）',1,5,'杭州',20,34,'本科及以上','数据科学/计算机','不限','负责离线/实时数据链路开发，建设指标体系和数据服务。','熟悉 SQL、Java/Python，了解 Flink/Spark/Hive 优先。','五险一金,年终奖,导师带教',1,NULL,1,290,2,'2026-06-29 23:39:34','2026-06-30 23:39:34','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (52,4,136,8,'质量效能测试开发工程师（校招演示）',1,4,'杭州',17,28,'本科及以上','计算机/软件工程','不限','建设自动化测试平台，提升云产品质量和发布效率。','熟悉测试理论、Java/Python，有自动化测试项目经验优先。','五险一金,技术分享,补充医疗',1,NULL,1,176,2,'2026-06-24 23:39:34','2026-06-30 23:39:34','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (53,5,137,6,'履约系统 Java 开发工程师（校招演示）',1,5,'北京',18,32,'本科及以上','计算机/软件工程','不限','参与即时零售、履约调度和交易系统研发。','熟悉 Java/SpringBoot/MySQL，理解高并发基础。','五险一金,餐补,弹性工作',1,NULL,1,245,2,'2026-06-28 23:39:34','2026-06-30 23:39:34','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (54,5,138,19,'本地生活运营管培生（校招演示）',1,8,'上海',10,18,'本科及以上','市场营销/工商管理/不限','不限','负责商家运营、活动策划、数据复盘和增长策略落地。','沟通能力强，熟悉 Excel/数据分析，有校园活动经验优先。','五险一金,绩效奖金,成长快',1,NULL,1,231,4,'2026-06-26 23:39:34','2026-06-30 23:39:34','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (55,10,139,9,'多模态算法工程师（校招演示）',1,4,'北京',25,45,'硕士及以上','人工智能/计算机/数学','不限','参与多模态模型训练、评测、推理优化和业务落地。','熟悉深度学习框架，具备 NLP/CV/多模态项目经验优先。','五险一金,论文支持,算力资源,弹性工作',1,NULL,1,389,4,'2026-06-29 23:39:34','2026-06-30 23:39:34','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (56,10,140,6,'AI 应用后端工程师（校招演示）',1,6,'北京',20,34,'本科及以上','计算机/软件工程/人工智能','不限','负责 AI 应用服务、模型网关、权限和计费链路研发。','熟悉 Java/SpringBoot，了解大模型应用开发优先。','五险一金,导师带教,技术社区',1,NULL,1,267,3,'2026-06-28 23:39:34','2026-06-30 23:39:34','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (57,6,6,29,'在线教育新媒体运营（扩展演示）',1,5,'北京',9,15,'本科及以上','新闻传播/市场营销/不限','不限','负责课程内容选题、短视频脚本、账号运营和数据复盘。','文字表达好，熟悉新媒体平台，有校园账号运营经验优先。','五险一金,带薪年假,学习资源',1,NULL,1,146,2,'2026-06-29 23:44:50','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (58,7,7,16,'金融数据分析师（扩展演示）',1,4,'上海',14,24,'本科及以上','统计/金融/数据科学','不限','建设金融业务指标体系，完成用户、风控和经营分析。','熟悉 SQL/Python，具备金融业务敏感度。','五险一金,补充医疗,绩效奖金',1,NULL,1,168,2,'2026-06-28 23:44:50','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (59,8,8,6,'智能制造 Java 工程师（扩展演示）',1,6,'苏州',13,22,'本科及以上','计算机/自动化','不限','参与制造执行系统、设备接入和数据采集平台研发。','熟悉 Java/SpringBoot/MySQL，有物联网项目经验优先。','五险一金,住宿补贴,项目奖金',1,NULL,1,152,2,'2026-06-27 23:44:50','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (60,11,11,17,'物流调度平台开发工程师（扩展演示）',1,5,'杭州',15,26,'本科及以上','计算机/软件工程','不限','负责运力调度、路径规划和订单履约系统研发。','熟悉 Java/Go，了解分布式系统和缓存。','五险一金,餐补,弹性工作',1,NULL,1,176,2,'2026-06-26 23:44:50','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (61,12,12,24,'游戏 UI 视觉设计师（扩展演示）',1,3,'上海',12,20,'本科及以上','视觉设计/数字媒体','不限','负责游戏界面、活动视觉、图标和运营素材设计。','熟练使用 Figma/PS/AI，有游戏设计作品集。','五险一金,创意奖金,弹性工作',1,NULL,1,134,2,'2026-06-25 23:44:50','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (62,13,13,20,'连锁餐饮电商运营（扩展演示）',1,8,'广州',8,14,'本科及以上','电子商务/市场营销','不限','负责外卖平台、会员活动和线上渠道运营。','数据意识强，能进行活动复盘和商家沟通。','五险一金,员工餐,节日福利',1,NULL,1,128,2,'2026-06-24 23:44:50','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (63,14,14,27,'酒店客户服务管培生（扩展演示）',1,10,'三亚',7,12,'大专及以上','酒店管理/旅游管理/不限','不限','参与前厅、会员、客户服务和投诉处理轮岗。','服务意识好，沟通表达清晰。','包食宿,五险一金,晋升通道',1,NULL,1,119,2,'2026-06-28 23:44:50','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (64,15,15,30,'门店零售储备干部（扩展演示）',1,12,'南京',7,13,'大专及以上','工商管理/市场营销/不限','不限','负责门店运营、商品陈列、会员维护和团队排班。','执行力强，愿意从一线业务成长。','五险一金,绩效奖金,带薪培训',1,NULL,1,142,2,'2026-06-27 23:44:50','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (65,16,16,16,'BI 数据分析实习生（扩展演示）',2,6,'深圳',4,7,'本科及以上','数据科学/统计/信息管理','不限','协助完成 BI 报表、数据口径梳理和专题分析。','熟悉 SQL 和 Excel，有可视化工具经验优先。','实习证明,转正机会,导师带教',1,NULL,1,155,2,'2026-06-29 23:44:50','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (66,17,17,23,'校园服务行政专员（扩展演示）',1,4,'成都',6,10,'本科及以上','行政管理/人力资源/不限','不限','负责校园服务项目行政支持、资料归档和跨部门协调。','细致负责，沟通协调能力好。','五险一金,周末双休,节日福利',1,NULL,1,98,2,'2026-06-23 23:44:50','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (67,18,18,6,'数字化平台后端工程师（扩展演示）',1,5,'武汉',13,24,'本科及以上','计算机/软件工程','不限','参与企业数字化平台、权限、流程引擎和报表系统研发。','熟悉 Java/SpringBoot/Vue，有业务系统开发经验优先。','五险一金,年终奖,技术分享',1,NULL,1,184,2,'2026-06-26 23:44:50','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (68,19,19,13,'校招 HR 助理（扩展演示）',2,4,'广州',4,6,'本科及以上','人力资源管理/心理学','不限','协助简历筛选、面试邀约、校招活动组织和数据维护。','沟通主动，能熟练使用办公软件。','实习证明,转正机会,弹性工作',1,NULL,1,121,2,'2026-06-28 23:44:50','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (69,20,20,7,'零售系统前端开发（扩展演示）',1,4,'上海',12,20,'本科及以上','计算机/软件工程','不限','负责门店运营后台、会员系统和数据看板前端开发。','熟悉 Vue/React，重视交互体验和工程质量。','五险一金,绩效奖金,弹性工作',1,NULL,1,139,2,'2026-06-24 23:44:50','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (70,21,21,11,'内容运营专员（扩展演示）',1,5,'长沙',7,12,'本科及以上','新闻传播/中文/市场营销','不限','负责内容策划、用户增长活动和社区氛围维护。','文案能力强，具备热点敏感度。','五险一金,下午茶,成长空间',1,NULL,1,128,2,'2026-06-25 23:44:50','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (71,22,22,22,'财务管培生（扩展演示）',1,4,'厦门',8,13,'本科及以上','会计学/财务管理','不限','参与预算、核算、经营分析和财务数字化项目。','财务基础扎实，熟悉 Excel，有初级证书优先。','五险一金,带薪年假,轮岗培养',1,NULL,1,113,2,'2026-06-27 23:44:50','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (72,23,23,10,'数据产品经理助理（扩展演示）',2,3,'北京',5,8,'本科及以上','信息管理/计算机/统计','不限','协助数据产品需求调研、原型设计、验收和上线跟进。','逻辑清晰，了解 SQL 或数据分析优先。','实习证明,导师带教,转正机会',1,NULL,1,166,2,'2026-06-28 23:44:50','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (73,24,24,6,'SaaS 后端开发工程师（扩展演示）',1,6,'杭州',14,25,'本科及以上','计算机/软件工程','不限','负责 SaaS 多租户、权限、消息和业务配置模块研发。','熟悉 Java/SpringBoot/MySQL，代码习惯良好。','五险一金,补充医疗,年终奖',1,NULL,1,176,2,'2026-06-29 23:44:50','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (74,25,25,21,'企业客户销售顾问（扩展演示）',1,8,'上海',8,16,'本科及以上','市场营销/工商管理/不限','不限','负责企业客户线索跟进、方案讲解和合同转化。','沟通表达强，有 B 端产品理解优先。','五险一金,高提成,带薪培训',1,NULL,1,127,2,'2026-06-26 23:44:50','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (75,26,26,9,'图像算法实习生（扩展演示）',2,4,'北京',6,10,'硕士优先','人工智能/计算机/数学','不限','参与图像识别、模型评估和数据集清洗工作。','熟悉 PyTorch，具备 CV 项目经验。','实习证明,论文支持,转正机会',1,NULL,1,199,2,'2026-06-28 23:44:50','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (76,27,27,8,'测试工程师（扩展演示）',1,5,'西安',9,15,'本科及以上','计算机/软件工程','不限','负责 Web/API 测试、自动化脚本和质量度量。','熟悉测试流程，有接口自动化经验优先。','五险一金,双休,技术培训',1,NULL,1,143,2,'2026-06-25 23:44:50','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (77,28,28,19,'用户增长运营（扩展演示）',1,6,'杭州',9,15,'本科及以上','市场营销/统计/不限','不限','负责拉新、留存、活动策略和增长实验复盘。','数据敏感，执行力强，熟悉 A/B 测试优先。','五险一金,绩效奖金,下午茶',1,NULL,1,151,2,'2026-06-24 23:44:50','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (78,29,29,7,'Web 前端实习生（扩展演示）',2,5,'南京',4,7,'本科及以上','计算机/软件工程','不限','参与后台管理系统和门户页面开发。','熟悉 HTML/CSS/JavaScript，了解 Vue。','实习证明,导师带教,弹性工作',1,NULL,1,132,2,'2026-06-27 23:44:50','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (79,30,30,16,'经营分析专员（扩展演示）',1,4,'重庆',8,14,'本科及以上','统计/经济/数据科学','不限','负责经营数据监控、异常分析和月度报告输出。','熟悉 SQL/Excel/PPT，表达清晰。','五险一金,双休,节日福利',1,NULL,1,122,2,'2026-06-26 23:44:50','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_post` (`id`, `enterprise_id`, `hr_id`, `category_id`, `title`, `job_type`, `recruit_num`, `city`, `salary_min`, `salary_max`, `education`, `major_require`, `experience`, `duty`, `requirement`, `welfare`, `audit_status`, `audit_remark`, `status`, `view_count`, `apply_count`, `publish_time`, `create_time`, `update_time`, `deleted`) VALUES (80,31,31,6,'后端开发工程师（扩展演示）',1,5,'北京',15,26,'本科及以上','计算机/软件工程','不限','负责核心业务接口、任务调度和数据服务研发。','熟悉 Java/SpringBoot/Redis，理解常见设计模式。','五险一金,年终奖,技术成长',1,NULL,1,162,2,'2026-06-28 23:44:50','2026-06-30 23:44:50','2026-06-30 23:44:50',0);

-- job_apply
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (16,1,1,40,17,17,0,'',NULL,'2026-06-29 10:07:38','2026-06-30 23:32:55',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (17,1,1,30,13,13,0,'',NULL,'2026-06-30 18:08:18','2026-06-30 23:32:55',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (18,37,36,44,1,128,0,'熟悉推荐系统课程项目，希望参与后端工程化。',NULL,'2026-06-29 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (19,38,37,44,1,128,1,'有 Java 微服务项目经验，关注高并发系统。','简历已查看，后续安排技术初筛','2026-06-28 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (20,39,38,44,1,128,2,'做过内容推荐实验，熟悉 Python 和 Java。','算法工程基础较好，已邀面试','2026-06-27 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (21,41,40,45,1,129,3,'Vue 项目经验丰富，希望做工程化方向。','进入笔试环节','2026-06-25 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (22,42,41,45,1,129,5,'有交互设计背景，也学习过前端。','技术栈暂不匹配','2026-06-24 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (23,60,59,45,1,129,0,'视觉与前端复合背景。',NULL,'2026-06-20 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (24,40,39,46,1,130,2,'擅长 SQL 和 Python，可每周到岗4天。','匹配数据平台实习，已邀面试','2026-06-26 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (25,66,65,46,1,130,1,'数据科学专业，熟悉可视化分析。','待复筛','2026-06-28 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (26,47,46,47,2,132,1,'开发过校园服务小程序。','简历通过初筛','2026-06-19 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (27,67,66,47,2,132,2,'做过微信小程序毕业设计。','安排前端面试','2026-06-27 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (28,48,47,48,2,133,0,'做过校园社区产品调研。',NULL,'2026-06-18 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (29,52,51,48,2,133,5,'产品方向兴趣强，缺少实习经历。','暂不匹配','2026-06-28 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (30,62,61,48,2,133,1,'有校园调研和活动策划经验。','简历已查看','2026-06-18 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (31,71,70,48,2,133,2,'人力资源背景，擅长用户访谈。','已邀业务面试','2026-06-23 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (32,51,50,49,2,131,3,'网络安全竞赛经历，熟悉 Linux。','进入笔试环节','2026-06-29 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (33,61,60,49,2,131,2,'网络空间安全方向，有攻防演练经历。','已邀面试','2026-06-19 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (34,49,48,50,4,134,2,'熟悉 Docker 和 Linux，做过服务部署平台。','基础扎实，安排面试','2026-06-17 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (35,63,62,50,4,134,0,'通信工程背景，熟悉 Linux。',NULL,'2026-06-17 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (36,69,68,50,4,134,5,'硬件背景更强，平台开发经验不足。','暂不匹配','2026-06-25 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (37,55,54,51,4,135,2,'熟悉 Spark 和 Hive 课程项目。','数据链路经验匹配','2026-06-25 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (38,59,58,51,4,135,1,'统计背景，熟悉 SQL 和 Python。','待复筛','2026-06-21 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (39,50,49,52,4,136,1,'熟悉自动化测试，有 Selenium 项目经验。','待安排测试开发笔试','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (40,68,67,52,4,136,0,'熟悉测试用例设计和缺陷管理。',NULL,'2026-06-26 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (41,45,44,53,5,137,4,'熟悉 SpringBoot 和订单系统课程设计。','综合表现优秀，已录用','2026-06-21 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (42,64,63,53,5,137,2,'Java 基础扎实，了解 Redis 和 MQ。','已邀面试','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (43,43,42,54,5,138,1,'参与过校园社团运营和活动复盘。','待业务负责人复筛','2026-06-23 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (44,44,43,54,5,138,2,'人力资源方向，希望轮岗学习运营管理。','沟通表达好，已邀面试','2026-06-22 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (45,56,55,54,5,138,0,'希望从事城市运营方向。',NULL,'2026-06-24 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (46,65,64,54,5,138,2,'市场营销专业，有社群运营经验。','已邀面试','2026-06-29 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (47,46,45,55,10,139,2,'研究生方向为多模态检索，有论文复现经验。','技术匹配，已邀面试','2026-06-20 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (48,53,52,55,10,139,4,'多模态模型实验经验丰富，代码能力强。','已发 Offer','2026-06-27 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (49,58,57,55,10,139,2,'方向为图文检索，熟悉 PyTorch。','安排算法面试','2026-06-22 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (50,72,71,55,10,139,0,'AI 专业，正在补充算法项目。',NULL,'2026-06-22 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (51,54,53,56,10,140,2,'Java 后端基础扎实，做过大模型应用 Demo。','已邀一面','2026-06-26 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (52,57,56,56,10,140,4,'研究生，有 SpringCloud 项目经验。','已录用','2026-06-23 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (53,70,69,56,10,140,1,'做过 AI 问答系统后端。','简历已查看','2026-06-24 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (81,37,36,74,25,25,1,'演示投递：顾晓晨 对「企业客户销售顾问（扩展演示）」岗位感兴趣。','简历已查看，待进一步筛选','2026-06-29 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (82,38,37,75,26,26,3,'演示投递：林雨薇 对「图像算法实习生（扩展演示）」岗位感兴趣。','进入笔试环节','2026-06-27 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (83,38,37,57,6,6,3,'演示投递：林雨薇 对「在线教育新媒体运营（扩展演示）」岗位感兴趣。','进入笔试环节','2026-06-27 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (84,39,38,75,26,26,4,'演示投递：许嘉豪 对「图像算法实习生（扩展演示）」岗位感兴趣。','综合表现较好，进入录用','2026-06-26 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (85,39,38,57,6,6,4,'演示投递：许嘉豪 对「在线教育新媒体运营（扩展演示）」岗位感兴趣。','综合表现较好，进入录用','2026-06-26 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (86,40,39,76,27,27,0,'演示投递：沈一诺 对「测试工程师（扩展演示）」岗位感兴趣。',NULL,'2026-06-24 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (87,40,39,58,7,7,0,'演示投递：沈一诺 对「金融数据分析师（扩展演示）」岗位感兴趣。',NULL,'2026-06-24 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (88,41,40,76,27,27,1,'演示投递：陈景行 对「测试工程师（扩展演示）」岗位感兴趣。','简历已查看，待进一步筛选','2026-06-23 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (89,41,40,58,7,7,1,'演示投递：陈景行 对「金融数据分析师（扩展演示）」岗位感兴趣。','简历已查看，待进一步筛选','2026-06-23 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (90,42,41,77,28,28,3,'演示投递：赵思琪 对「用户增长运营（扩展演示）」岗位感兴趣。','进入笔试环节','2026-06-21 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (91,42,41,59,8,8,3,'演示投递：赵思琪 对「智能制造 Java 工程师（扩展演示）」岗位感兴趣。','进入笔试环节','2026-06-21 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (92,43,42,77,28,28,4,'演示投递：黄子昂 对「用户增长运营（扩展演示）」岗位感兴趣。','综合表现较好，进入录用','2026-06-20 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (93,43,42,59,8,8,4,'演示投递：黄子昂 对「智能制造 Java 工程师（扩展演示）」岗位感兴趣。','综合表现较好，进入录用','2026-06-20 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (94,44,43,78,29,29,0,'演示投递：吴清欢 对「Web 前端实习生（扩展演示）」岗位感兴趣。',NULL,'2026-06-18 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (95,44,43,60,11,11,0,'演示投递：吴清欢 对「物流调度平台开发工程师（扩展演示）」岗位感兴趣。',NULL,'2026-06-18 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (96,45,44,78,29,29,1,'演示投递：周明远 对「Web 前端实习生（扩展演示）」岗位感兴趣。','简历已查看，待进一步筛选','2026-06-17 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (97,45,44,60,11,11,1,'演示投递：周明远 对「物流调度平台开发工程师（扩展演示）」岗位感兴趣。','简历已查看，待进一步筛选','2026-06-17 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (98,46,45,79,30,30,3,'演示投递：郑语桐 对「经营分析专员（扩展演示）」岗位感兴趣。','进入笔试环节','2026-06-15 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (99,46,45,61,12,12,3,'演示投递：郑语桐 对「游戏 UI 视觉设计师（扩展演示）」岗位感兴趣。','进入笔试环节','2026-06-15 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (100,47,46,79,30,30,4,'演示投递：唐逸飞 对「经营分析专员（扩展演示）」岗位感兴趣。','综合表现较好，进入录用','2026-06-14 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (101,47,46,61,12,12,4,'演示投递：唐逸飞 对「游戏 UI 视觉设计师（扩展演示）」岗位感兴趣。','综合表现较好，进入录用','2026-06-14 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (102,48,47,80,31,31,0,'演示投递：冯若溪 对「后端开发工程师（扩展演示）」岗位感兴趣。',NULL,'2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (103,48,47,62,13,13,0,'演示投递：冯若溪 对「连锁餐饮电商运营（扩展演示）」岗位感兴趣。',NULL,'2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (104,49,48,80,31,31,1,'演示投递：蒋承泽 对「后端开发工程师（扩展演示）」岗位感兴趣。','简历已查看，待进一步筛选','2026-06-29 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (105,49,48,62,13,13,1,'演示投递：蒋承泽 对「连锁餐饮电商运营（扩展演示）」岗位感兴趣。','简历已查看，待进一步筛选','2026-06-29 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (106,50,49,63,14,14,3,'演示投递：苏芷晴 对「酒店客户服务管培生（扩展演示）」岗位感兴趣。','进入笔试环节','2026-06-27 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (107,51,50,63,14,14,4,'演示投递：邹凯文 对「酒店客户服务管培生（扩展演示）」岗位感兴趣。','综合表现较好，进入录用','2026-06-26 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (108,52,51,64,15,15,0,'演示投递：姜沐言 对「门店零售储备干部（扩展演示）」岗位感兴趣。',NULL,'2026-06-24 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (109,53,52,64,15,15,1,'演示投递：程浩然 对「门店零售储备干部（扩展演示）」岗位感兴趣。','简历已查看，待进一步筛选','2026-06-23 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (110,54,53,65,16,16,3,'演示投递：罗诗涵 对「BI 数据分析实习生（扩展演示）」岗位感兴趣。','进入笔试环节','2026-06-21 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (111,55,54,65,16,16,4,'演示投递：韩亦辰 对「BI 数据分析实习生（扩展演示）」岗位感兴趣。','综合表现较好，进入录用','2026-06-20 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (112,56,55,66,17,17,0,'演示投递：宋安然 对「校园服务行政专员（扩展演示）」岗位感兴趣。',NULL,'2026-06-18 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (113,57,56,66,17,17,1,'演示投递：梁峻熙 对「校园服务行政专员（扩展演示）」岗位感兴趣。','简历已查看，待进一步筛选','2026-06-17 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (114,58,57,67,18,18,3,'演示投递：叶知秋 对「数字化平台后端工程师（扩展演示）」岗位感兴趣。','进入笔试环节','2026-06-15 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (115,59,58,67,18,18,4,'演示投递：许星河 对「数字化平台后端工程师（扩展演示）」岗位感兴趣。','综合表现较好，进入录用','2026-06-14 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (116,60,59,68,19,19,0,'演示投递：白若宁 对「校招 HR 助理（扩展演示）」岗位感兴趣。',NULL,'2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (117,61,60,68,19,19,1,'演示投递：陆景川 对「校招 HR 助理（扩展演示）」岗位感兴趣。','简历已查看，待进一步筛选','2026-06-29 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (118,62,61,69,20,20,3,'演示投递：乔欣然 对「零售系统前端开发（扩展演示）」岗位感兴趣。','进入笔试环节','2026-06-27 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (119,63,62,69,20,20,4,'演示投递：戴子墨 对「零售系统前端开发（扩展演示）」岗位感兴趣。','综合表现较好，进入录用','2026-06-26 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (120,64,63,70,21,21,0,'演示投递：夏晚晴 对「内容运营专员（扩展演示）」岗位感兴趣。',NULL,'2026-06-24 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (121,65,64,70,21,21,1,'演示投递：秦朗 对「内容运营专员（扩展演示）」岗位感兴趣。','简历已查看，待进一步筛选','2026-06-23 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (122,66,65,71,22,22,3,'演示投递：穆清越 对「财务管培生（扩展演示）」岗位感兴趣。','进入笔试环节','2026-06-21 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (123,67,66,71,22,22,4,'演示投递：石天佑 对「财务管培生（扩展演示）」岗位感兴趣。','综合表现较好，进入录用','2026-06-20 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (124,68,67,72,23,23,0,'演示投递：季云舒 对「数据产品经理助理（扩展演示）」岗位感兴趣。',NULL,'2026-06-18 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (125,69,68,72,23,23,1,'演示投递：何以安 对「数据产品经理助理（扩展演示）」岗位感兴趣。','简历已查看，待进一步筛选','2026-06-17 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (126,70,69,73,24,24,3,'演示投递：郝思源 对「SaaS 后端开发工程师（扩展演示）」岗位感兴趣。','进入笔试环节','2026-06-15 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (127,71,70,73,24,24,4,'演示投递：孟可欣 对「SaaS 后端开发工程师（扩展演示）」岗位感兴趣。','综合表现较好，进入录用','2026-06-14 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `job_apply` (`id`, `student_id`, `resume_id`, `job_id`, `enterprise_id`, `hr_id`, `status`, `apply_remark`, `hr_remark`, `create_time`, `update_time`, `deleted`) VALUES (128,72,71,74,25,25,0,'演示投递：杜若飞 对「企业客户销售顾问（扩展演示）」岗位感兴趣。',NULL,'2026-06-30 23:44:50','2026-06-30 23:44:50',0);

-- interview_notice
INSERT IGNORE INTO `interview_notice` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `interview_time`, `interview_type`, `location`, `contact`, `remark`, `student_status`, `create_time`, `update_time`, `deleted`) VALUES (6,20,39,1,128,44,'2026-07-05 23:42:49',1,'线下面试：北京办公区','13810001001','请提前准备项目经历和岗位相关问题。',1,'2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `interview_notice` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `interview_time`, `interview_type`, `location`, `contact`, `remark`, `student_status`, `create_time`, `update_time`, `deleted`) VALUES (7,24,40,1,130,46,'2026-07-01 23:42:49',2,'腾讯会议/飞书会议链接将在面试前发送','13810001003','请提前准备项目经历和岗位相关问题。',0,'2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `interview_notice` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `interview_time`, `interview_type`, `location`, `contact`, `remark`, `student_status`, `create_time`, `update_time`, `deleted`) VALUES (8,27,67,2,132,47,'2026-07-03 23:42:49',1,'线下面试：深圳办公区','13810002002','请提前准备项目经历和岗位相关问题。',0,'2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `interview_notice` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `interview_time`, `interview_type`, `location`, `contact`, `remark`, `student_status`, `create_time`, `update_time`, `deleted`) VALUES (9,31,71,2,133,48,'2026-07-02 23:42:49',1,'线下面试：深圳办公区','13810002003','请提前准备项目经历和岗位相关问题。',0,'2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `interview_notice` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `interview_time`, `interview_type`, `location`, `contact`, `remark`, `student_status`, `create_time`, `update_time`, `deleted`) VALUES (10,33,61,2,131,49,'2026-07-02 23:42:49',1,'线下面试：深圳办公区','13810002001','请提前准备项目经历和岗位相关问题。',0,'2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `interview_notice` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `interview_time`, `interview_type`, `location`, `contact`, `remark`, `student_status`, `create_time`, `update_time`, `deleted`) VALUES (11,34,49,4,134,50,'2026-07-05 23:42:49',1,'线下面试：杭州办公区','13810004001','请提前准备项目经历和岗位相关问题。',0,'2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `interview_notice` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `interview_time`, `interview_type`, `location`, `contact`, `remark`, `student_status`, `create_time`, `update_time`, `deleted`) VALUES (12,37,55,4,135,51,'2026-07-01 23:42:49',1,'线下面试：杭州办公区','13810004002','请提前准备项目经历和岗位相关问题。',0,'2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `interview_notice` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `interview_time`, `interview_type`, `location`, `contact`, `remark`, `student_status`, `create_time`, `update_time`, `deleted`) VALUES (13,42,64,5,137,53,'2026-07-05 23:42:49',2,'腾讯会议/飞书会议链接将在面试前发送','13810005001','请提前准备项目经历和岗位相关问题。',0,'2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `interview_notice` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `interview_time`, `interview_type`, `location`, `contact`, `remark`, `student_status`, `create_time`, `update_time`, `deleted`) VALUES (14,44,44,5,138,54,'2026-07-05 23:42:49',2,'腾讯会议/飞书会议链接将在面试前发送','13810005002','请提前准备项目经历和岗位相关问题。',0,'2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `interview_notice` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `interview_time`, `interview_type`, `location`, `contact`, `remark`, `student_status`, `create_time`, `update_time`, `deleted`) VALUES (15,46,65,5,138,54,'2026-07-01 23:42:49',1,'线下面试：北京办公区','13810005002','请提前准备项目经历和岗位相关问题。',0,'2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `interview_notice` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `interview_time`, `interview_type`, `location`, `contact`, `remark`, `student_status`, `create_time`, `update_time`, `deleted`) VALUES (16,47,46,10,139,55,'2026-07-02 23:42:49',2,'腾讯会议/飞书会议链接将在面试前发送','13810010001','请提前准备项目经历和岗位相关问题。',0,'2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `interview_notice` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `interview_time`, `interview_type`, `location`, `contact`, `remark`, `student_status`, `create_time`, `update_time`, `deleted`) VALUES (17,49,58,10,139,55,'2026-07-04 23:42:49',2,'腾讯会议/飞书会议链接将在面试前发送','13810010001','请提前准备项目经历和岗位相关问题。',0,'2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `interview_notice` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `interview_time`, `interview_type`, `location`, `contact`, `remark`, `student_status`, `create_time`, `update_time`, `deleted`) VALUES (18,51,54,10,140,56,'2026-07-05 23:42:49',2,'腾讯会议/飞书会议链接将在面试前发送','13810010002','请提前准备项目经历和岗位相关问题。',1,'2026-06-30 23:42:49','2026-06-30 23:42:49',0);

-- interview_feedback
INSERT IGNORE INTO `interview_feedback` (`id`, `notice_id`, `apply_id`, `enterprise_id`, `hr_id`, `score`, `content`, `is_pass`, `interviewer`, `create_time`, `update_time`, `deleted`) VALUES (4,6,20,1,128,94,'沟通顺畅，基础扎实，项目表达清晰，建议进入后续流程。',1,'王敏-后端招聘','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `interview_feedback` (`id`, `notice_id`, `apply_id`, `enterprise_id`, `hr_id`, `score`, `content`, `is_pass`, `interviewer`, `create_time`, `update_time`, `deleted`) VALUES (5,18,51,10,140,89,'沟通顺畅，基础扎实，项目表达清晰，建议进入后续流程。',1,'沈琳-校招主管','2026-06-30 23:42:49','2026-06-30 23:42:49',0);

-- offer_record
INSERT IGNORE INTO `offer_record` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `position`, `salary`, `work_city`, `report_time`, `content`, `offer_status`, `create_time`, `update_time`, `deleted`) VALUES (6,41,45,5,137,53,'履约系统 Java 开发工程师（校招演示）','18-32K * 14薪','北京','2026-07-15','恭喜通过 履约系统 Java 开发工程师（校招演示） 校招流程，请在系统内确认 Offer。',0,'2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `offer_record` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `position`, `salary`, `work_city`, `report_time`, `content`, `offer_status`, `create_time`, `update_time`, `deleted`) VALUES (7,48,53,10,139,55,'多模态算法工程师（校招演示）','25-45K * 14薪','北京','2026-07-15','恭喜通过 多模态算法工程师（校招演示） 校招流程，请在系统内确认 Offer。',0,'2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `offer_record` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `position`, `salary`, `work_city`, `report_time`, `content`, `offer_status`, `create_time`, `update_time`, `deleted`) VALUES (8,52,57,10,140,56,'AI 应用后端工程师（校招演示）','20-34K * 14薪','北京','2026-07-15','恭喜通过 AI 应用后端工程师（校招演示） 校招流程，请在系统内确认 Offer。',0,'2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `offer_record` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `position`, `salary`, `work_city`, `report_time`, `content`, `offer_status`, `create_time`, `update_time`, `deleted`) VALUES (9,84,39,26,26,75,'图像算法实习生（扩展演示）','6-10K * 14薪','北京','2026-07-15','恭喜通过 图像算法实习生（扩展演示） 招聘流程，请在系统内确认 Offer。',0,'2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `offer_record` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `position`, `salary`, `work_city`, `report_time`, `content`, `offer_status`, `create_time`, `update_time`, `deleted`) VALUES (10,85,39,6,6,57,'在线教育新媒体运营（扩展演示）','9-15K * 14薪','北京','2026-07-15','恭喜通过 在线教育新媒体运营（扩展演示） 招聘流程，请在系统内确认 Offer。',0,'2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `offer_record` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `position`, `salary`, `work_city`, `report_time`, `content`, `offer_status`, `create_time`, `update_time`, `deleted`) VALUES (11,92,43,28,28,77,'用户增长运营（扩展演示）','9-15K * 14薪','杭州','2026-07-15','恭喜通过 用户增长运营（扩展演示） 招聘流程，请在系统内确认 Offer。',0,'2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `offer_record` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `position`, `salary`, `work_city`, `report_time`, `content`, `offer_status`, `create_time`, `update_time`, `deleted`) VALUES (12,93,43,8,8,59,'智能制造 Java 工程师（扩展演示）','13-22K * 14薪','苏州','2026-07-15','恭喜通过 智能制造 Java 工程师（扩展演示） 招聘流程，请在系统内确认 Offer。',0,'2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `offer_record` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `position`, `salary`, `work_city`, `report_time`, `content`, `offer_status`, `create_time`, `update_time`, `deleted`) VALUES (13,100,47,30,30,79,'经营分析专员（扩展演示）','8-14K * 14薪','重庆','2026-07-15','恭喜通过 经营分析专员（扩展演示） 招聘流程，请在系统内确认 Offer。',0,'2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `offer_record` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `position`, `salary`, `work_city`, `report_time`, `content`, `offer_status`, `create_time`, `update_time`, `deleted`) VALUES (14,101,47,12,12,61,'游戏 UI 视觉设计师（扩展演示）','12-20K * 14薪','上海','2026-07-15','恭喜通过 游戏 UI 视觉设计师（扩展演示） 招聘流程，请在系统内确认 Offer。',0,'2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `offer_record` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `position`, `salary`, `work_city`, `report_time`, `content`, `offer_status`, `create_time`, `update_time`, `deleted`) VALUES (15,107,51,14,14,63,'酒店客户服务管培生（扩展演示）','7-12K * 14薪','三亚','2026-07-15','恭喜通过 酒店客户服务管培生（扩展演示） 招聘流程，请在系统内确认 Offer。',0,'2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `offer_record` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `position`, `salary`, `work_city`, `report_time`, `content`, `offer_status`, `create_time`, `update_time`, `deleted`) VALUES (16,111,55,16,16,65,'BI 数据分析实习生（扩展演示）','4-7K * 14薪','深圳','2026-07-15','恭喜通过 BI 数据分析实习生（扩展演示） 招聘流程，请在系统内确认 Offer。',0,'2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `offer_record` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `position`, `salary`, `work_city`, `report_time`, `content`, `offer_status`, `create_time`, `update_time`, `deleted`) VALUES (17,115,59,18,18,67,'数字化平台后端工程师（扩展演示）','13-24K * 14薪','武汉','2026-07-15','恭喜通过 数字化平台后端工程师（扩展演示） 招聘流程，请在系统内确认 Offer。',0,'2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `offer_record` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `position`, `salary`, `work_city`, `report_time`, `content`, `offer_status`, `create_time`, `update_time`, `deleted`) VALUES (18,119,63,20,20,69,'零售系统前端开发（扩展演示）','12-20K * 14薪','上海','2026-07-15','恭喜通过 零售系统前端开发（扩展演示） 招聘流程，请在系统内确认 Offer。',0,'2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `offer_record` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `position`, `salary`, `work_city`, `report_time`, `content`, `offer_status`, `create_time`, `update_time`, `deleted`) VALUES (19,123,67,22,22,71,'财务管培生（扩展演示）','8-13K * 14薪','厦门','2026-07-15','恭喜通过 财务管培生（扩展演示） 招聘流程，请在系统内确认 Offer。',0,'2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `offer_record` (`id`, `apply_id`, `student_id`, `enterprise_id`, `hr_id`, `job_id`, `position`, `salary`, `work_city`, `report_time`, `content`, `offer_status`, `create_time`, `update_time`, `deleted`) VALUES (20,127,71,24,24,73,'SaaS 后端开发工程师（扩展演示）','14-25K * 14薪','杭州','2026-07-15','恭喜通过 SaaS 后端开发工程师（扩展演示） 招聘流程，请在系统内确认 Offer。',0,'2026-06-30 23:44:50','2026-06-30 23:44:50',0);

-- talent_pool
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (7,1,128,38,37,'已初筛','演示数据：林雨薇 适合后续校园招聘跟进。','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (8,1,128,39,38,'面试中','演示数据：许嘉豪 适合后续校园招聘跟进。','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (9,1,130,40,39,'面试中','演示数据：沈一诺 适合后续校园招聘跟进。','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (10,1,130,66,65,'已初筛','演示数据：穆清越 适合后续校园招聘跟进。','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (11,2,132,47,46,'已初筛','演示数据：唐逸飞 适合后续校园招聘跟进。','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (12,2,132,67,66,'面试中','演示数据：石天佑 适合后续校园招聘跟进。','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (13,2,133,62,61,'已初筛','演示数据：乔欣然 适合后续校园招聘跟进。','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (14,2,133,71,70,'面试中','演示数据：孟可欣 适合后续校园招聘跟进。','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (15,2,131,61,60,'面试中','演示数据：陆景川 适合后续校园招聘跟进。','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (16,4,134,49,48,'面试中','演示数据：蒋承泽 适合后续校园招聘跟进。','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (17,4,135,55,54,'面试中','演示数据：韩亦辰 适合后续校园招聘跟进。','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (18,4,135,59,58,'已初筛','演示数据：许星河 适合后续校园招聘跟进。','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (19,4,136,50,49,'已初筛','演示数据：苏芷晴 适合后续校园招聘跟进。','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (20,5,137,45,44,'录用候选','演示数据：周明远 适合后续校园招聘跟进。','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (21,5,137,64,63,'面试中','演示数据：夏晚晴 适合后续校园招聘跟进。','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (22,5,138,43,42,'已初筛','演示数据：黄子昂 适合后续校园招聘跟进。','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (23,5,138,44,43,'面试中','演示数据：吴清欢 适合后续校园招聘跟进。','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (24,5,138,65,64,'面试中','演示数据：秦朗 适合后续校园招聘跟进。','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (25,10,139,46,45,'面试中','演示数据：郑语桐 适合后续校园招聘跟进。','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (26,10,139,53,52,'录用候选','演示数据：程浩然 适合后续校园招聘跟进。','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (27,10,139,58,57,'面试中','演示数据：叶知秋 适合后续校园招聘跟进。','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (28,10,140,54,53,'面试中','演示数据：罗诗涵 适合后续校园招聘跟进。','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (29,10,140,57,56,'录用候选','演示数据：梁峻熙 适合后续校园招聘跟进。','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (30,10,140,70,69,'已初筛','演示数据：郝思源 适合后续校园招聘跟进。','2026-06-30 23:42:49','2026-06-30 23:42:49',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (38,6,6,39,38,'录用候选','演示数据：许嘉豪 可用于人才库跟进。','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (39,7,7,41,40,'已初筛','演示数据：陈景行 可用于人才库跟进。','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (40,8,8,43,42,'录用候选','演示数据：黄子昂 可用于人才库跟进。','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (41,11,11,45,44,'已初筛','演示数据：周明远 可用于人才库跟进。','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (42,12,12,47,46,'录用候选','演示数据：唐逸飞 可用于人才库跟进。','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (43,13,13,49,48,'已初筛','演示数据：蒋承泽 可用于人才库跟进。','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (44,14,14,51,50,'录用候选','演示数据：邹凯文 可用于人才库跟进。','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (45,15,15,53,52,'已初筛','演示数据：程浩然 可用于人才库跟进。','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (46,16,16,55,54,'录用候选','演示数据：韩亦辰 可用于人才库跟进。','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (47,17,17,57,56,'已初筛','演示数据：梁峻熙 可用于人才库跟进。','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (48,18,18,59,58,'录用候选','演示数据：许星河 可用于人才库跟进。','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (49,19,19,61,60,'已初筛','演示数据：陆景川 可用于人才库跟进。','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (50,20,20,63,62,'录用候选','演示数据：戴子墨 可用于人才库跟进。','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (51,21,21,65,64,'已初筛','演示数据：秦朗 可用于人才库跟进。','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (52,22,22,67,66,'录用候选','演示数据：石天佑 可用于人才库跟进。','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (53,23,23,69,68,'已初筛','演示数据：何以安 可用于人才库跟进。','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (54,24,24,71,70,'录用候选','演示数据：孟可欣 可用于人才库跟进。','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (55,25,25,37,36,'已初筛','演示数据：顾晓晨 可用于人才库跟进。','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (56,26,26,39,38,'录用候选','演示数据：许嘉豪 可用于人才库跟进。','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (57,27,27,41,40,'已初筛','演示数据：陈景行 可用于人才库跟进。','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (58,28,28,43,42,'录用候选','演示数据：黄子昂 可用于人才库跟进。','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (59,29,29,45,44,'已初筛','演示数据：周明远 可用于人才库跟进。','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (60,30,30,47,46,'录用候选','演示数据：唐逸飞 可用于人才库跟进。','2026-06-30 23:44:50','2026-06-30 23:44:50',0);
INSERT IGNORE INTO `talent_pool` (`id`, `enterprise_id`, `hr_id`, `student_id`, `resume_id`, `tag`, `remark`, `create_time`, `update_time`, `deleted`) VALUES (61,31,31,49,48,'已初筛','演示数据：蒋承泽 可用于人才库跟进。','2026-06-30 23:44:50','2026-06-30 23:44:50',0);

-- activity_sign
INSERT IGNORE INTO `activity_sign` (`id`, `activity_type`, `activity_id`, `student_id`, `sign_status`, `create_time`, `update_time`, `deleted`) VALUES (15,1,4,1,1,'2026-06-25 21:48:13','2026-06-25 21:48:13',0);
INSERT IGNORE INTO `activity_sign` (`id`, `activity_type`, `activity_id`, `student_id`, `sign_status`, `create_time`, `update_time`, `deleted`) VALUES (16,2,24,1,1,'2026-06-27 01:49:48','2026-06-27 01:49:48',0);
INSERT IGNORE INTO `activity_sign` (`id`, `activity_type`, `activity_id`, `student_id`, `sign_status`, `create_time`, `update_time`, `deleted`) VALUES (17,1,23,1,1,'2026-06-29 09:18:09','2026-06-29 09:18:09',0);
INSERT IGNORE INTO `activity_sign` (`id`, `activity_type`, `activity_id`, `student_id`, `sign_status`, `create_time`, `update_time`, `deleted`) VALUES (18,1,25,1,1,'2026-06-29 10:08:07','2026-06-29 10:08:07',0);

-- favorite_job
INSERT IGNORE INTO `favorite_job` (`id`, `student_id`, `job_id`, `create_time`, `update_time`, `deleted`) VALUES (19,1,29,'2026-06-30 10:43:18','2026-06-30 10:43:19',1);
INSERT IGNORE INTO `favorite_job` (`id`, `student_id`, `job_id`, `create_time`, `update_time`, `deleted`) VALUES (20,1,6,'2026-06-30 16:45:49','2026-06-30 16:45:49',0);

-- chat_message
INSERT IGNORE INTO `chat_message` (`id`, `from_user_id`, `from_role`, `to_user_id`, `to_role`, `job_id`, `seeker_post_id`, `content`, `is_read`, `create_time`, `update_time`, `deleted`) VALUES (3,1,'ENTERPRISE',1,'STUDENT',NULL,1,'有兴趣来我们公司吗',1,'2026-06-29 09:17:29','2026-06-29 10:08:52',0);
INSERT IGNORE INTO `chat_message` (`id`, `from_user_id`, `from_role`, `to_user_id`, `to_role`, `job_id`, `seeker_post_id`, `content`, `is_read`, `create_time`, `update_time`, `deleted`) VALUES (4,1,'STUDENT',1,'ENTERPRISE',NULL,NULL,'111',1,'2026-06-29 10:08:56','2026-06-29 10:10:35',0);
INSERT IGNORE INTO `chat_message` (`id`, `from_user_id`, `from_role`, `to_user_id`, `to_role`, `job_id`, `seeker_post_id`, `content`, `is_read`, `create_time`, `update_time`, `deleted`) VALUES (5,1,'ENTERPRISE',16,'STUDENT',NULL,15,'[resume-card]{\"type\":\"RESUME_REQUEST\",\"title\":\"请求查看简历\",\"text\":\"HR 请求查看你的在线简历或附件简历。\"}',0,'2026-06-30 18:10:11','2026-06-30 18:10:11',0);
-- END LOCAL DEMO DATA PATCH
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
