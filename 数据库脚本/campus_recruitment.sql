/*
 ============================================================================
  校园求职招聘系统 - 数据库脚本
  Database : campus_recruitment
  Charset  : utf8mb4 / utf8mb4_general_ci
  Engine   : InnoDB
  适配     : MySQL 5.7+ / 8.0+，可用 Navicat Premium 17 直接导入
 ----------------------------------------------------------------------------
  说明：
  1. 本脚本会自动创建数据库 campus_recruitment 并切换使用。
  2. 所有表均含 create_time / update_time / deleted(逻辑删除) 公共字段。
  3. 主键统一 bigint 自增。
  4. 密码字段存储 BCrypt 加密串，初始测试账号明文均为 123456。
  5. 末尾附带字典数据、轮播图、公告、宣讲会、招聘会、职位、简历等演示数据
     以及三类角色测试账号，导入后即可直接登录体验。
 ============================================================================
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS `campus_recruitment`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE `campus_recruitment`;

-- ============================================================================
-- 1. 权限与角色
-- ============================================================================

-- ----------------------------
-- 角色表
-- ----------------------------
DROP TABLE IF EXISTS `role`;
CREATE TABLE `role` (
  `id`          bigint       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `role_code`   varchar(50)  NOT NULL COMMENT '角色编码：ADMIN/ENTERPRISE/STUDENT',
  `role_name`   varchar(50)  NOT NULL COMMENT '角色名称',
  `description` varchar(255)          DEFAULT NULL COMMENT '描述',
  `create_time` datetime              DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime              DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`     tinyint      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_code` (`role_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色表';

-- ----------------------------
-- 权限表
-- ----------------------------
DROP TABLE IF EXISTS `permission`;
CREATE TABLE `permission` (
  `id`          bigint       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `perm_code`   varchar(80)  NOT NULL COMMENT '权限编码',
  `perm_name`   varchar(80)  NOT NULL COMMENT '权限名称',
  `perm_type`   varchar(20)           DEFAULT 'MENU' COMMENT '类型：MENU菜单/BUTTON按钮',
  `parent_id`   bigint                DEFAULT 0 COMMENT '父级ID',
  `path`        varchar(200)          DEFAULT NULL COMMENT '前端路由路径',
  `sort`        int                   DEFAULT 0 COMMENT '排序',
  `create_time` datetime              DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime              DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`     tinyint      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_perm_code` (`perm_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='权限表';

-- ----------------------------
-- 角色-权限关联表
-- ----------------------------
DROP TABLE IF EXISTS `role_permission`;
CREATE TABLE `role_permission` (
  `id`            bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `role_id`       bigint NOT NULL COMMENT '角色ID',
  `permission_id` bigint NOT NULL COMMENT '权限ID',
  PRIMARY KEY (`id`),
  KEY `idx_rp_role` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色权限关联表';

-- ----------------------------
-- 管理员/就业办用户表
-- ----------------------------
DROP TABLE IF EXISTS `admin_user`;
CREATE TABLE `admin_user` (
  `id`          bigint       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username`    varchar(50)  NOT NULL COMMENT '登录账号',
  `password`    varchar(100) NOT NULL COMMENT '密码(BCrypt)',
  `real_name`   varchar(50)           DEFAULT NULL COMMENT '姓名',
  `phone`       varchar(20)           DEFAULT NULL COMMENT '手机号',
  `email`       varchar(80)           DEFAULT NULL COMMENT '邮箱',
  `avatar`      varchar(255)          DEFAULT NULL COMMENT '头像',
  `role_id`     bigint                DEFAULT NULL COMMENT '角色ID',
  `status`      tinyint      NOT NULL DEFAULT 1 COMMENT '状态：1正常0禁用',
  `last_login`  datetime              DEFAULT NULL COMMENT '最后登录时间',
  `create_time` datetime              DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime              DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`     tinyint      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_admin_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='管理员用户表';

-- ============================================================================
-- 2. 学生 / 企业 用户
-- ============================================================================

-- ----------------------------
-- 学生表
-- ----------------------------
DROP TABLE IF EXISTS `student`;
CREATE TABLE `student` (
  `id`            bigint       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username`      varchar(50)  NOT NULL COMMENT '登录账号',
  `password`      varchar(100) NOT NULL COMMENT '密码(BCrypt)',
  `real_name`     varchar(50)           DEFAULT NULL COMMENT '姓名',
  `student_no`    varchar(30)           DEFAULT NULL COMMENT '学号',
  `gender`        tinyint               DEFAULT 0 COMMENT '性别：0未知1男2女',
  `college`       varchar(80)           DEFAULT NULL COMMENT '学院',
  `major`         varchar(80)           DEFAULT NULL COMMENT '专业',
  `grade`         varchar(20)           DEFAULT NULL COMMENT '年级',
  `education`     varchar(20)           DEFAULT NULL COMMENT '学历',
  `phone`         varchar(20)           DEFAULT NULL COMMENT '手机号',
  `email`         varchar(80)           DEFAULT NULL COMMENT '邮箱',
  `avatar`        varchar(255)          DEFAULT NULL COMMENT '头像',
  `intro`         varchar(500)          DEFAULT NULL COMMENT '个人简介',
  `status`        tinyint      NOT NULL DEFAULT 1 COMMENT '状态：1正常0禁用',
  `last_login`    datetime              DEFAULT NULL COMMENT '最后登录时间',
  `create_time`   datetime              DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`   datetime              DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`       tinyint      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_student_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生表';

-- ----------------------------
-- 求职意向表
-- ----------------------------
DROP TABLE IF EXISTS `job_intention`;
CREATE TABLE `job_intention` (
  `id`             bigint      NOT NULL AUTO_INCREMENT COMMENT '主键',
  `student_id`     bigint      NOT NULL COMMENT '学生ID',
  `expect_post`    varchar(80)          DEFAULT NULL COMMENT '期望岗位',
  `expect_city`    varchar(80)          DEFAULT NULL COMMENT '期望城市',
  `expect_salary`  varchar(40)          DEFAULT NULL COMMENT '期望薪资',
  `job_type`       tinyint              DEFAULT 1 COMMENT '类型：1全职2实习',
  `arrival_time`   varchar(40)          DEFAULT NULL COMMENT '到岗时间',
  `create_time`    datetime             DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`    datetime             DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`        tinyint     NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_intention_student` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='求职意向表';

-- ----------------------------
-- 企业表
-- ----------------------------
DROP TABLE IF EXISTS `enterprise`;
CREATE TABLE `enterprise` (
  `id`            bigint       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username`      varchar(50)  NOT NULL COMMENT '登录账号',
  `password`      varchar(100) NOT NULL COMMENT '密码(BCrypt)',
  `company_name`  varchar(120) NOT NULL COMMENT '企业名称',
  `credit_code`   varchar(18)           DEFAULT NULL COMMENT '统一社会信用代码',
  `industry`      varchar(60)           DEFAULT NULL COMMENT '所属行业',
  `scale`         varchar(40)           DEFAULT NULL COMMENT '企业规模',
  `nature`        varchar(40)           DEFAULT NULL COMMENT '企业性质',
  `address`       varchar(200)          DEFAULT NULL COMMENT '地址',
  `city`          varchar(60)           DEFAULT NULL COMMENT '所在城市',
  `logo`          varchar(255)          DEFAULT NULL COMMENT 'Logo',
  `intro`         text                  COMMENT '企业简介',
  `welfare`       varchar(255)          DEFAULT NULL COMMENT '福利标签(逗号分隔)',
  `contact_name`  varchar(50)           DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(20)           DEFAULT NULL COMMENT '联系电话',
  `email`         varchar(80)           DEFAULT NULL COMMENT '邮箱',
  `website`       varchar(120)          DEFAULT NULL COMMENT '官网',
  `audit_status`  tinyint      NOT NULL DEFAULT 0 COMMENT '认证状态：0未认证1待审核2已通过3已驳回',
  `status`        tinyint      NOT NULL DEFAULT 1 COMMENT '状态：1正常0禁用',
  `last_login`    datetime              DEFAULT NULL COMMENT '最后登录时间',
  `create_time`   datetime              DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`   datetime              DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`       tinyint      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_enterprise_username` (`username`),
  UNIQUE KEY `uk_enterprise_credit_code` (`credit_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='企业表';

-- ----------------------------
-- 企业认证审核表
-- ----------------------------
DROP TABLE IF EXISTS `enterprise_audit`;
CREATE TABLE `enterprise_audit` (
  `id`             bigint       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `enterprise_id`  bigint       NOT NULL COMMENT '企业ID',
  `license_no`     varchar(60)           DEFAULT NULL COMMENT '营业执照号',
  `license_img`    varchar(255)          DEFAULT NULL COMMENT '营业执照图片',
  `extra_img`      varchar(255)          DEFAULT NULL COMMENT '其他资质材料',
  `audit_status`   tinyint      NOT NULL DEFAULT 1 COMMENT '审核状态：1待审核2通过3驳回',
  `audit_remark`   varchar(255)          DEFAULT NULL COMMENT '审核意见',
  `auditor_id`     bigint                DEFAULT NULL COMMENT '审核人ID',
  `audit_time`     datetime              DEFAULT NULL COMMENT '审核时间',
  `create_time`    datetime              DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`    datetime              DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`        tinyint      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_audit_enterprise` (`enterprise_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='企业认证审核表';

-- ============================================================================
-- 3. 字典 / 分类
-- ============================================================================

-- ----------------------------
-- 岗位类别表
-- ----------------------------
DROP TABLE IF EXISTS `job_category`;
CREATE TABLE `job_category` (
  `id`          bigint      NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name`        varchar(60) NOT NULL COMMENT '类别名称',
  `parent_id`   bigint               DEFAULT 0 COMMENT '父级ID',
  `sort`        int                  DEFAULT 0 COMMENT '排序',
  `create_time` datetime             DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime             DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`     tinyint     NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='岗位类别表';

-- ----------------------------
-- 通用数据字典表（行业/城市/学历/专业等）
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict`;
CREATE TABLE `sys_dict` (
  `id`          bigint      NOT NULL AUTO_INCREMENT COMMENT '主键',
  `dict_type`   varchar(40) NOT NULL COMMENT '字典类型：industry/city/education/major/welfare',
  `dict_label`  varchar(80) NOT NULL COMMENT '字典标签',
  `dict_value`  varchar(80)          DEFAULT NULL COMMENT '字典值',
  `sort`        int                  DEFAULT 0 COMMENT '排序',
  `create_time` datetime             DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime             DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`     tinyint     NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_dict_type` (`dict_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据字典表';

-- ============================================================================
-- 4. 职位 / 简历
-- ============================================================================

-- ----------------------------
-- 职位表
-- ----------------------------
DROP TABLE IF EXISTS `job_post`;
CREATE TABLE `job_post` (
  `id`             bigint       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `enterprise_id`  bigint       NOT NULL COMMENT '企业ID',
  `category_id`    bigint                DEFAULT NULL COMMENT '岗位类别ID',
  `title`          varchar(120) NOT NULL COMMENT '岗位名称',
  `job_type`       tinyint               DEFAULT 1 COMMENT '类型：1全职2实习',
  `recruit_num`    int                   DEFAULT 1 COMMENT '招聘人数',
  `city`           varchar(60)           DEFAULT NULL COMMENT '工作城市',
  `salary_min`     int                   DEFAULT 0 COMMENT '最低薪资(K)',
  `salary_max`     int                   DEFAULT 0 COMMENT '最高薪资(K)',
  `education`      varchar(20)           DEFAULT NULL COMMENT '学历要求',
  `major_require`  varchar(120)          DEFAULT NULL COMMENT '专业要求',
  `experience`     varchar(40)           DEFAULT NULL COMMENT '经验要求',
  `duty`           text                  COMMENT '岗位职责',
  `requirement`    text                  COMMENT '任职要求',
  `welfare`        varchar(255)          DEFAULT NULL COMMENT '福利标签',
  `audit_status`   tinyint      NOT NULL DEFAULT 0 COMMENT '审核状态：0待审核1通过2驳回',
  `audit_remark`   varchar(255)          DEFAULT NULL COMMENT '审核意见',
  `status`         tinyint      NOT NULL DEFAULT 1 COMMENT '状态：1招聘中0已下架',
  `view_count`     int                   DEFAULT 0 COMMENT '浏览量',
  `apply_count`    int                   DEFAULT 0 COMMENT '投递量',
  `publish_time`   datetime              DEFAULT NULL COMMENT '发布时间',
  `create_time`    datetime              DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`    datetime              DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`        tinyint      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_job_enterprise` (`enterprise_id`),
  KEY `idx_job_category` (`category_id`),
  KEY `idx_job_city` (`city`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='职位表';

-- ----------------------------
-- 在线简历主表
-- ----------------------------
DROP TABLE IF EXISTS `resume`;
CREATE TABLE `resume` (
  `id`            bigint       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `student_id`    bigint       NOT NULL COMMENT '学生ID',
  `name`          varchar(50)           DEFAULT NULL COMMENT '姓名',
  `gender`        tinyint               DEFAULT 0 COMMENT '性别',
  `birth`         varchar(20)           DEFAULT NULL COMMENT '出生年月',
  `phone`         varchar(20)           DEFAULT NULL COMMENT '手机号',
  `email`         varchar(80)           DEFAULT NULL COMMENT '邮箱',
  `college`       varchar(80)           DEFAULT NULL COMMENT '学院',
  `major`         varchar(80)           DEFAULT NULL COMMENT '专业',
  `education`     varchar(20)           DEFAULT NULL COMMENT '学历',
  `skill_cert`    text                  COMMENT '技能证书',
  `award`         text                  COMMENT '获奖经历',
  `self_eval`     text                  COMMENT '自我评价',
  `complete_rate` int                   DEFAULT 0 COMMENT '完整度百分比',
  `is_public`     tinyint      NOT NULL DEFAULT 1 COMMENT '是否公开：1是0否',
  `create_time`   datetime              DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`   datetime              DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`       tinyint      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_resume_student` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='在线简历主表';

-- ----------------------------
-- 教育经历表
-- ----------------------------
DROP TABLE IF EXISTS `resume_education`;
CREATE TABLE `resume_education` (
  `id`          bigint      NOT NULL AUTO_INCREMENT COMMENT '主键',
  `resume_id`   bigint      NOT NULL COMMENT '简历ID',
  `school`      varchar(80)          DEFAULT NULL COMMENT '学校',
  `major`       varchar(80)          DEFAULT NULL COMMENT '专业',
  `degree`      varchar(20)          DEFAULT NULL COMMENT '学历',
  `start_date`  varchar(20)          DEFAULT NULL COMMENT '开始时间',
  `end_date`    varchar(20)          DEFAULT NULL COMMENT '结束时间',
  `description` varchar(500)         DEFAULT NULL COMMENT '描述',
  `create_time` datetime             DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime             DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`     tinyint     NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_edu_resume` (`resume_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='简历教育经历表';

-- ----------------------------
-- 项目经历表
-- ----------------------------
DROP TABLE IF EXISTS `resume_project`;
CREATE TABLE `resume_project` (
  `id`           bigint      NOT NULL AUTO_INCREMENT COMMENT '主键',
  `resume_id`    bigint      NOT NULL COMMENT '简历ID',
  `project_name` varchar(120)         DEFAULT NULL COMMENT '项目名称',
  `role`         varchar(60)          DEFAULT NULL COMMENT '担任角色',
  `start_date`   varchar(20)          DEFAULT NULL COMMENT '开始时间',
  `end_date`     varchar(20)          DEFAULT NULL COMMENT '结束时间',
  `description`  text                 COMMENT '项目描述',
  `create_time`  datetime             DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`  datetime             DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`      tinyint     NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_proj_resume` (`resume_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='简历项目经历表';

-- ----------------------------
-- 实习/工作经历表
-- ----------------------------
DROP TABLE IF EXISTS `resume_experience`;
CREATE TABLE `resume_experience` (
  `id`           bigint      NOT NULL AUTO_INCREMENT COMMENT '主键',
  `resume_id`    bigint      NOT NULL COMMENT '简历ID',
  `company`      varchar(120)         DEFAULT NULL COMMENT '公司名称',
  `position`     varchar(60)          DEFAULT NULL COMMENT '职位',
  `start_date`   varchar(20)          DEFAULT NULL COMMENT '开始时间',
  `end_date`     varchar(20)          DEFAULT NULL COMMENT '结束时间',
  `description`  text                 COMMENT '工作内容',
  `create_time`  datetime             DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`  datetime             DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`      tinyint     NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_exp_resume` (`resume_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='简历实习工作经历表';

-- ----------------------------
-- 附件简历表
-- ----------------------------
DROP TABLE IF EXISTS `resume_attachment`;
CREATE TABLE `resume_attachment` (
  `id`          bigint       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `student_id`  bigint       NOT NULL COMMENT '学生ID',
  `file_name`   varchar(200)          DEFAULT NULL COMMENT '文件名',
  `file_url`    varchar(255)          DEFAULT NULL COMMENT '文件地址',
  `file_size`   bigint                DEFAULT 0 COMMENT '文件大小(字节)',
  `file_type`   varchar(40)           DEFAULT NULL COMMENT '文件类型',
  `create_time` datetime              DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime              DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`     tinyint      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_attach_student` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='附件简历表';

-- ============================================================================
-- 5. 投递 / 面试 / Offer / 收藏 / 人才库
-- ============================================================================

-- ----------------------------
-- 投递记录表
-- ----------------------------
DROP TABLE IF EXISTS `job_apply`;
CREATE TABLE `job_apply` (
  `id`            bigint   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `student_id`    bigint   NOT NULL COMMENT '学生ID',
  `resume_id`     bigint            DEFAULT NULL COMMENT '简历ID',
  `job_id`        bigint   NOT NULL COMMENT '职位ID',
  `enterprise_id` bigint   NOT NULL COMMENT '企业ID',
  `status`        tinyint  NOT NULL DEFAULT 0 COMMENT '状态：0待查看1已查看2邀请面试3笔试4已录用5不合适',
  `apply_remark`  varchar(255)      DEFAULT NULL COMMENT '投递备注',
  `hr_remark`     varchar(255)      DEFAULT NULL COMMENT 'HR备注',
  `create_time`   datetime          DEFAULT CURRENT_TIMESTAMP COMMENT '投递时间',
  `update_time`   datetime          DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`       tinyint  NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_apply_student` (`student_id`),
  KEY `idx_apply_job` (`job_id`),
  KEY `idx_apply_enterprise` (`enterprise_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='投递记录表';

-- ----------------------------
-- 面试通知表
-- ----------------------------
DROP TABLE IF EXISTS `interview_notice`;
CREATE TABLE `interview_notice` (
  `id`             bigint   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `apply_id`       bigint   NOT NULL COMMENT '投递记录ID',
  `student_id`     bigint   NOT NULL COMMENT '学生ID',
  `enterprise_id`  bigint   NOT NULL COMMENT '企业ID',
  `job_id`         bigint            DEFAULT NULL COMMENT '职位ID',
  `interview_time` datetime          DEFAULT NULL COMMENT '面试时间',
  `interview_type` tinyint           DEFAULT 1 COMMENT '方式：1现场2线上',
  `location`       varchar(200)      DEFAULT NULL COMMENT '地点/线上链接',
  `contact`        varchar(80)       DEFAULT NULL COMMENT '联系人/电话',
  `remark`         varchar(255)      DEFAULT NULL COMMENT '面试备注',
  `student_status` tinyint  NOT NULL DEFAULT 0 COMMENT '学生确认：0待确认1已确认2已拒绝',
  `create_time`    datetime          DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`    datetime          DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`        tinyint  NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_notice_student` (`student_id`),
  KEY `idx_notice_enterprise` (`enterprise_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='面试通知表';

-- ----------------------------
-- 面试评价表
-- ----------------------------
DROP TABLE IF EXISTS `interview_feedback`;
CREATE TABLE `interview_feedback` (
  `id`           bigint   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `notice_id`    bigint   NOT NULL COMMENT '面试通知ID',
  `apply_id`     bigint            DEFAULT NULL COMMENT '投递记录ID',
  `enterprise_id` bigint           DEFAULT NULL COMMENT '企业ID',
  `score`        int               DEFAULT 0 COMMENT '评分(0-100)',
  `content`      varchar(500)      DEFAULT NULL COMMENT '评价内容',
  `is_pass`      tinyint  NOT NULL DEFAULT 0 COMMENT '是否通过：0否1是',
  `interviewer`  varchar(50)       DEFAULT NULL COMMENT '面试官',
  `create_time`  datetime          DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`  datetime          DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`      tinyint  NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_feedback_notice` (`notice_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='面试评价表';

-- ----------------------------
-- Offer 记录表
-- ----------------------------
DROP TABLE IF EXISTS `offer_record`;
CREATE TABLE `offer_record` (
  `id`             bigint   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `apply_id`       bigint            DEFAULT NULL COMMENT '投递记录ID',
  `student_id`     bigint   NOT NULL COMMENT '学生ID',
  `enterprise_id`  bigint   NOT NULL COMMENT '企业ID',
  `job_id`         bigint            DEFAULT NULL COMMENT '职位ID',
  `position`       varchar(120)      DEFAULT NULL COMMENT '岗位名称',
  `salary`         varchar(60)       DEFAULT NULL COMMENT '薪资',
  `work_city`      varchar(60)       DEFAULT NULL COMMENT '工作城市',
  `report_time`    varchar(40)       DEFAULT NULL COMMENT '报到时间',
  `content`        varchar(500)      DEFAULT NULL COMMENT 'Offer内容',
  `offer_status`   tinyint  NOT NULL DEFAULT 0 COMMENT '状态：0待确认1已接受2已拒绝3已撤回',
  `create_time`    datetime          DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`    datetime          DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`        tinyint  NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_offer_student` (`student_id`),
  KEY `idx_offer_enterprise` (`enterprise_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Offer记录表';

-- ----------------------------
-- 职位收藏表
-- ----------------------------
DROP TABLE IF EXISTS `favorite_job`;
CREATE TABLE `favorite_job` (
  `id`          bigint   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `student_id`  bigint   NOT NULL COMMENT '学生ID',
  `job_id`      bigint   NOT NULL COMMENT '职位ID',
  `create_time` datetime          DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  `update_time` datetime          DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`     tinyint  NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_fav_student` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='职位收藏表';

-- ----------------------------
-- 人才库表
-- ----------------------------
DROP TABLE IF EXISTS `talent_pool`;
CREATE TABLE `talent_pool` (
  `id`            bigint   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `enterprise_id` bigint   NOT NULL COMMENT '企业ID',
  `student_id`    bigint   NOT NULL COMMENT '学生ID',
  `resume_id`     bigint            DEFAULT NULL COMMENT '简历ID',
  `tag`           varchar(120)      DEFAULT NULL COMMENT '标签',
  `remark`        varchar(255)      DEFAULT NULL COMMENT '备注',
  `create_time`   datetime          DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  `update_time`   datetime          DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`       tinyint  NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_talent_enterprise` (`enterprise_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='人才库表';

-- ============================================================================
-- 6. 校园活动 / 资讯 / 论坛 / 反馈 / 通知 / 日志
-- ============================================================================

-- ----------------------------
-- 校园宣讲会表
-- ----------------------------
DROP TABLE IF EXISTS `campus_talk`;
CREATE TABLE `campus_talk` (
  `id`            bigint       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title`         varchar(150) NOT NULL COMMENT '标题',
  `enterprise_id` bigint                DEFAULT NULL COMMENT '企业ID',
  `company_name`  varchar(120)          DEFAULT NULL COMMENT '企业名称',
  `talk_time`     datetime              DEFAULT NULL COMMENT '宣讲时间',
  `location`      varchar(200)          DEFAULT NULL COMMENT '地点',
  `content`       text                  COMMENT '宣讲内容',
  `cover`         varchar(255)          DEFAULT NULL COMMENT '封面图',
  `sign_count`    int                   DEFAULT 0 COMMENT '报名人数',
  `status`        tinyint      NOT NULL DEFAULT 1 COMMENT '状态：1正常0关闭',
  `create_time`   datetime              DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`   datetime              DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`       tinyint      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='校园宣讲会表';

-- ----------------------------
-- 招聘会表
-- ----------------------------
DROP TABLE IF EXISTS `job_fair`;
CREATE TABLE `job_fair` (
  `id`            bigint       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title`         varchar(150) NOT NULL COMMENT '招聘会名称',
  `fair_time`     datetime              DEFAULT NULL COMMENT '举办时间',
  `location`      varchar(200)          DEFAULT NULL COMMENT '地点',
  `host`          varchar(120)          DEFAULT NULL COMMENT '主办方',
  `content`       text                  COMMENT '介绍',
  `cover`         varchar(255)          DEFAULT NULL COMMENT '封面图',
  `company_count` int                   DEFAULT 0 COMMENT '参会企业数',
  `job_count`     int                   DEFAULT 0 COMMENT '岗位数',
  `sign_count`    int                   DEFAULT 0 COMMENT '报名人数',
  `status`        tinyint      NOT NULL DEFAULT 1 COMMENT '状态：1正常0关闭',
  `create_time`   datetime              DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`   datetime              DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`       tinyint      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='招聘会表';

-- ----------------------------
-- 活动报名表（宣讲会/招聘会通用）
-- ----------------------------
DROP TABLE IF EXISTS `activity_sign`;
CREATE TABLE `activity_sign` (
  `id`            bigint   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `activity_type` tinyint  NOT NULL DEFAULT 1 COMMENT '类型：1宣讲会2招聘会',
  `activity_id`   bigint   NOT NULL COMMENT '活动ID',
  `student_id`    bigint   NOT NULL COMMENT '学生ID',
  `sign_status`   tinyint  NOT NULL DEFAULT 1 COMMENT '状态：1已报名2已签到3已取消',
  `create_time`   datetime          DEFAULT CURRENT_TIMESTAMP COMMENT '报名时间',
  `update_time`   datetime          DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`       tinyint  NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_sign_activity` (`activity_type`,`activity_id`),
  KEY `idx_sign_student` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动报名表';

-- ----------------------------
-- 资讯分类表
-- ----------------------------
DROP TABLE IF EXISTS `news_category`;
CREATE TABLE `news_category` (
  `id`          bigint      NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name`        varchar(60) NOT NULL COMMENT '分类名称',
  `sort`        int                  DEFAULT 0 COMMENT '排序',
  `create_time` datetime             DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime             DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`     tinyint     NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='资讯分类表';

-- ----------------------------
-- 公告资讯表
-- ----------------------------
DROP TABLE IF EXISTS `announcement`;
CREATE TABLE `announcement` (
  `id`           bigint       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `category_id`  bigint                DEFAULT NULL COMMENT '分类ID',
  `title`        varchar(150) NOT NULL COMMENT '标题',
  `cover`        varchar(255)          DEFAULT NULL COMMENT '封面图',
  `summary`      varchar(255)          DEFAULT NULL COMMENT '摘要',
  `content`      longtext              COMMENT '正文',
  `author`       varchar(50)           DEFAULT NULL COMMENT '作者',
  `view_count`   int                   DEFAULT 0 COMMENT '阅读量',
  `is_top`       tinyint      NOT NULL DEFAULT 0 COMMENT '是否置顶',
  `status`       tinyint      NOT NULL DEFAULT 1 COMMENT '状态：1发布0草稿',
  `publish_time` datetime              DEFAULT NULL COMMENT '发布时间',
  `create_time`  datetime              DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`  datetime              DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`      tinyint      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_ann_category` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='公告资讯表';

-- ----------------------------
-- 轮播图表
-- ----------------------------
DROP TABLE IF EXISTS `banner`;
CREATE TABLE `banner` (
  `id`          bigint       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title`       varchar(120)          DEFAULT NULL COMMENT '标题',
  `image_url`   varchar(255) NOT NULL COMMENT '图片地址',
  `link_url`    varchar(255)          DEFAULT NULL COMMENT '跳转链接',
  `sort`        int                   DEFAULT 0 COMMENT '排序',
  `status`      tinyint      NOT NULL DEFAULT 1 COMMENT '状态：1显示0隐藏',
  `create_time` datetime              DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime              DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`     tinyint      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='轮播图表';

-- ----------------------------
-- 论坛帖子表
-- ----------------------------
DROP TABLE IF EXISTS `forum_post`;
CREATE TABLE `forum_post` (
  `id`            bigint       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `student_id`    bigint                DEFAULT NULL COMMENT '发帖学生ID',
  `author_name`   varchar(50)           DEFAULT NULL COMMENT '作者昵称',
  `title`         varchar(150) NOT NULL COMMENT '标题',
  `content`       text                  COMMENT '内容',
  `category`      varchar(40)           DEFAULT NULL COMMENT '版块：求职交流/经验分享/offer捷报',
  `view_count`    int                   DEFAULT 0 COMMENT '浏览数',
  `like_count`    int                   DEFAULT 0 COMMENT '点赞数',
  `comment_count` int                   DEFAULT 0 COMMENT '评论数',
  `audit_status`  tinyint      NOT NULL DEFAULT 1 COMMENT '审核状态：0待审核1通过2驳回',
  `status`        tinyint      NOT NULL DEFAULT 1 COMMENT '状态：1正常0隐藏',
  `create_time`   datetime              DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`   datetime              DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`       tinyint      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_post_student` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='论坛帖子表';

-- ----------------------------
-- 论坛评论表
-- ----------------------------
DROP TABLE IF EXISTS `forum_comment`;
CREATE TABLE `forum_comment` (
  `id`          bigint   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `post_id`     bigint   NOT NULL COMMENT '帖子ID',
  `student_id`  bigint            DEFAULT NULL COMMENT '评论学生ID',
  `author_name` varchar(50)       DEFAULT NULL COMMENT '昵称',
  `content`     varchar(500)      DEFAULT NULL COMMENT '评论内容',
  `like_count`  int               DEFAULT 0 COMMENT '点赞数',
  `status`      tinyint  NOT NULL DEFAULT 1 COMMENT '状态：1正常0删除',
  `create_time` datetime          DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime          DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`     tinyint  NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_comment_post` (`post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='论坛评论表';

-- ----------------------------
-- 留言反馈表
-- ----------------------------
DROP TABLE IF EXISTS `message_feedback`;
CREATE TABLE `message_feedback` (
  `id`           bigint   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id`      bigint            DEFAULT NULL COMMENT '用户ID',
  `user_type`    varchar(20)       DEFAULT NULL COMMENT '用户类型：STUDENT/ENTERPRISE',
  `user_name`    varchar(50)       DEFAULT NULL COMMENT '用户名称',
  `content`      varchar(500) NOT NULL COMMENT '留言内容',
  `contact`      varchar(80)       DEFAULT NULL COMMENT '联系方式',
  `reply`        varchar(500)      DEFAULT NULL COMMENT '回复内容',
  `reply_time`   datetime          DEFAULT NULL COMMENT '回复时间',
  `status`       tinyint  NOT NULL DEFAULT 0 COMMENT '状态：0待处理1已回复',
  `create_time`  datetime          DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`  datetime          DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`      tinyint  NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='留言反馈表';

-- ----------------------------
-- 系统消息/通知表
-- ----------------------------
DROP TABLE IF EXISTS `system_notice`;
CREATE TABLE `system_notice` (
  `id`           bigint   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `receiver_id`  bigint            DEFAULT NULL COMMENT '接收者ID',
  `receiver_type` varchar(20)      DEFAULT NULL COMMENT '接收者类型：STUDENT/ENTERPRISE/ADMIN',
  `title`        varchar(150)      DEFAULT NULL COMMENT '标题',
  `content`      varchar(500)      DEFAULT NULL COMMENT '内容',
  `notice_type`  varchar(40)       DEFAULT 'SYSTEM' COMMENT '类型：SYSTEM/APPLY/INTERVIEW/OFFER/AUDIT',
  `is_read`      tinyint  NOT NULL DEFAULT 0 COMMENT '是否已读：0否1是',
  `create_time`  datetime          DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time`  datetime          DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`      tinyint  NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_notice_receiver` (`receiver_type`,`receiver_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统消息通知表';

-- ----------------------------
-- 操作/登录/异常日志表
-- ----------------------------
DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log` (
  `id`          bigint   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id`     bigint            DEFAULT NULL COMMENT '用户ID',
  `user_type`   varchar(20)       DEFAULT NULL COMMENT '用户类型',
  `user_name`   varchar(50)       DEFAULT NULL COMMENT '用户名',
  `log_type`    varchar(20)       DEFAULT 'OPERATION' COMMENT '日志类型：LOGIN/OPERATION/ERROR',
  `module`      varchar(50)       DEFAULT NULL COMMENT '模块',
  `operation`   varchar(120)      DEFAULT NULL COMMENT '操作描述',
  `method`      varchar(200)      DEFAULT NULL COMMENT '请求方法',
  `params`      text              COMMENT '请求参数',
  `ip`          varchar(50)       DEFAULT NULL COMMENT 'IP地址',
  `status`      tinyint  NOT NULL DEFAULT 1 COMMENT '状态：1成功0失败',
  `error_msg`   text              COMMENT '异常信息',
  `cost_time`   bigint            DEFAULT 0 COMMENT '耗时(ms)',
  `create_time` datetime          DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `deleted`     tinyint  NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_log_type` (`log_type`),
  KEY `idx_log_user` (`user_type`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统日志表';

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- 7. 初始化数据
-- ============================================================================

-- 角色
INSERT INTO `role` (`id`,`role_code`,`role_name`,`description`) VALUES
(1,'ADMIN','系统管理员','就业办/系统管理员，拥有全部权限'),
(2,'ENTERPRISE','企业HR','企业招聘方'),
(3,'STUDENT','学生','求职者');

-- 管理员账号（密码均为 123456 的 BCrypt 串）
-- BCrypt: $2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO
INSERT INTO `admin_user` (`id`,`username`,`password`,`real_name`,`phone`,`email`,`role_id`,`status`) VALUES
(1,'admin','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','超级管理员','13800000000','admin@campus.com',1,1),
(2,'jiuyeban','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','就业办老师','13800000001','jyb@campus.com',1,1);

-- 学生账号（密码 123456）
INSERT INTO `student` (`id`,`username`,`password`,`real_name`,`student_no`,`gender`,`college`,`major`,`grade`,`education`,`phone`,`email`,`status`) VALUES
(1,'student','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','张三','2021001001',1,'计算机学院','计算机科学与技术','2021级','本科','13900000001','zhangsan@stu.com',1),
(2,'lisi','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','李四','2021001002',2,'计算机学院','软件工程','2021级','本科','13900000002','lisi@stu.com',1),
(3,'wangwu','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','王五','2021002001',1,'经济管理学院','市场营销','2021级','本科','13900000003','wangwu@stu.com',1);

-- 企业账号（密码 123456）
INSERT INTO `enterprise` (`id`,`username`,`password`,`company_name`,`credit_code`,`industry`,`scale`,`nature`,`address`,`city`,`intro`,`welfare`,`contact_name`,`contact_phone`,`email`,`audit_status`,`status`) VALUES
(1,'company','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','字节跳动科技有限公司','911100001234567890','互联网','1000人以上','民营企业','北京市海淀区','北京','字节跳动是一家全球化的科技公司，旗下产品包括抖音、今日头条等。','五险一金,年终奖,带薪年假,免费三餐','HR王经理','010-88888888','hr@bytedance.com',2,1),
(2,'tencent','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','腾讯科技有限公司','914403001234567891','互联网','1000人以上','民营企业','深圳市南山区','深圳','腾讯是领先的互联网增值服务提供商之一。','五险一金,股票期权,弹性工作,免费班车','李HR','0755-86013388','hr@tencent.com',2,1),
(3,'newcorp','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','创新未来信息技术有限公司','913100001234567892','计算机软件','100-499人','民营企业','上海市浦东新区','上海','专注于企业数字化转型的创新型科技公司。','五险一金,绩效奖金,节日福利','张总监','021-66668888','hr@newcorp.com',1,1);

-- 岗位类别
INSERT INTO `job_category` (`id`,`name`,`parent_id`,`sort`) VALUES
(1,'技术开发',0,1),(2,'产品运营',0,2),(3,'市场营销',0,3),(4,'职能管理',0,4),(5,'设计创意',0,5),
(6,'Java开发',1,1),(7,'前端开发',1,2),(8,'测试工程师',1,3),(9,'算法工程师',1,4),
(10,'产品经理',2,1),(11,'运营专员',2,2),(12,'市场专员',3,1),(13,'人力资源',4,1),(14,'UI设计师',5,1);

-- 数据字典：行业
INSERT INTO `sys_dict` (`dict_type`,`dict_label`,`dict_value`,`sort`) VALUES
('industry','互联网','互联网',1),('industry','计算机软件','计算机软件',2),('industry','电子商务','电子商务',3),
('industry','金融','金融',4),('industry','教育培训','教育培训',5),('industry','制造业','制造业',6),
-- 城市
('city','北京','北京',1),('city','上海','上海',2),('city','广州','广州',3),('city','深圳','深圳',4),
('city','杭州','杭州',5),('city','成都','成都',6),('city','武汉','武汉',7),('city','南京','南京',8),
-- 学历
('education','大专','大专',1),('education','本科','本科',2),('education','硕士','硕士',3),('education','博士','博士',4),
-- 专业
('major','计算机科学与技术','计算机科学与技术',1),('major','软件工程','软件工程',2),('major','人工智能','人工智能',3),
('major','市场营销','市场营销',4),('major','工商管理','工商管理',5),('major','电子信息工程','电子信息工程',6),
-- 福利标签
('welfare','五险一金','五险一金',1),('welfare','年终奖','年终奖',2),('welfare','带薪年假','带薪年假',3),
('welfare','弹性工作','弹性工作',4),('welfare','免费三餐','免费三餐',5),('welfare','股票期权','股票期权',6);

-- 资讯分类
INSERT INTO `news_category` (`id`,`name`,`sort`) VALUES
(1,'就业政策',1),(2,'招聘公告',2),(3,'求职技巧',3),(4,'校园新闻',4);

-- 职位
INSERT INTO `job_post` (`id`,`enterprise_id`,`category_id`,`title`,`job_type`,`recruit_num`,`city`,`salary_min`,`salary_max`,`education`,`major_require`,`experience`,`duty`,`requirement`,`welfare`,`audit_status`,`status`,`view_count`,`apply_count`,`publish_time`) VALUES
(1,1,6,'Java开发工程师',1,5,'北京',10,16,'本科','计算机相关','应届',
 '1、负责后端服务的设计与开发；\n2、参与系统架构设计；\n3、编写高质量代码并保证系统稳定性。',
 '1、本科及以上学历，计算机相关专业；\n2、熟悉Java、Spring Boot；\n3、熟悉MySQL、Redis；\n4、有良好的团队协作能力。',
 '五险一金,年终奖,免费三餐,带薪年假',1,1,128,3,'2026-03-01 09:00:00'),
(2,1,7,'前端开发工程师',1,3,'北京',9,15,'本科','计算机相关','应届',
 '1、负责Web前端开发；\n2、与后端协作完成产品功能；\n3、优化前端性能。',
 '1、熟悉HTML/CSS/JavaScript；\n2、熟悉Vue或React框架；\n3、有良好的审美和代码规范。',
 '五险一金,弹性工作,股票期权',1,1,96,2,'2026-03-02 09:00:00'),
(3,2,6,'后端开发工程师',1,4,'深圳',10,17,'本科','计算机相关','应届',
 '1、负责微服务后端开发；\n2、参与高并发系统设计；\n3、保障服务质量。',
 '1、扎实的Java基础；\n2、熟悉分布式与微服务；\n3、熟悉常用中间件。',
 '五险一金,股票期权,弹性工作,免费班车',1,1,150,1,'2026-03-03 09:00:00'),
(4,2,10,'产品经理',1,2,'深圳',8,14,'本科','不限','应届',
 '1、负责产品需求分析与规划；\n2、撰写产品文档；\n3、跟进产品研发落地。',
 '1、有较强的逻辑思维；\n2、良好的沟通协调能力；\n3、对互联网产品有热情。',
 '五险一金,带薪年假,节日福利',1,1,88,1,'2026-03-04 09:00:00'),
(5,3,8,'软件测试工程师（实习）',2,3,'上海',3,5,'本科','计算机相关','在校生',
 '1、负责软件功能测试；\n2、编写测试用例；\n3、提交并跟踪缺陷。',
 '1、了解软件测试流程；\n2、细心负责；\n3、每周到岗4天以上。',
 '五险一金,绩效奖金',0,1,42,0,'2026-03-05 09:00:00');

-- 简历
INSERT INTO `resume` (`id`,`student_id`,`name`,`gender`,`birth`,`phone`,`email`,`college`,`major`,`education`,`skill_cert`,`award`,`self_eval`,`complete_rate`,`is_public`) VALUES
(1,1,'张三',1,'2003-05','13900000001','zhangsan@stu.com','计算机学院','计算机科学与技术','本科',
 '全国计算机等级考试二级、CET-6、软件设计师','校级一等奖学金、ACM程序设计大赛省赛三等奖',
 '本人性格开朗，热爱编程，掌握扎实的Java后端开发技能，具备良好的学习能力和团队协作精神。',85,1),
(2,2,'李四',2,'2003-08','13900000002','lisi@stu.com','计算机学院','软件工程','本科',
 'CET-4、前端开发实训证书','校级三好学生','熟悉前端开发，喜欢钻研新技术，有较强的责任心。',70,1);

-- 教育经历
INSERT INTO `resume_education` (`resume_id`,`school`,`major`,`degree`,`start_date`,`end_date`,`description`) VALUES
(1,'某某大学','计算机科学与技术','本科','2021-09','2025-06','主修数据结构、操作系统、计算机网络、数据库等课程，成绩优异。'),
(2,'某某大学','软件工程','本科','2021-09','2025-06','主修软件工程、Web开发、面向对象程序设计等课程。');

-- 项目经历
INSERT INTO `resume_project` (`resume_id`,`project_name`,`role`,`start_date`,`end_date`,`description`) VALUES
(1,'校园二手交易平台','后端负责人','2024-03','2024-06','基于Spring Boot开发后端接口，实现商品发布、交易、评价等功能。'),
(1,'在线考试系统','全栈开发','2023-09','2023-12','独立完成前后端开发，支持组卷、答题、自动判分。');

-- 实习经历
INSERT INTO `resume_experience` (`resume_id`,`company`,`position`,`start_date`,`end_date`,`description`) VALUES
(1,'某科技公司','后端开发实习生','2024-07','2024-09','参与企业内部管理系统的后端开发，负责部分模块的接口编写与测试。');

-- 投递记录
INSERT INTO `job_apply` (`id`,`student_id`,`resume_id`,`job_id`,`enterprise_id`,`status`,`apply_remark`) VALUES
(1,1,1,1,1,2,'希望加入贵公司Java团队'),
(2,1,1,3,2,1,NULL),
(3,2,2,2,1,0,NULL);

-- 面试通知
INSERT INTO `interview_notice` (`id`,`apply_id`,`student_id`,`enterprise_id`,`job_id`,`interview_time`,`interview_type`,`location`,`contact`,`remark`,`student_status`) VALUES
(1,1,1,1,1,'2026-03-20 14:00:00',1,'北京市海淀区字节跳动总部B座3层','王经理 010-88888888','请携带简历及身份证，提前10分钟到场',1);

-- Offer 演示
INSERT INTO `offer_record` (`id`,`apply_id`,`student_id`,`enterprise_id`,`job_id`,`position`,`salary`,`work_city`,`report_time`,`content`,`offer_status`) VALUES
(1,1,1,1,1,'Java开发工程师','14K','北京','2026-07-01','恭喜您通过我司面试，期待您的加入！',0);

-- 职位收藏
INSERT INTO `favorite_job` (`student_id`,`job_id`) VALUES (1,2),(1,4),(2,1);

-- 轮播图
INSERT INTO `banner` (`title`,`image_url`,`link_url`,`sort`,`status`) VALUES
('春季校园双选会岗位上线','/upload/image/seed/banner-campus-fair.jpg','/fairs',1,1),
('名企宣讲与校招直通','/upload/image/seed/banner-enterprise-talk.jpg','/talks',2,1),
('就业政策与求职指导','/upload/image/seed/banner-career-guidance.jpg','/news',3,1);

-- 公告资讯
INSERT INTO `announcement` (`id`,`category_id`,`title`,`summary`,`content`,`author`,`view_count`,`is_top`,`status`,`publish_time`) VALUES
(1,1,'关于2026届毕业生就业工作的通知','学校就业办发布2026届毕业生就业相关政策与安排。','<p>各位同学：</p><p>为做好2026届毕业生就业工作，现将有关事项通知如下……</p>','就业办',320,1,1,'2026-03-01 10:00:00'),
(2,3,'求职简历撰写技巧','一份优秀的简历是求职成功的第一步。','<p>简历应突出重点，量化成果，避免冗长……</p>','就业指导中心',256,0,1,'2026-03-02 10:00:00'),
(3,2,'多家名企春招岗位发布','字节跳动、腾讯等企业春招岗位现已开放。','<p>本周新增多家名企招聘岗位，欢迎同学们积极投递……</p>','就业办',198,0,1,'2026-03-03 10:00:00');

-- 宣讲会
INSERT INTO `campus_talk` (`id`,`title`,`enterprise_id`,`company_name`,`talk_time`,`location`,`content`,`sign_count`,`status`) VALUES
(1,'字节跳动校园宣讲会',1,'字节跳动科技有限公司','2026-03-25 19:00:00','大学生活动中心报告厅','介绍公司文化、招聘岗位及发展前景。',45,1),
(2,'腾讯春季校园宣讲',2,'腾讯科技有限公司','2026-03-28 19:00:00','信息楼一楼报告厅','腾讯各业务线岗位介绍与现场答疑。',38,1);

-- 招聘会
INSERT INTO `job_fair` (`id`,`title`,`fair_time`,`location`,`host`,`content`,`company_count`,`job_count`,`sign_count`,`status`) VALUES
(1,'2026春季大型校园双选会','2026-04-10 09:00:00','学校体育馆','校就业指导中心','汇聚百余家优质企业，提供数千个就业岗位。',120,3500,860,1),
(2,'IT行业专场招聘会','2026-04-15 09:00:00','计算机学院一楼大厅','计算机学院','面向计算机相关专业的专场招聘活动。',45,1200,420,1);

-- 论坛帖子
INSERT INTO `forum_post` (`id`,`student_id`,`author_name`,`title`,`content`,`category`,`view_count`,`like_count`,`comment_count`,`audit_status`,`status`) VALUES
(1,1,'张三','分享一下我的字节面试经验','今天去字节面试了，整体感觉还不错，面试官很专业……','经验分享',156,23,2,1,1),
(2,2,'李四','应届生该如何准备前端面试？','想请教各位学长学姐，前端面试一般会问哪些问题？','求职交流',98,12,1,1,1);

-- 论坛评论
INSERT INTO `forum_comment` (`post_id`,`student_id`,`author_name`,`content`,`like_count`,`status`) VALUES
(1,2,'李四','感谢分享，很有帮助！',5,1),
(1,3,'王五','请问算法题难吗？',2,1),
(2,1,'张三','建议多刷面经，重点准备项目经历。',3,1);

-- 留言反馈
INSERT INTO `message_feedback` (`user_id`,`user_type`,`user_name`,`content`,`contact`,`status`) VALUES
(1,'STUDENT','张三','希望能增加更多实习岗位信息。','zhangsan@stu.com',0),
(2,'STUDENT','李四','简历预览功能很好用，点赞！','lisi@stu.com',1);

-- 系统消息
INSERT INTO `system_notice` (`receiver_id`,`receiver_type`,`title`,`content`,`notice_type`,`is_read`) VALUES
(1,'STUDENT','面试邀请','字节跳动邀请您参加Java开发工程师面试，请及时确认。','INTERVIEW',0),
(1,'STUDENT','投递反馈','您投递的腾讯后端开发工程师简历已被查看。','APPLY',0),
(1,'ENTERPRISE','认证通过','贵公司的企业认证已通过审核。','AUDIT',1);

-- 操作日志示例
INSERT INTO `operation_log` (`user_id`,`user_type`,`user_name`,`log_type`,`module`,`operation`,`ip`,`status`,`cost_time`) VALUES
(1,'ADMIN','admin','LOGIN','登录','管理员登录系统','127.0.0.1',1,35),
(1,'STUDENT','student','LOGIN','登录','学生登录系统','127.0.0.1',1,28),
(1,'ADMIN','admin','OPERATION','企业管理','审核通过企业：字节跳动','127.0.0.1',1,52);

-- ============================================================================
-- 8. 扩展演示数据：覆盖更多状态、分页、审核、活动、人才库与日志
-- ============================================================================

-- 权限菜单与角色授权
INSERT INTO `permission` (`id`,`perm_code`,`perm_name`,`perm_type`,`parent_id`,`path`,`sort`) VALUES
(1,'admin:dashboard','数据统计','MENU',0,'/admin/dashboard',1),
(2,'admin:student','学生管理','MENU',0,'/admin/student',2),
(3,'admin:enterprise','企业管理','MENU',0,'/admin/enterprise',3),
(4,'admin:job','岗位审核','MENU',0,'/admin/job',4),
(5,'admin:category','岗位类别','MENU',0,'/admin/category',5),
(6,'admin:dict','字典管理','MENU',0,'/admin/dict',6),
(7,'admin:announcement','公告资讯','MENU',0,'/admin/announcement',7),
(8,'admin:banner','轮播图','MENU',0,'/admin/banner',8),
(9,'admin:talk','宣讲会','MENU',0,'/admin/talk',9),
(10,'admin:fair','招聘会','MENU',0,'/admin/fair',10),
(11,'admin:forum','论坛管理','MENU',0,'/admin/forum',11),
(12,'admin:feedback','留言反馈','MENU',0,'/admin/feedback',12),
(13,'admin:log','系统日志','MENU',0,'/admin/log',13),
(14,'enterprise:dashboard','企业数据看板','MENU',0,'/enterprise/dashboard',1),
(15,'enterprise:profile','企业资料','MENU',0,'/enterprise/profile',2),
(16,'enterprise:audit','企业认证','MENU',0,'/enterprise/audit',3),
(17,'enterprise:job','职位管理','MENU',0,'/enterprise/job',4),
(18,'enterprise:apply','简历筛选','MENU',0,'/enterprise/apply',5),
(19,'enterprise:interview','面试管理','MENU',0,'/enterprise/interview',6),
(20,'enterprise:offer','Offer管理','MENU',0,'/enterprise/offer',7),
(21,'enterprise:talent','人才库','MENU',0,'/enterprise/talent',8),
(22,'student:dashboard','学生个人中心','MENU',0,'/student/dashboard',1),
(23,'student:profile','个人信息','MENU',0,'/student/profile',2),
(24,'student:intention','求职意向','MENU',0,'/student/intention',3),
(25,'student:resume','在线简历','MENU',0,'/student/resume',4),
(26,'student:attachment','附件简历','MENU',0,'/student/attachment',5),
(27,'student:apply','投递记录','MENU',0,'/student/apply',6),
(28,'student:interview','面试通知','MENU',0,'/student/interview',7),
(29,'student:offer','Offer管理','MENU',0,'/student/offer',8),
(30,'student:favorite','我的收藏','MENU',0,'/student/favorite',9),
(31,'student:notice','消息中心','MENU',0,'/student/notice',10),
(32,'student:forum','我的帖子','MENU',0,'/student/myposts',11);

INSERT INTO `role_permission` (`role_id`,`permission_id`) VALUES
(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9),(1,10),(1,11),(1,12),(1,13),
(2,14),(2,15),(2,16),(2,17),(2,18),(2,19),(2,20),(2,21),
(3,22),(3,23),(3,24),(3,25),(3,26),(3,27),(3,28),(3,29),(3,30),(3,31),(3,32);

-- 更多账号
INSERT INTO `admin_user` (`id`,`username`,`password`,`real_name`,`phone`,`email`,`role_id`,`status`) VALUES
(3,'auditor','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','审核专员','13800000002','auditor@campus.com',1,1),
(4,'disabled_admin','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','停用管理员','13800000003','disabled.admin@campus.com',1,0);

INSERT INTO `student` (`id`,`username`,`password`,`real_name`,`student_no`,`gender`,`college`,`major`,`grade`,`education`,`phone`,`email`,`intro`,`status`) VALUES
(4,'zhaoliu','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','赵六','2021003001',2,'人工智能学院','人工智能','2021级','本科','13900000004','zhaoliu@stu.com','关注机器学习、数据挖掘和算法工程。',1),
(5,'sunqi','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','孙七','2022001001',1,'电子信息学院','电子信息工程','2022级','本科','13900000005','sunqi@stu.com','有嵌入式和测试开发项目经验。',1),
(6,'zhouba','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','周八','2020004001',2,'经济管理学院','工商管理','2020级','本科','13900000006','zhouba@stu.com','希望从事产品运营与人力资源方向。',1),
(7,'wuyue','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','吴越','2021005001',1,'艺术设计学院','视觉传达设计','2021级','本科','13900000007','wuyue@stu.com','擅长UI设计、交互原型与视觉表达。',1),
(8,'qianjiu','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','钱九','2022006001',2,'计算机学院','软件工程','2022级','本科','13900000008','qianjiu@stu.com','准备寻找暑期实习岗位。',1),
(9,'disabled_stu','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','停用学生','2021009999',1,'计算机学院','计算机科学与技术','2021级','本科','13900000999','disabled.stu@stu.com','用于验证禁用账号。',0);

INSERT INTO `enterprise` (`id`,`username`,`password`,`company_name`,`credit_code`,`industry`,`scale`,`nature`,`address`,`city`,`intro`,`welfare`,`contact_name`,`contact_phone`,`email`,`website`,`audit_status`,`status`) VALUES
(4,'alibaba','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','阿里云计算有限公司','913301001234567894','互联网','1000人以上','民营企业','杭州市余杭区文一西路','杭州','阿里云提供云计算、大数据和人工智能服务。','五险一金,年终奖,弹性工作,股票期权','陈HR','0571-26888888','campus@aliyun.com','https://www.aliyun.com',2,1),
(5,'meituan','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','美团科技有限公司','911101051234567895','电子商务','1000人以上','民营企业','北京市朝阳区望京','北京','美团围绕本地生活服务持续创新，岗位覆盖研发、产品、运营和设计。','五险一金,绩效奖金,带薪年假,免费三餐','刘HR','010-55556666','hr@meituan.com','https://www.meituan.com',2,1),
(6,'eduonline','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','启航在线教育科技有限公司','915101001234567896','教育培训','100-499人','民营企业','成都市高新区天府大道','成都','专注高校在线课程、职业教育和就业能力提升。','五险一金,节日福利,带薪年假','何经理','028-66667777','hr@eduonline.com','https://www.eduonline.com',2,1),
(7,'fintech','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','海纳金融科技有限公司','913100001234567897','金融','500-999人','民营企业','上海市陆家嘴金融城','上海','提供智能风控、量化交易和企业金融科技解决方案。','五险一金,年终奖,绩效奖金','赵总监','021-88889999','hr@fintech.com','https://www.fintech.com',1,1),
(8,'greenmaker','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','绿动智能制造有限公司','914201001234567898','制造业','500-999人','民营企业','武汉市东湖高新区','武汉','聚焦智能制造、工业互联网和绿色能源设备。','五险一金,绩效奖金,节日福利','宋经理','027-77778888','hr@greenmaker.com','https://www.greenmaker.com',3,1),
(9,'oldcorp','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','停用演示企业有限公司','913201001234567899','计算机软件','20-99人','民营企业','南京市软件大道','南京','用于验证企业禁用状态。','五险一金','停用联系人','025-11112222','disabled@oldcorp.com','',2,0);

INSERT INTO `enterprise_audit` (`id`,`enterprise_id`,`license_no`,`license_img`,`extra_img`,`audit_status`,`audit_remark`,`auditor_id`,`audit_time`) VALUES
(1,1,'911100001234567890','/upload/audit/bytedance_license.png','/upload/audit/bytedance_extra.png',2,'营业执照与授权材料完整，认证通过',1,'2026-02-25 10:00:00'),
(2,2,'914403001234567891','/upload/audit/tencent_license.png','/upload/audit/tencent_extra.png',2,'企业信息完整，认证通过',1,'2026-02-26 10:30:00'),
(3,3,'913100001234567892','/upload/audit/newcorp_license.png','/upload/audit/newcorp_extra.png',1,'等待平台审核',NULL,NULL),
(4,4,'913301001234567894','/upload/audit/alibaba_license.png','/upload/audit/alibaba_extra.png',2,'云计算企业资质材料完整，认证通过',1,'2026-02-26 14:00:00'),
(5,5,'911101051234567895','/upload/audit/meituan_license.png','/upload/audit/meituan_extra.png',2,'营业执照与联系人授权材料完整，认证通过',1,'2026-02-26 15:10:00'),
(6,6,'915101001234567896','/upload/audit/eduonline_license.png','/upload/audit/eduonline_extra.png',2,'教育培训企业材料齐全，认证通过',1,'2026-02-26 16:20:00'),
(7,7,'913100001234567897','/upload/audit/fintech_license.png','/upload/audit/fintech_extra.png',1,'新提交认证，等待审核',NULL,NULL),
(8,8,'914201001234567898','/upload/audit/greenmaker_license.png','/upload/audit/greenmaker_extra.png',3,'授权材料信息与企业资料不一致，请重新上传',3,'2026-02-27 15:00:00'),
(9,9,'913201001234567899','/upload/audit/oldcorp_license.png','/upload/audit/oldcorp_extra.png',2,'历史认证材料完整，认证通过；账号当前为禁用演示状态',1,'2026-02-27 16:00:00');

-- 更多分类和字典
INSERT INTO `job_category` (`id`,`name`,`parent_id`,`sort`) VALUES
(15,'移动开发',1,5),(16,'数据分析',1,6),(17,'运维开发',1,7),(18,'安全工程',1,8),
(19,'运营增长',2,3),(20,'电商运营',2,4),(21,'销售顾问',3,2),(22,'财务管理',4,2),(23,'行政专员',4,3),
(24,'视觉设计',5,2),(25,'交互设计',5,3),(26,'数据产品',2,5);

INSERT INTO `sys_dict` (`dict_type`,`dict_label`,`dict_value`,`sort`) VALUES
('industry','人工智能','人工智能',7),('industry','新能源','新能源',8),('industry','游戏','游戏',9),
('city','西安','西安',9),('city','苏州','苏州',10),('city','重庆','重庆',11),('city','长沙','长沙',12),
('education','不限','不限',0),
('major','视觉传达设计','视觉传达设计',7),('major','工商管理','工商管理',8),('major','会计学','会计学',9),('major','网络空间安全','网络空间安全',10),
('welfare','绩效奖金','绩效奖金',7),('welfare','节日福利','节日福利',8),('welfare','免费班车','免费班车',9),('welfare','补充医疗','补充医疗',10);

-- 求职意向
INSERT INTO `job_intention` (`student_id`,`expect_post`,`expect_city`,`expect_salary`,`job_type`,`arrival_time`) VALUES
(1,'Java开发工程师','北京,杭州','10K-16K',1,'毕业后1个月内'),
(2,'前端开发工程师','北京,深圳','9K-15K',1,'随时到岗'),
(3,'市场运营专员','上海,广州','6K-10K',1,'2026-07'),
(4,'算法工程师','杭州,上海','16K-25K',1,'毕业后2个月内'),
(5,'测试开发工程师','北京,深圳','8K-14K',1,'2026-06'),
(6,'产品运营/HR','成都,武汉','5K-9K',1,'2026-07'),
(7,'UI/交互设计师','北京,杭州','8K-14K',1,'2026-06'),
(8,'后端开发实习生','南京,苏州','3K-5K',2,'每周4天');

-- 更多职位
INSERT INTO `job_post` (`id`,`enterprise_id`,`category_id`,`title`,`job_type`,`recruit_num`,`city`,`salary_min`,`salary_max`,`education`,`major_require`,`experience`,`duty`,`requirement`,`welfare`,`audit_status`,`audit_remark`,`status`,`view_count`,`apply_count`,`publish_time`) VALUES
(6,4,9,'机器学习算法工程师',1,4,'杭州',16,25,'硕士','人工智能/计算机相关','应届','负责推荐、搜索、预测模型研发；参与机器学习平台建设。','熟悉机器学习基础算法，熟练使用Python，有竞赛或论文经验优先。','五险一金,年终奖,股票期权,补充医疗',1,NULL,1,210,0,'2026-03-06 09:00:00'),
(7,4,16,'数据分析师',1,5,'杭州',9,15,'本科','统计学/计算机/数学相关','应届','负责业务数据分析、指标体系建设和报表自动化。','熟悉SQL和数据可视化工具，具备良好的业务理解能力。','五险一金,弹性工作,年终奖',1,NULL,1,132,0,'2026-03-07 09:00:00'),
(8,5,24,'UI视觉设计师',1,3,'北京',8,14,'本科','设计相关','应届','负责App和Web端视觉设计、活动专题设计和品牌视觉规范。','熟练使用Figma、Sketch、Photoshop，作品集完整。','五险一金,免费三餐,带薪年假',1,NULL,1,98,0,'2026-03-08 09:00:00'),
(9,4,6,'Java后端开发实习生',2,8,'杭州',3,5,'本科','计算机相关','在校生','参与云平台后端接口开发和自动化测试。','每周实习4天以上，熟悉Java基础和Spring Boot者优先。','实习津贴,弹性工作,免费三餐',1,NULL,1,86,0,'2026-03-09 09:00:00'),
(10,5,8,'测试开发工程师',1,4,'北京',9,15,'本科','计算机/电子信息相关','应届','建设自动化测试平台，保障核心业务质量。','熟悉测试流程、Python或Java，有接口自动化经验优先。','五险一金,绩效奖金,带薪年假',1,NULL,1,115,0,'2026-03-10 09:00:00'),
(11,6,19,'用户运营专员',1,6,'成都',5,8,'本科','不限','应届','负责在线课程用户增长、社群运营和活动策划。','沟通能力强，具备数据意识和内容策划能力。','五险一金,节日福利,带薪年假',1,NULL,1,76,0,'2026-03-11 09:00:00'),
(12,6,13,'人力资源管培生',1,2,'成都',5,8,'本科','工商管理/人力资源相关','应届','参与校园招聘、员工培训和组织发展项目。','性格开朗，执行力强，具备良好沟通能力。','五险一金,节日福利,绩效奖金',1,NULL,1,61,0,'2026-03-12 09:00:00'),
(13,4,18,'安全工程师',1,3,'杭州',12,20,'本科','网络空间安全/计算机相关','应届','负责安全检测、漏洞修复和安全工具建设。','熟悉Web安全、Linux和常见安全测试工具。','五险一金,股票期权,补充医疗',1,NULL,1,129,0,'2026-03-13 09:00:00'),
(14,5,15,'Android开发工程师',1,4,'北京',10,17,'本科','计算机相关','应届','负责移动端业务开发、性能优化和组件化建设。','熟悉Kotlin/Java和Android基础框架。','五险一金,免费三餐,年终奖',1,NULL,1,84,0,'2026-03-14 09:00:00'),
(15,5,20,'电商运营专员',1,5,'北京',6,10,'本科','电子商务/市场营销','应届','负责商家活动、商品运营和数据复盘。','对本地生活和电商业务有兴趣，逻辑清晰。','五险一金,绩效奖金,节日福利',1,NULL,1,69,0,'2026-03-15 09:00:00'),
(16,7,22,'财务助理',1,2,'上海',6,9,'本科','会计学/财务管理','应届','协助预算、报销、账务核对和财务分析。','认真细致，熟悉Excel，具备会计基础知识。','五险一金,年终奖',0,NULL,1,40,0,'2026-03-16 09:00:00'),
(17,8,24,'视觉设计实习生',2,2,'武汉',2,4,'本科','设计相关','在校生','负责海报、物料和产品页面视觉支持。','有完整作品集，每周实习3天以上。','实习津贴,节日福利',2,'作品集链接无法打开，请补充材料',1,38,0,'2026-03-17 09:00:00'),
(18,1,26,'数据产品经理',1,2,'北京',10,16,'本科','计算机/统计/产品相关','应届','负责数据产品规划、需求分析和产品迭代。','具备数据分析能力和产品思维，有BI项目经验优先。','五险一金,免费三餐,股票期权',1,NULL,0,77,0,'2026-03-18 09:00:00'),
(19,2,17,'运维开发工程师',1,3,'深圳',10,16,'本科','计算机相关','应届','负责CI/CD、监控告警和自动化运维平台建设。','熟悉Linux、Shell/Python和容器技术。','五险一金,免费班车,股票期权',1,NULL,1,91,0,'2026-03-19 09:00:00'),
(20,4,21,'解决方案销售顾问',1,6,'上海',7,12,'本科','不限','应届','负责云计算产品售前咨询、客户沟通和方案推进。','表达能力强，愿意挑战客户沟通和销售目标。','五险一金,绩效奖金,补充医疗',1,NULL,1,58,0,'2026-03-20 09:00:00');

-- 更多简历与附件
INSERT INTO `resume` (`id`,`student_id`,`name`,`gender`,`birth`,`phone`,`email`,`college`,`major`,`education`,`skill_cert`,`award`,`self_eval`,`complete_rate`,`is_public`) VALUES
(3,3,'王五',1,'2002-11','13900000003','wangwu@stu.com','经济管理学院','市场营销','本科','CET-4、普通话二甲','校级营销策划大赛二等奖','善于沟通和活动策划，希望从事市场运营岗位。',78,1),
(4,4,'赵六',2,'2003-03','13900000004','zhaoliu@stu.com','人工智能学院','人工智能','本科','CET-6、Python数据分析证书','数学建模省赛二等奖、校级一等奖学金','熟悉机器学习、深度学习和数据分析工具，乐于钻研算法。',92,1),
(5,5,'孙七',1,'2003-07','13900000005','sunqi@stu.com','电子信息学院','电子信息工程','本科','CET-4、嵌入式开发实训证书','电子设计竞赛校赛一等奖','动手能力强，熟悉测试流程和基础硬件调试。',80,1),
(6,6,'周八',2,'2002-12','13900000006','zhouba@stu.com','经济管理学院','工商管理','本科','CET-6、人力资源管理师三级','优秀学生干部','有社团管理和活动运营经验，沟通协调能力强。',76,1),
(7,7,'吴越',1,'2003-01','13900000007','wuyue@stu.com','艺术设计学院','视觉传达设计','本科','Adobe认证设计师','校园文创设计大赛一等奖','关注用户体验，擅长视觉设计和交互原型。',88,1),
(8,8,'钱九',2,'2004-04','13900000008','qianjiu@stu.com','计算机学院','软件工程','本科','CET-4','软件工程课程设计优秀作品','正在寻找后端开发或测试开发实习机会。',62,0);

INSERT INTO `resume_education` (`resume_id`,`school`,`major`,`degree`,`start_date`,`end_date`,`description`) VALUES
(3,'某某大学','市场营销','本科','2021-09','2025-06','主修消费者行为学、市场调研、品牌管理等课程。'),
(4,'某某大学','人工智能','本科','2021-09','2025-06','主修机器学习、深度学习、数据挖掘、概率论等课程。'),
(5,'某某大学','电子信息工程','本科','2021-09','2025-06','主修数字电路、嵌入式系统、软件测试基础等课程。'),
(6,'某某大学','工商管理','本科','2020-09','2024-06','主修组织行为学、运营管理、人力资源管理等课程。'),
(7,'某某大学','视觉传达设计','本科','2021-09','2025-06','主修界面设计、交互设计、品牌视觉和用户研究。'),
(8,'某某大学','软件工程','本科','2022-09','2026-06','主修Java程序设计、软件工程、数据库系统。');

INSERT INTO `resume_project` (`resume_id`,`project_name`,`role`,`start_date`,`end_date`,`description`) VALUES
(3,'校园品牌推广策划','项目负责人','2024-04','2024-06','负责市场调研、活动方案、渠道投放和效果复盘。'),
(4,'校园招聘岗位推荐模型','算法负责人','2024-02','2024-05','基于学生画像和岗位标签构建推荐模型，完成特征工程和模型评估。'),
(4,'课程成绩预测分析','数据分析','2023-10','2023-12','使用Python完成数据清洗、建模和可视化报告。'),
(5,'接口自动化测试平台','测试开发','2024-03','2024-06','基于Python实现接口用例管理、批量执行和报告生成。'),
(6,'就业服务社群运营','运营负责人','2024-01','2024-04','组织求职分享会和线上答疑，累计服务学生500余人。'),
(7,'校园求职APP界面设计','UI设计','2024-03','2024-05','完成信息架构、交互原型、高保真视觉稿和设计规范。'),
(8,'图书管理系统','后端开发','2024-04','2024-06','基于Spring Boot完成图书借还、用户管理和数据统计模块。');

INSERT INTO `resume_experience` (`resume_id`,`company`,`position`,`start_date`,`end_date`,`description`) VALUES
(3,'某传媒公司','市场运营实习生','2024-07','2024-09','参与新媒体内容策划、用户调研和活动执行。'),
(4,'某AI实验室','算法实习生','2024-07','2024-10','参与文本分类模型训练与评估，优化数据标注流程。'),
(5,'某软件公司','测试实习生','2024-06','2024-08','负责Web系统功能测试和接口测试，输出缺陷报告。'),
(6,'某教育机构','社群运营实习生','2024-03','2024-06','维护学习社群，策划线上活动并跟踪转化数据。'),
(7,'某设计工作室','UI设计实习生','2024-07','2024-09','参与小程序页面设计和设计资产整理。'),
(8,'某信息公司','后端实习生','2025-01','2025-03','参与内部工具接口开发和单元测试编写。');

INSERT INTO `resume_attachment` (`student_id`,`file_name`,`file_url`,`file_size`,`file_type`) VALUES
(1,'张三-Java后端简历.pdf','/upload/resume/zhangsan-java.pdf',356240,'pdf'),
(2,'李四-前端开发简历.docx','/upload/resume/lisi-frontend.docx',284120,'docx'),
(4,'赵六-算法工程师简历.pdf','/upload/resume/zhaoliu-ai.pdf',426880,'pdf'),
(7,'吴越-UI作品集.pdf','/upload/resume/wuyue-ui-portfolio.pdf',1586240,'pdf'),
(8,'钱九-后端实习简历.doc','/upload/resume/qianjiu-backend.doc',196320,'doc');

-- 更多投递、面试、评价、Offer、收藏、人才库
INSERT INTO `job_apply` (`id`,`student_id`,`resume_id`,`job_id`,`enterprise_id`,`status`,`apply_remark`,`hr_remark`) VALUES
(4,3,3,11,6,0,'对教育行业用户运营很感兴趣',NULL),
(5,4,4,6,4,1,'希望参与机器学习平台建设','简历已查看，算法基础较好'),
(6,5,5,8,5,2,'附上测试项目经历，期待面试','邀请参加线上面试'),
(7,6,6,12,6,3,'有校园社团管理经验','进入笔试环节'),
(8,7,7,10,5,4,'希望转向测试体验方向','面试通过，已录用'),
(9,3,3,15,5,5,'关注电商运营方向','岗位匹配度一般'),
(10,4,4,13,4,2,'对安全和算法交叉方向感兴趣','安排安全基础面试'),
(11,1,1,6,4,0,'希望挑战算法方向',NULL),
(12,2,2,7,4,1,'具备前端和数据可视化经验','已查看，待业务评估'),
(13,5,5,14,5,0,'有移动端课程项目经验',NULL),
(14,6,6,19,2,3,'希望参与运维流程优化','笔试中'),
(15,7,7,8,5,2,'提交作品集供参考','邀请设计评审面试');

INSERT INTO `interview_notice` (`id`,`apply_id`,`student_id`,`enterprise_id`,`job_id`,`interview_time`,`interview_type`,`location`,`contact`,`remark`,`student_status`) VALUES
(2,6,5,5,8,'2026-03-22 10:00:00',2,'https://meeting.example.com/meituan-test','刘HR 010-55556666','请提前准备接口测试项目介绍',0),
(3,7,6,6,12,'2026-03-23 15:00:00',1,'成都市高新区A座会议室','何经理 028-66667777','现场笔试后进行群面',1),
(4,10,4,4,13,'2026-03-24 19:00:00',2,'https://meeting.example.com/security','陈HR 0571-26888888','请准备安全项目说明',2),
(5,15,7,5,8,'2026-03-26 14:30:00',2,'https://meeting.example.com/design-review','刘HR 010-55556666','请携带作品集讲解设计思路',0);

INSERT INTO `interview_feedback` (`notice_id`,`apply_id`,`enterprise_id`,`score`,`content`,`is_pass`,`interviewer`) VALUES
(1,1,1,88,'Java基础扎实，沟通顺畅，建议进入录用流程。',1,'王经理'),
(3,7,6,76,'表达能力好，笔试仍需加强。',0,'何经理'),
(4,10,4,82,'安全基础不错，但实战经验略少，可进入复试。',1,'陈HR');

INSERT INTO `offer_record` (`id`,`apply_id`,`student_id`,`enterprise_id`,`job_id`,`position`,`salary`,`work_city`,`report_time`,`content`,`offer_status`) VALUES
(2,8,7,5,10,'测试开发工程师','12K','北京','2026-07-05','恭喜通过测试开发岗位面试，请按时报到。',1),
(3,7,6,6,12,'人力资源管培生','7K','成都','2026-07-10','感谢参与面试，现发放管培生岗位Offer。',2),
(4,6,5,5,8,'UI视觉设计师','11K','北京','2026-07-08','Offer已因岗位调整撤回。',3),
(5,15,7,5,8,'UI视觉设计师','12K','北京','2026-07-12','设计评审通过后发放待确认Offer。',0);

INSERT INTO `favorite_job` (`student_id`,`job_id`) VALUES
(1,6),(1,13),(2,7),(2,9),(3,11),(3,15),(4,6),(4,13),(5,8),(5,10),(6,12),(6,19),(7,8),(7,14),(8,9);

INSERT INTO `talent_pool` (`enterprise_id`,`student_id`,`resume_id`,`tag`,`remark`) VALUES
(1,2,2,'前端优秀','前端基础扎实，可关注后续岗位'),
(2,1,1,'Java后端','已面试，技术潜力较好'),
(4,4,4,'算法苗子','数学基础好，推荐算法方向'),
(4,1,1,'可培养','Java基础好，适合后端/算法交叉培养'),
(5,7,7,'设计作品集优秀','作品集完整，可约设计评审'),
(6,3,3,'运营潜力','活动策划经验丰富');

-- 更多内容、活动和互动数据
INSERT INTO `banner` (`title`,`image_url`,`link_url`,`sort`,`status`) VALUES
('AI与大数据专场岗位精选','/upload/image/seed/banner-ai-data.jpg','/jobs?keyword=算法',4,1),
('简历门诊与面试辅导开放预约','/upload/image/seed/banner-resume-clinic.jpg','/news/2',5,1),
('校园职业发展服务预览','/upload/image/seed/banner-career-guidance.jpg','',99,0);

INSERT INTO `announcement` (`id`,`category_id`,`title`,`summary`,`content`,`author`,`view_count`,`is_top`,`status`,`publish_time`) VALUES
(4,1,'教育部关于促进高校毕业生高质量充分就业的提示','梳理就业政策、基层就业和灵活就业支持措施。','<p>各学院应持续开展就业指导和岗位推荐服务，帮助毕业生高质量充分就业。</p>','就业办',188,1,1,'2026-03-05 10:00:00'),
(5,2,'阿里云校园招聘算法与云计算岗位开放','阿里云春招岗位开放，覆盖算法、研发、数据和销售。','<p>阿里云本轮校招岗位包含机器学习算法、数据分析、运维开发等方向。</p>','就业办',166,0,1,'2026-03-06 10:00:00'),
(6,3,'无领导小组面试准备指南','介绍群面常见流程、角色分工和表达技巧。','<p>群面应重视信息梳理、观点表达和团队协作，避免过度争抢发言。</p>','就业指导中心',142,0,1,'2026-03-07 10:00:00'),
(7,4,'我校举办2026届毕业生就业动员会','学校召开就业动员会，部署就业指导和服务工作。','<p>会议强调要精准帮扶、拓展岗位、提升就业服务质量。</p>','校园新闻中心',96,0,1,'2026-03-08 10:00:00'),
(8,2,'金融科技企业专场招聘预告','金融科技、风控、数据产品岗位即将开放。','<p>海纳金融科技将面向我校发布数据产品、财务和风控岗位。</p>','就业办',75,0,0,NULL);

INSERT INTO `campus_talk` (`id`,`title`,`enterprise_id`,`company_name`,`talk_time`,`location`,`content`,`sign_count`,`status`) VALUES
(3,'阿里云AI与云计算宣讲会',4,'阿里云计算有限公司','2026-04-02 19:00:00','信息楼二楼报告厅','介绍阿里云技术体系、校招流程和技术成长路径。',72,1),
(4,'美团本地生活业务宣讲',5,'美团科技有限公司','2026-04-06 19:00:00','大学生活动中心多功能厅','研发、产品、运营、设计岗位介绍及校友经验分享。',64,1),
(5,'启航在线教育产品运营分享',6,'启航在线教育科技有限公司','2026-04-12 15:00:00','经管学院报告厅','教育科技行业发展、用户运营和课程产品岗位介绍。',31,1),
(6,'金融科技专场预告',7,'海纳金融科技有限公司','2026-04-18 19:00:00','线上直播','认证通过后开放报名。',12,0);

INSERT INTO `job_fair` (`id`,`title`,`fair_time`,`location`,`host`,`content`,`company_count`,`job_count`,`sign_count`,`status`) VALUES
(3,'互联网名企校园招聘周','2026-04-22 09:00:00','学校体育馆东区','校就业指导中心','集中展示互联网、云计算、AI方向岗位。',80,2200,610,1),
(4,'经管与金融专场双选会','2026-04-28 09:00:00','经管学院大厅','经济管理学院','面向运营、市场、金融、财务、人力资源岗位。',55,900,360,1),
(5,'设计与传媒创意招聘会','2026-05-08 09:00:00','艺术设计学院展厅','艺术设计学院','提供UI、交互、视觉、新媒体方向岗位。',32,420,210,1),
(6,'已结束招聘会示例','2026-02-20 09:00:00','旧体育馆','校就业办','用于验证关闭状态不在公共列表展示。',20,200,80,0);

INSERT INTO `activity_sign` (`activity_type`,`activity_id`,`student_id`,`sign_status`) VALUES
(1,1,1,2),(1,1,2,1),(1,2,1,1),(1,3,4,1),(1,3,5,2),(1,4,7,1),(1,5,6,3),
(2,1,1,2),(2,1,3,1),(2,2,2,1),(2,3,4,1),(2,3,5,1),(2,4,6,3),(2,5,7,1);

INSERT INTO `forum_post` (`id`,`student_id`,`author_name`,`title`,`content`,`category`,`view_count`,`like_count`,`comment_count`,`audit_status`,`status`) VALUES
(3,4,'赵六','算法岗笔试应该如何准备？','最近在准备算法岗笔试，想请教动态规划和机器学习基础如何安排复习。','求职交流',121,18,2,1,1),
(4,5,'孙七','测试开发岗位面试题整理','整理了接口测试、自动化测试和数据库常见面试问题。','经验分享',186,31,2,1,1),
(5,7,'吴越','拿到设计岗位Offer啦','感谢社区里大家对作品集的建议，终于拿到Offer。','Offer捷报',143,36,1,1,1),
(6,6,'周八','运营岗位群面复盘','今天参加无领导小组讨论，记录几个容易踩坑的点。','经验分享',65,9,0,0,1),
(7,8,'钱九','后端实习投递求建议','简历完整度还不高，希望大家帮忙看看。','求职交流',43,4,0,2,1),
(8,3,'王五','隐藏帖子示例','用于验证后台隐藏状态。','求职交流',12,1,0,1,0);

INSERT INTO `forum_comment` (`post_id`,`student_id`,`author_name`,`content`,`like_count`,`status`) VALUES
(3,1,'张三','建议先刷基础题，再按岗位补充机器学习常见题。',4,1),
(3,2,'李四','可以整理一个错题本，复盘效率会高很多。',2,1),
(4,5,'孙七','补充：接口自动化最好准备一个完整项目案例。',6,1),
(4,1,'张三','数据库事务和索引也经常会问。',3,1),
(5,7,'吴越','感谢大家，我会整理作品集经验分享。',8,1),
(1,4,'赵六','谢谢分享，字节面试流程很清晰。',1,1);

INSERT INTO `message_feedback` (`user_id`,`user_type`,`user_name`,`content`,`contact`,`reply`,`reply_time`,`status`) VALUES
(4,'STUDENT','赵六','希望增加算法岗专场筛选。','zhaoliu@stu.com',NULL,NULL,0),
(5,'STUDENT','孙七','附件简历上传后列表展示很直观。','sunqi@stu.com','感谢反馈，我们会持续优化体验。','2026-03-10 11:00:00',1),
(4,'ENTERPRISE','阿里云计算有限公司','企业端希望支持批量刷新岗位。','campus@aliyun.com',NULL,NULL,0),
(NULL,'GUEST','访客','请问往届生是否可以参加招聘会？','guest@example.com','可以关注学校就业办后续通知。','2026-03-11 15:00:00',1);

UPDATE `message_feedback` SET `reply`='感谢支持，简历预览功能后续会继续优化。', `reply_time`='2026-03-09 10:00:00' WHERE `user_name`='李四';

INSERT INTO `system_notice` (`receiver_id`,`receiver_type`,`title`,`content`,`notice_type`,`is_read`) VALUES
(2,'STUDENT','收藏岗位提醒','您收藏的Java开发工程师岗位仍在招聘中。','SYSTEM',0),
(4,'STUDENT','投递状态更新','您投递的机器学习算法工程师简历已被查看。','APPLY',0),
(5,'STUDENT','面试邀请','美团邀请您参加UI视觉设计师线上面试。','INTERVIEW',0),
(7,'STUDENT','Offer通知','您收到美团测试开发工程师Offer。','OFFER',1),
(4,'ENTERPRISE','岗位审核通过','机器学习算法工程师岗位已通过审核。','AUDIT',0),
(5,'ENTERPRISE','新的简历投递','您发布的UI视觉设计师岗位收到新的投递。','APPLY',0),
(1,'ADMIN','待审核提醒','当前有企业认证和岗位待审核，请及时处理。','SYSTEM',0),
(3,'ADMIN','异常日志提醒','系统检测到一次登录失败记录，请关注。','SYSTEM',1);

INSERT INTO `operation_log` (`user_id`,`user_type`,`user_name`,`log_type`,`module`,`operation`,`method`,`params`,`ip`,`status`,`error_msg`,`cost_time`) VALUES
(1,'ADMIN','admin','OPERATION','岗位审核','审核通过岗位：Java开发工程师','PUT /admin/job/1/audit','status=1','127.0.0.1',1,NULL,48),
(4,'ENTERPRISE','alibaba','OPERATION','职位管理','发布岗位：机器学习算法工程师','POST /enterprise/job','title=机器学习算法工程师','127.0.0.1',1,NULL,66),
(4,'STUDENT','zhaoliu','LOGIN','登录','学生登录系统','POST /auth/login','role=STUDENT','127.0.0.1',1,NULL,31),
(9,'STUDENT','disabled_stu','LOGIN','登录','停用学生登录失败','POST /auth/login','role=STUDENT','127.0.0.1',0,'账号已被禁用，请联系管理员',29),
(1,'ADMIN','admin','ERROR','导出','导出岗位数据异常示例','GET /admin/export/job','{}','127.0.0.1',0,'演示异常日志',103);

-- 让展示统计与明细保持一致
UPDATE `job_post` jp SET `apply_count` = (SELECT COUNT(*) FROM `job_apply` ja WHERE ja.`job_id` = jp.`id` AND ja.`deleted` = 0);
UPDATE `forum_post` fp SET `comment_count` = (SELECT COUNT(*) FROM `forum_comment` fc WHERE fc.`post_id` = fp.`id` AND fc.`deleted` = 0 AND fc.`status` = 1);
UPDATE `campus_talk` ct SET `sign_count` = GREATEST(ct.`sign_count`, (SELECT COUNT(*) FROM `activity_sign` s WHERE s.`activity_type` = 1 AND s.`activity_id` = ct.`id` AND s.`deleted` = 0 AND s.`sign_status` <> 3));
UPDATE `job_fair` jf SET `sign_count` = GREATEST(jf.`sign_count`, (SELECT COUNT(*) FROM `activity_sign` s WHERE s.`activity_type` = 2 AND s.`activity_id` = jf.`id` AND s.`deleted` = 0 AND s.`sign_status` <> 3));

-- 演示头像与企业 Logo
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

-- 首页补充演示数据：用于宽屏门户展示，保留原有待审核/驳回/停用样例不变
INSERT INTO `enterprise` (`id`,`username`,`password`,`company_name`,`credit_code`,`industry`,`scale`,`nature`,`address`,`city`,`logo`,`intro`,`welfare`,`contact_name`,`contact_phone`,`email`,`website`,`audit_status`,`status`) VALUES
(10,'sparkai','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','星火人工智能科技有限公司','916101001234567900','人工智能','100-499人','民营企业','西安市高新区科技二路','西安','/upload/image/seed/enterprise-newcorp-logo-v2.png','专注大模型应用、智能客服和行业知识库产品研发。','五险一金,年终奖,弹性工作,补充医疗','周经理','029-66668888','campus@sparkai.com','https://www.sparkai.com',2,1),
(11,'cloudway','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','云途物流科技有限公司','914401001234567901','互联网','500-999人','民营企业','广州市天河区软件园','广州','/upload/image/seed/enterprise-greenmaker-logo-v2.png','面向智慧物流、供应链协同和跨境电商提供数字化平台。','五险一金,绩效奖金,带薪年假,免费班车','吴HR','020-88990011','hr@cloudway.com','https://www.cloudway.com',2,1),
(12,'mokerplay','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','墨客互动游戏有限公司','914301001234567902','游戏','100-499人','民营企业','长沙市岳麓区麓谷企业广场','长沙','/upload/image/seed/enterprise-meituan-logo-v2.png','研发休闲竞技、互动剧情和校园创意游戏产品。','五险一金,年终奖,节日福利,弹性工作','唐主管','0731-77889900','jobs@mokerplay.com','https://www.mokerplay.com',2,1);

INSERT INTO `job_post` (`id`,`enterprise_id`,`category_id`,`title`,`job_type`,`recruit_num`,`city`,`salary_min`,`salary_max`,`education`,`major_require`,`experience`,`duty`,`requirement`,`welfare`,`audit_status`,`audit_remark`,`status`,`view_count`,`apply_count`,`publish_time`) VALUES
(21,10,9,'NLP算法工程师',1,4,'西安',13,20,'硕士','人工智能/计算机相关','应届','负责文本理解、检索增强和行业模型调优；参与算法效果评估与上线迭代。','熟悉机器学习、深度学习和Python，有NLP项目或竞赛经验优先。','五险一金,年终奖,弹性工作,补充医疗',1,NULL,1,144,6,'2026-03-21 09:00:00'),
(22,10,16,'数据平台开发工程师',1,5,'西安',10,16,'本科','计算机/数据科学相关','应届','负责数据采集、清洗、指标计算和可视化平台建设。','熟悉SQL、Java或Python，理解数仓建模和任务调度。','五险一金,年终奖,带薪年假',1,NULL,1,118,4,'2026-03-22 09:00:00'),
(23,10,26,'AI产品经理',1,3,'西安',8,13,'本科','计算机/工业设计/管理相关','应届','负责AI应用产品需求分析、原型设计和版本迭代跟进。','具备产品思维和沟通能力，了解大模型应用场景者优先。','五险一金,弹性工作,节日福利',1,NULL,1,104,3,'2026-03-23 09:00:00'),
(24,11,17,'后端运维开发工程师',1,4,'广州',9,15,'本科','计算机相关','应届','负责物流平台服务治理、监控告警和自动化运维工具开发。','熟悉Linux、Docker、Java或Go，具备问题定位能力。','五险一金,绩效奖金,免费班车',1,NULL,1,112,5,'2026-03-24 09:00:00'),
(25,11,20,'跨境电商运营专员',1,6,'广州',6,10,'本科','电子商务/市场营销','应届','负责跨境店铺活动、商品运营、用户增长和数据复盘。','英语读写良好，数据敏感，执行力强。','五险一金,绩效奖金,带薪年假',1,NULL,1,97,4,'2026-03-25 09:00:00'),
(26,11,21,'校园客户成功顾问',1,5,'广州',5,9,'本科','不限','应届','负责校园客户需求跟进、产品培训和续约支持。','表达清晰，服务意识强，能适应短期出差。','五险一金,节日福利,带薪年假',1,NULL,1,83,2,'2026-03-26 09:00:00'),
(27,12,15,'游戏客户端开发工程师',1,4,'长沙',9,15,'本科','计算机/软件工程相关','应届','负责Unity客户端功能开发、性能优化和工具链建设。','熟悉C#或C++，有游戏Demo或项目作品优先。','五险一金,年终奖,弹性工作',1,NULL,1,126,6,'2026-03-27 09:00:00'),
(28,12,25,'交互设计师',1,3,'长沙',7,12,'本科','交互设计/视觉传达相关','应届','负责游戏活动页、社区互动和工具产品交互方案。','熟悉Figma，理解用户体验方法，有完整作品集。','五险一金,节日福利,弹性工作',1,NULL,1,92,3,'2026-03-28 09:00:00');

-- ============================================================================
-- 脚本结束
-- ============================================================================
