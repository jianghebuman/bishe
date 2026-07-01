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
  5. 末尾附带字典数据、轮播图、公告、宣讲会、招聘会、职位、简历等样例数据
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
-- 学校基础数据表
-- ----------------------------
DROP TABLE IF EXISTS `school`;
CREATE TABLE `school` (
  `id`          bigint      NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name`        varchar(80) NOT NULL COMMENT '学校名称',
  `sort`        int                  DEFAULT 0 COMMENT '排序',
  `status`      tinyint     NOT NULL DEFAULT 1 COMMENT '状态：1启用0停用',
  `create_time` datetime             DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime             DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`     tinyint     NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_school_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学校基础数据表';

-- ----------------------------
-- 学生表
-- ----------------------------
DROP TABLE IF EXISTS `student`;
CREATE TABLE `student` (
  `id`            bigint       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username`      varchar(50)  NOT NULL COMMENT '登录账号',
  `password`      varchar(100) NOT NULL COMMENT '密码(BCrypt)',
  `real_name`     varchar(50)           DEFAULT NULL COMMENT '姓名',
  `school`        varchar(80)  NOT NULL COMMENT '学校',
  `student_no`    varchar(30)  NOT NULL COMMENT '学号',
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
  UNIQUE KEY `uk_student_username` (`username`),
  UNIQUE KEY `uk_student_school_no` (`school`,`student_no`),
  KEY `idx_student_school` (`school`)
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
  `username`      varchar(50)           DEFAULT NULL COMMENT '旧企业登录账号(兼容迁移)',
  `password`      varchar(100)          DEFAULT NULL COMMENT '旧企业密码(兼容迁移)',
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
-- 企业 HR 账号表
-- ----------------------------
DROP TABLE IF EXISTS `enterprise_hr`;
CREATE TABLE `enterprise_hr` (
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
  `verify_source`  varchar(120)          DEFAULT NULL COMMENT '权威核验来源',
  `verify_source_url` varchar(255)       DEFAULT NULL COMMENT '权威核验来源地址',
  `verify_time`    datetime              DEFAULT NULL COMMENT '权威核验时间',
  `verify_company_name` varchar(120)     DEFAULT NULL COMMENT '权威来源企业名称',
  `verify_credit_code` varchar(60)       DEFAULT NULL COMMENT '权威来源统一社会信用代码',
  `verify_status`  varchar(60)           DEFAULT NULL COMMENT '权威来源登记状态',
  `verify_result`  tinyint      NOT NULL DEFAULT 0 COMMENT '核验结果：0未核验1一致2不一致3未接入或异常',
  `verify_remark`  varchar(255)          DEFAULT NULL COMMENT '核验说明',
  `verify_snapshot_hash` varchar(64)     DEFAULT NULL COMMENT '权威返回快照SHA256',
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
  `hr_id`          bigint                DEFAULT NULL COMMENT '负责HR账号ID',
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
  KEY `idx_job_hr` (`hr_id`),
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

-- ----------------------------
-- 求职栏信息表
-- ----------------------------
DROP TABLE IF EXISTS `job_seeker_post`;
CREATE TABLE `job_seeker_post` (
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
  `hr_id`         bigint            DEFAULT NULL COMMENT '负责HR账号ID',
  `status`        tinyint  NOT NULL DEFAULT 0 COMMENT '状态：0待查看1已查看2邀请面试3笔试4已录用5不合适',
  `apply_remark`  varchar(255)      DEFAULT NULL COMMENT '投递备注',
  `hr_remark`     varchar(255)      DEFAULT NULL COMMENT 'HR备注',
  `create_time`   datetime          DEFAULT CURRENT_TIMESTAMP COMMENT '投递时间',
  `update_time`   datetime          DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`       tinyint  NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_apply_student` (`student_id`),
  KEY `idx_apply_job` (`job_id`),
  KEY `idx_apply_enterprise` (`enterprise_id`),
  KEY `idx_apply_hr` (`hr_id`)
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
  `hr_id`          bigint            DEFAULT NULL COMMENT '负责HR账号ID',
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
  KEY `idx_notice_enterprise` (`enterprise_id`),
  KEY `idx_notice_hr` (`hr_id`)
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
  `hr_id`         bigint           DEFAULT NULL COMMENT '负责HR账号ID',
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
  `hr_id`          bigint            DEFAULT NULL COMMENT '负责HR账号ID',
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
  KEY `idx_offer_enterprise` (`enterprise_id`),
  KEY `idx_offer_hr` (`hr_id`)
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
-- 企业收藏表
-- ----------------------------
DROP TABLE IF EXISTS `favorite_enterprise`;
CREATE TABLE `favorite_enterprise` (
  `id`            bigint   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `student_id`    bigint   NOT NULL COMMENT '学生ID',
  `enterprise_id` bigint   NOT NULL COMMENT '企业ID',
  `create_time`   datetime          DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  `update_time`   datetime          DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`       tinyint  NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_fav_enterprise_student` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='企业收藏表';

-- ----------------------------
-- 人才库表
-- ----------------------------
DROP TABLE IF EXISTS `talent_pool`;
CREATE TABLE `talent_pool` (
  `id`            bigint   NOT NULL AUTO_INCREMENT COMMENT '主键',
  `enterprise_id` bigint   NOT NULL COMMENT '企业ID',
  `hr_id`         bigint            DEFAULT NULL COMMENT '负责HR账号ID',
  `student_id`    bigint   NOT NULL COMMENT '学生ID',
  `resume_id`     bigint            DEFAULT NULL COMMENT '简历ID',
  `tag`           varchar(120)      DEFAULT NULL COMMENT '标签',
  `remark`        varchar(255)      DEFAULT NULL COMMENT '备注',
  `create_time`   datetime          DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  `update_time`   datetime          DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted`       tinyint  NOT NULL DEFAULT 0 COMMENT '逻辑删除：0否1是',
  PRIMARY KEY (`id`),
  KEY `idx_talent_enterprise` (`enterprise_id`),
  KEY `idx_talent_hr` (`hr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='人才库表';

-- ----------------------------
-- 在线沟通消息表
-- ----------------------------
DROP TABLE IF EXISTS `chat_message`;
CREATE TABLE `chat_message` (
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

-- 学校
INSERT INTO `school` (`id`,`name`,`sort`,`status`) VALUES
(1,'江南应用科技大学',1,1),
(2,'星海数据学院',2,1),
(3,'华东数字传媒学院',3,1),
(4,'南城财经科技大学',4,1),
(5,'星河文旅运营管理学院',5,1);

-- 管理员账号（密码均为 123456 的 BCrypt 串）
-- BCrypt: $2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO
INSERT INTO `admin_user` (`id`,`username`,`password`,`real_name`,`phone`,`email`,`role_id`,`status`) VALUES
(1,'admin','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','超级管理员','13800000000','admin@campus.com',1,1),
(2,'jiuyeban','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','就业办老师','13800000001','jyb@campus.com',1,1);

-- 学生账号（密码 123456）
INSERT INTO `student` (`id`,`username`,`password`,`real_name`,`school`,`student_no`,`gender`,`college`,`major`,`grade`,`education`,`phone`,`email`,`status`) VALUES
(1,'student','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','张三','江南应用科技大学','2021001001',1,'计算机学院','计算机科学与技术','2021级','本科','13900000001','zhangsan@stu.com',1),
(2,'lisi','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','李四','江南应用科技大学','2021001002',2,'计算机学院','软件工程','2021级','本科','13900000002','lisi@stu.com',1),
(3,'wangwu','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','王五','南城财经科技大学','2021002001',1,'经济管理学院','市场营销','2021级','本科','13900000003','wangwu@stu.com',1);

-- 企业账号（密码 123456）
INSERT INTO `enterprise` (`id`,`username`,`password`,`company_name`,`credit_code`,`industry`,`scale`,`nature`,`address`,`city`,`intro`,`welfare`,`contact_name`,`contact_phone`,`email`,`audit_status`,`status`) VALUES
(1,'company','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','字节跳动科技有限公司','911100001234567890','互联网','1000人以上','民营企业','北京市海淀区','北京','字节跳动是一家全球化的科技公司，旗下产品包括抖音、今日头条等。','五险一金,年终奖,带薪年假,免费三餐','HR王经理','010-88888888','hr@bytedance.com',2,1),
(2,'tencent','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','腾讯科技有限公司','914403001234567891','互联网','1000人以上','民营企业','深圳市南山区','深圳','腾讯是领先的互联网增值服务提供商之一。','五险一金,股票期权,弹性工作,免费班车','李HR','0755-86013388','hr@tencent.com',2,1),
(3,'newcorp','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','创新未来信息技术有限公司','913100001234567892','计算机软件','100-499人','民营企业','上海市浦东新区','上海','专注于企业数字化转型的创新型科技公司。','五险一金,绩效奖金,节日福利','张总监','021-66668888','hr@newcorp.com',1,1);

INSERT INTO `enterprise_hr` (`id`,`enterprise_id`,`username`,`password`,`real_name`,`phone`,`email`,`hr_role`,`status`) VALUES
(1,1,'company','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','HR王经理','010-88888888','hr@bytedance.com','SUPERVISOR',1),
(2,2,'tencent','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','李HR','0755-86013388','hr@tencent.com','SUPERVISOR',1),
(3,3,'newcorp','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','张总监','021-66668888','hr@newcorp.com','SUPERVISOR',1);

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

-- Offer 样例
INSERT INTO `offer_record` (`id`,`apply_id`,`student_id`,`enterprise_id`,`job_id`,`position`,`salary`,`work_city`,`report_time`,`content`,`offer_status`) VALUES
(1,1,1,1,1,'Java开发工程师','14K','北京','2026-07-01','恭喜您通过我司面试，期待您的加入！',0);

-- 职位收藏
INSERT INTO `favorite_job` (`student_id`,`job_id`) VALUES (1,2),(1,4),(2,1);

-- 企业收藏
INSERT INTO `favorite_enterprise` (`student_id`,`enterprise_id`) VALUES (1,1),(1,2),(2,1);

-- 轮播图
INSERT INTO `banner` (`title`,`image_url`,`link_url`,`sort`,`status`) VALUES
('春季校园双选会岗位上线','/upload/image/seed/banner-campus-fair.jpg','/fairs',1,1),
('名企宣讲与校招直通','/upload/image/seed/banner-enterprise-talk.jpg','/talks',2,1),
('就业政策与求职指导','/upload/image/seed/banner-career-guidance.jpg','/news',3,1);

-- 公告资讯
INSERT INTO `announcement` (`id`,`category_id`,`title`,`summary`,`content`,`author`,`view_count`,`is_top`,`status`,`publish_time`) VALUES
(1,1,'关于2026届毕业生就业工作的通知','学校就业办发布2026届毕业生就业相关政策与安排。','<p>各位同学：</p><p>为做好2026届毕业生就业工作，现将有关事项通知如下……</p>','就业办',320,1,1,'2026-03-01 10:00:00'),
(2,3,'求职简历撰写技巧','一份优秀的简历是求职成功的第一步。','<p>简历应突出重点，量化成果，避免冗长……</p>','就业指导中心',256,0,1,'2026-03-02 10:00:00'),
(3,2,'多家名企春招岗位发布','字节跳动、腾讯等企业春招岗位现已开放。','<p>本周新增多家名企招聘岗位，欢迎同学们积极投递……</p>','就业办',198,0,1,'2026-03-03 10:00:00'),
(4,4,'我校举办2026届毕业生就业动员会','学校召开就业动员会，部署就业指导和服务工作。','<p>会议强调要精准帮扶、拓展岗位、提升就业服务质量。</p>','校园新闻中心',96,0,1,'2026-03-08 10:00:00'),
(5,2,'阿里云校园招聘算法与云计算岗位开放','阿里云春招岗位开放，覆盖算法、研发、数据和销售。','<p>阿里云本轮校招岗位包含机器学习算法、数据分析、运维开发等方向。</p>','就业办',166,0,1,'2026-03-06 10:00:00'),
(6,3,'无领导小组面试准备指南','介绍群面常见流程、角色分工和表达技巧。','<p>群面应重视信息梳理、观点表达和团队协作，避免过度争抢发言。</p>','就业指导中心',142,0,1,'2026-03-07 10:00:00'),
(7,1,'教育部关于促进高校毕业生高质量充分就业的提示','梳理就业政策、基层就业和灵活就业支持措施。','<p>各学院应持续开展就业指导和岗位推荐服务，帮助毕业生高质量充分就业。</p>','就业办',188,1,1,'2026-03-05 10:00:00'),
(8,2,'金融科技企业专场招聘预告','金融科技、风控、数据产品岗位即将开放。','<p>海纳金融科技将面向我校发布数据产品、财务和风控岗位。</p>','就业办',75,0,0,NULL);

-- 宣讲会
INSERT INTO `campus_talk` (`id`,`title`,`enterprise_id`,`company_name`,`talk_time`,`location`,`content`,`sign_count`,`status`) VALUES
(1,'字节跳动校园宣讲会',1,'字节跳动科技有限公司','2026-03-25 19:00:00','大学生活动中心报告厅','介绍公司文化、招聘岗位及发展前景。',45,1),
(2,'腾讯春季校园宣讲',2,'腾讯科技有限公司','2026-03-28 19:00:00','信息楼一楼报告厅','腾讯各业务线岗位介绍与现场答疑。',38,1),
(3,'阿里云AI与云计算宣讲会',4,'阿里云计算有限公司','2026-04-02 19:00:00','信息楼二楼报告厅','介绍阿里云技术体系、校招流程和技术成长路径。',72,1),
(4,'美团本地生活业务宣讲',5,'美团科技有限公司','2026-04-06 19:00:00','大学生活动中心多功能厅','研发、产品、运营、设计岗位介绍及校友经验分享。',64,1),
(5,'启航在线教育产品运营分享',6,'启航在线教育科技有限公司','2026-04-12 15:00:00','经管学院报告厅','教育科技行业发展、用户运营和课程产品岗位介绍。',31,1),
(6,'金融科技专场预告',7,'海纳金融科技有限公司','2026-04-18 19:00:00','线上直播','认证通过后开放报名。',12,0);

-- 招聘会
INSERT INTO `job_fair` (`id`,`title`,`fair_time`,`location`,`host`,`content`,`company_count`,`job_count`,`sign_count`,`status`) VALUES
(1,'2026春季大型校园双选会','2026-04-10 09:00:00','学校体育馆','校就业指导中心','汇聚百余家优质企业，提供数千个就业岗位。',120,3500,860,1),
(2,'IT行业专场招聘会','2026-04-15 09:00:00','计算机学院一楼大厅','计算机学院','面向计算机相关专业的专场招聘活动。',45,1200,420,1),
(3,'互联网名企校园招聘周','2026-04-22 09:00:00','学校体育馆东区','校就业指导中心','集中展示互联网、云计算、AI方向岗位。',80,2200,610,1),
(4,'经管与金融专场双选会','2026-04-28 09:00:00','经管学院大厅','经济管理学院','面向运营、市场、金融、财务、人力资源岗位。',55,900,360,1),
(5,'设计与传媒创意招聘会','2026-05-08 09:00:00','艺术设计学院展厅','艺术设计学院','提供UI、交互、视觉、新媒体方向岗位。',32,420,210,1),
(6,'已结束招聘会示例','2026-02-20 09:00:00','旧体育馆','校就业办','用于验证关闭状态不在公共列表展示。',20,200,80,0);

-- 论坛帖子
INSERT INTO `forum_post` (`id`,`student_id`,`author_name`,`title`,`content`,`category`,`view_count`,`like_count`,`comment_count`,`audit_status`,`status`) VALUES
(1,1,'张三','分享一下我的字节面试经验','今天去字节面试了，整体感觉还不错，面试官很专业……','经验分享',156,23,2,1,1),
(2,2,'李四','应届生该如何准备前端面试？','想请教各位学长学姐，前端面试一般会问哪些问题？','求职交流',98,12,1,1,1),
(3,4,'赵六','算法岗笔试应该如何准备？','最近在准备算法岗笔试，想请教动态规划和机器学习基础如何安排复习。','求职交流',121,18,2,1,1),
(4,5,'孙七','测试开发岗位面试题整理','整理了接口测试、自动化测试和数据库常见面试问题。','经验分享',186,31,2,1,1),
(5,7,'吴越','拿到设计岗位Offer啦','感谢社区里大家对作品集的建议，终于拿到Offer。','Offer捷报',143,36,1,1,1),
(6,6,'周八','运营岗位群面复盘','今天参加无领导小组讨论，记录几个容易踩坑的点。','经验分享',65,9,0,0,1),
(7,8,'钱九','后端实习投递求建议','简历完整度还不高，希望大家帮忙看看。','求职交流',43,4,0,2,1),
(8,3,'王五','隐藏帖子示例','用于验证后台隐藏状态。','求职交流',12,1,0,1,0);

-- 论坛评论
INSERT INTO `forum_comment` (`post_id`,`student_id`,`author_name`,`content`,`like_count`,`status`) VALUES
(1,2,'李四','感谢分享，很有帮助！',5,1),
(1,3,'王五','请问算法题难吗？',2,1),
(2,1,'张三','建议多刷面经，重点准备项目经历。',3,1),
(3,1,'张三','建议先刷基础题，再按岗位补充机器学习常见题。',4,1),
(3,2,'李四','可以整理一个错题本，复盘效率会高很多。',2,1),
(4,5,'孙七','补充：接口自动化最好准备一个完整项目案例。',6,1),
(4,1,'张三','数据库事务和索引也经常会问。',3,1),
(5,7,'吴越','感谢大家，我会整理作品集经验分享。',8,1),
(1,4,'赵六','谢谢分享，字节面试流程很清晰。',1,1);

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
-- 8. 扩展样例数据：覆盖更多状态、分页、审核、活动、人才库与日志
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
(33,'admin:seeker-post','求职信息管理','MENU',0,'/admin/seeker-post',14),
(14,'enterprise:dashboard','企业数据看板','MENU',0,'/enterprise/dashboard',1),
(15,'enterprise:profile','企业资料','MENU',0,'/enterprise/profile',2),
(16,'enterprise:audit','企业认证','MENU',0,'/enterprise/audit',3),
(17,'enterprise:job','职位管理','MENU',0,'/enterprise/job',4),
(18,'enterprise:apply','简历筛选','MENU',0,'/enterprise/apply',5),
(19,'enterprise:interview','面试管理','MENU',0,'/enterprise/interview',6),
(20,'enterprise:offer','Offer管理','MENU',0,'/enterprise/offer',7),
(21,'enterprise:talent','人才库','MENU',0,'/enterprise/talent',8),
(34,'enterprise:chat','在线沟通','MENU',0,'/enterprise/chat',9),
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
(32,'student:forum','我的帖子','MENU',0,'/student/myposts',11),
(35,'student:seeker-post','我的求职信息','MENU',0,'/student/seeker-post',12),
(36,'student:chat','在线沟通','MENU',0,'/student/chat',13);

INSERT INTO `role_permission` (`role_id`,`permission_id`) VALUES
(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9),(1,10),(1,11),(1,12),(1,13),(1,33),
(2,14),(2,15),(2,16),(2,17),(2,18),(2,19),(2,20),(2,21),(2,34),
(3,22),(3,23),(3,24),(3,25),(3,26),(3,27),(3,28),(3,29),(3,30),(3,31),(3,32),(3,35),(3,36);

-- 更多账号
INSERT INTO `admin_user` (`id`,`username`,`password`,`real_name`,`phone`,`email`,`role_id`,`status`) VALUES
(3,'auditor','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','审核专员','13800000002','auditor@campus.com',1,1),
(4,'disabled_admin','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','停用管理员','13800000003','disabled.admin@campus.com',1,0);

INSERT INTO `student` (`id`,`username`,`password`,`real_name`,`school`,`student_no`,`gender`,`college`,`major`,`grade`,`education`,`phone`,`email`,`intro`,`status`) VALUES
(4,'zhaoliu','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','赵六','星海数据学院','2021003001',2,'人工智能学院','人工智能','2021级','本科','13900000004','zhaoliu@stu.com','关注机器学习、数据挖掘和算法工程。',1),
(5,'sunqi','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','孙七','江南应用科技大学','2022001001',1,'电子信息学院','电子信息工程','2022级','本科','13900000005','sunqi@stu.com','有嵌入式和测试开发项目经验。',1),
(6,'zhouba','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','周八','南城财经科技大学','2020004001',2,'经济管理学院','工商管理','2020级','本科','13900000006','zhouba@stu.com','希望从事产品运营与人力资源方向。',1),
(7,'wuyue','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','吴越','华东数字传媒学院','2021005001',1,'艺术设计学院','视觉传达设计','2021级','本科','13900000007','wuyue@stu.com','擅长UI设计、交互原型与视觉表达。',1),
(8,'qianjiu','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','钱九','江南应用科技大学','2022006001',2,'计算机学院','软件工程','2022级','本科','13900000008','qianjiu@stu.com','准备寻找暑期实习岗位。',1),
(9,'disabled_stu','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','停用学生','江南应用科技大学','2021009999',1,'计算机学院','计算机科学与技术','2021级','本科','13900000999','disabled.stu@stu.com','用于验证禁用账号。',0);

INSERT INTO `enterprise` (`id`,`username`,`password`,`company_name`,`credit_code`,`industry`,`scale`,`nature`,`address`,`city`,`intro`,`welfare`,`contact_name`,`contact_phone`,`email`,`website`,`audit_status`,`status`) VALUES
(4,'alibaba','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','阿里云计算有限公司','913301001234567894','互联网','1000人以上','民营企业','杭州市余杭区文一西路','杭州','阿里云提供云计算、大数据和人工智能服务。','五险一金,年终奖,弹性工作,股票期权','陈HR','0571-26888888','campus@aliyun.com','https://www.aliyun.com',2,1),
(5,'meituan','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','美团科技有限公司','911101051234567895','电子商务','1000人以上','民营企业','北京市朝阳区望京','北京','美团围绕本地生活服务持续创新，岗位覆盖研发、产品、运营和设计。','五险一金,绩效奖金,带薪年假,免费三餐','刘HR','010-55556666','hr@meituan.com','https://www.meituan.com',2,1),
(6,'eduonline','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','启航在线教育科技有限公司','915101001234567896','教育培训','100-499人','民营企业','成都市高新区天府大道','成都','专注高校在线课程、职业教育和就业能力提升。','五险一金,节日福利,带薪年假','何经理','028-66667777','hr@eduonline.com','https://www.eduonline.com',2,1),
(7,'fintech','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','海纳金融科技有限公司','913100001234567897','金融','500-999人','民营企业','上海市陆家嘴金融城','上海','提供智能风控、量化交易和企业金融科技解决方案。','五险一金,年终奖,绩效奖金','赵总监','021-88889999','hr@fintech.com','https://www.fintech.com',1,1),
(8,'greenmaker','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','绿动智能制造有限公司','914201001234567898','制造业','500-999人','民营企业','武汉市东湖高新区','武汉','聚焦智能制造、工业互联网和绿色能源设备。','五险一金,绩效奖金,节日福利','宋经理','027-77778888','hr@greenmaker.com','https://www.greenmaker.com',3,1),
;

INSERT INTO `enterprise_audit` (`id`,`enterprise_id`,`license_no`,`license_img`,`extra_img`,`audit_status`,`audit_remark`,`auditor_id`,`audit_time`,`verify_source`,`verify_source_url`,`verify_time`,`verify_company_name`,`verify_credit_code`,`verify_status`,`verify_result`,`verify_remark`,`verify_snapshot_hash`) VALUES
(1,1,'911100001234567890','/upload/audit/bytedance_license.png','/upload/audit/bytedance_extra.png',2,'营业执照与授权材料完整，认证通过',1,'2026-02-25 10:00:00','国家企业信用信息公示系统','https://www.gsxt.gov.cn/','2026-02-25 09:58:00','字节跳动科技有限公司','911100001234567890','存续',1,'权威来源返回的企业名称、统一社会信用代码与提交信息一致',NULL),
(2,2,'914403001234567891','/upload/audit/tencent_license.png','/upload/audit/tencent_extra.png',2,'企业信息完整，认证通过',1,'2026-02-26 10:30:00','国家企业信用信息公示系统','https://www.gsxt.gov.cn/','2026-02-26 10:25:00','腾讯科技有限公司','914403001234567891','存续',1,'权威来源返回的企业名称、统一社会信用代码与提交信息一致',NULL),
(3,3,'913100001234567892','/upload/audit/newcorp_license.png','/upload/audit/newcorp_extra.png',1,'等待平台审核',NULL,NULL,'国家企业信用信息公示系统','https://www.gsxt.gov.cn/','2026-02-26 11:00:00','灵犀数据科技有限公司','913100001234567892','存续',1,'权威来源返回的企业名称、统一社会信用代码与提交信息一致',NULL),
(4,4,'913301001234567894','/upload/audit/alibaba_license.png','/upload/audit/alibaba_extra.png',2,'云计算企业资质材料完整，认证通过',1,'2026-02-26 14:00:00','国家企业信用信息公示系统','https://www.gsxt.gov.cn/','2026-02-26 13:55:00','阿里巴巴云计算有限公司','913301001234567894','存续',1,'权威来源返回的企业名称、统一社会信用代码与提交信息一致',NULL),
(5,5,'911101051234567895','/upload/audit/meituan_license.png','/upload/audit/meituan_extra.png',2,'营业执照与联系人授权材料完整，认证通过',1,'2026-02-26 15:10:00','国家企业信用信息公示系统','https://www.gsxt.gov.cn/','2026-02-26 15:05:00','美团科技有限公司','911101051234567895','存续',1,'权威来源返回的企业名称、统一社会信用代码与提交信息一致',NULL),
(6,6,'915101001234567896','/upload/audit/eduonline_license.png','/upload/audit/eduonline_extra.png',2,'教育培训企业材料齐全，认证通过',1,'2026-02-26 16:20:00','国家企业信用信息公示系统','https://www.gsxt.gov.cn/','2026-02-26 16:15:00','启航在线教育科技有限公司','915101001234567896','存续',1,'权威来源返回的企业名称、统一社会信用代码与提交信息一致',NULL),
(7,7,'913100001234567897','/upload/audit/fintech_license.png','/upload/audit/fintech_extra.png',1,'新提交认证，等待审核',NULL,NULL,'国家企业信用信息公示系统','https://www.gsxt.gov.cn/','2026-02-27 09:30:00','海纳金融科技有限公司','913100001234567897','存续',1,'权威来源返回的企业名称、统一社会信用代码与提交信息一致',NULL),
(8,8,'914201001234567898','/upload/audit/greenmaker_license.png','/upload/audit/greenmaker_extra.png',3,'授权材料信息与企业资料不一致，请重新上传',3,'2026-02-27 15:00:00','国家企业信用信息公示系统','https://www.gsxt.gov.cn/','2026-02-27 14:40:00','绿动智能制造有限公司','914201001234567898','存续',1,'权威来源返回的企业名称、统一社会信用代码与提交信息一致',NULL),
;

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

INSERT INTO `job_seeker_post` (`id`,`student_id`,`resume_id`,`title`,`expect_post`,`expect_city`,`expect_salary`,`intro`,`status`,`view_count`) VALUES
(1,1,1,'计算机本科求Java后端开发实习','Java后端开发','北京,杭州','8K-12K','熟悉Spring Boot、MySQL和Redis，有校园招聘系统和论坛项目经验，希望参与真实业务后端开发。',1,42),
(2,4,4,'人工智能方向学生寻找算法实习','机器学习算法实习','深圳,广州','10K-15K','关注机器学习、数据挖掘和大模型应用，做过文本分类和推荐系统课程项目。',1,31),
(3,7,7,'视觉传达专业求UI/交互设计岗位','UI设计师','上海,杭州','6K-10K','擅长Figma、PS和移动端界面设计，可提供作品集，期待参与产品设计与交互优化。',1,18),
(4,2,2,'软件工程学生求前端开发实习','前端开发实习生','北京,深圳','7K-11K','熟悉Vue 3、Element Plus和数据可视化，参与过校园招聘系统前端页面开发，期望加入业务前端团队。',1,27),
(5,3,3,'市场营销本科寻找用户运营岗位','用户运营专员','上海,广州','6K-9K','做过校园品牌推广和社群活动策划，擅长活动复盘、用户调研和内容运营。',1,36),
(6,5,5,'电子信息学生求测试开发实习','测试开发实习生','北京,深圳','7K-12K','掌握Python、接口测试和基础嵌入式开发，做过接口自动化测试平台课程项目。',1,22),
(7,6,6,'工商管理学生求产品运营/HR方向','产品运营/人力资源','成都,武汉','5K-8K','有就业服务社群运营经历，熟悉活动组织、用户沟通和招聘流程，期望从事运营或HR方向。',1,19),
(8,8,8,'软件工程大二寻找后端暑期实习','后端开发实习生','南京,苏州','3K-5K','熟悉Java基础、Spring Boot和MySQL，完成过图书管理系统，希望获得暑期实习机会。',1,24);

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

INSERT INTO `favorite_enterprise` (`student_id`,`enterprise_id`) VALUES
(1,5),(1,13),(2,4),(2,6),(3,8),(3,16),(4,7),(5,10),(6,12),(7,14),(8,9);

INSERT INTO `talent_pool` (`enterprise_id`,`student_id`,`resume_id`,`tag`,`remark`) VALUES
(1,2,2,'前端优秀','前端基础扎实，可关注后续岗位'),
(2,1,1,'Java后端','已面试，技术潜力较好'),
(4,4,4,'算法苗子','数学基础好，推荐算法方向'),
(4,1,1,'可培养','Java基础好，适合后端/算法交叉培养'),
(5,7,7,'设计作品集优秀','作品集完整，可约设计评审'),
(6,3,3,'运营潜力','活动策划经验丰富');

INSERT INTO `chat_message` (`from_user_id`,`from_role`,`to_user_id`,`to_role`,`job_id`,`seeker_post_id`,`content`,`is_read`) VALUES
(2,'ENTERPRISE',1,'STUDENT',NULL,1,'你好，我们看到你的求职信息，想了解一下你最近是否方便参加线上沟通？',0),
(1,'STUDENT',2,'ENTERPRISE',1,NULL,'您好，我想咨询腾讯后端开发工程师岗位，对实习时长有要求吗？',1);

-- 更多内容、活动和互动数据
INSERT INTO `banner` (`title`,`image_url`,`link_url`,`sort`,`status`) VALUES
('AI与大数据专场岗位精选','/upload/image/seed/banner-ai-data.jpg','/jobs?keyword=算法',4,1),
('简历门诊与面试辅导开放预约','/upload/image/seed/banner-resume-clinic.jpg','/news/2',5,1),
('校园职业发展服务预览','/upload/image/seed/banner-career-guidance.jpg','',99,0);

INSERT INTO `announcement` (`id`,`category_id`,`title`,`summary`,`content`,`author`,`view_count`,`is_top`,`status`,`publish_time`) VALUES
(9,3,'简历门诊与一对一求职辅导预约开放','针对秋招同学开放简历一对一优化服务。','<p>本周起，校就业指导中心开放简历门诊预约，帮助同学梳理项目亮点与岗位匹配度。</p>','就业指导中心',128,0,1,'2026-03-09 10:00:00'),
(10,2,'校企联合开展Java后端专场招聘','多家企业面向后端开发岗位集中放出需求。','<p>本轮专场招聘覆盖Java后端、测试开发与中间件开发方向，欢迎相关专业同学投递。</p>','就业办',144,0,1,'2026-03-10 10:00:00'),
(11,4,'学院组织毕业生模拟面试活动','邀请企业HR现场点评表达与答辩。','<p>学院将组织模拟面试与群面训练，帮助毕业生提升现场表达和临场反应能力。</p>','校园新闻中心',88,0,1,'2026-03-11 10:00:00'),
(12,1,'基层就业与西部计划政策说明','解读基层就业、三支一扶和西部计划支持。','<p>就业办整理了基层就业支持政策、补贴方向及报名时间，建议有意向的同学关注。</p>','就业办',104,1,1,'2026-03-12 10:00:00');

INSERT INTO `campus_talk` (`id`,`title`,`enterprise_id`,`company_name`,`talk_time`,`location`,`content`,`sign_count`,`status`) VALUES
(7,'字节跳动产品与后端宣讲会',1,'字节跳动科技有限公司','2026-04-20 19:00:00','大学生活动中心A厅','围绕产品协作、后端服务和成长路径展开。',58,1),
(8,'腾讯数据分析与算法分享',2,'腾讯科技有限公司','2026-04-24 19:00:00','信息楼三楼报告厅','聚焦数据平台、推荐系统与校招流程。',52,1),
(9,'海纳金融科技校招说明会',7,'海纳金融科技有限公司','2026-04-26 19:00:00','线上会议室','介绍风控、数据产品与研发岗位。',27,1),
(10,'美团设计与前端联合宣讲',5,'美团科技有限公司','2026-05-02 19:00:00','艺术设计学院报告厅','覆盖设计、前端与产品岗位。',33,1),
(11,'灵犀数据科技AI应用宣讲会',16,'灵犀数据科技有限公司','2026-05-08 19:00:00','信息楼三楼报告厅','聚焦数据中台、AI应用和产品成长路径。',29,1),
(12,'清和校园服务运营宣讲会',17,'清和校园服务有限公司','2026-05-15 19:00:00','大学生活动中心B厅','介绍校园运营、活动执行与客户服务岗位。',21,1),
(13,'星桥零售校园管培生说明会',15,'星桥零售服务有限公司','2026-05-21 19:00:00','经管学院阶梯教室','讲解门店管理、零售数据分析和储备店长培养计划。',34,1);

INSERT INTO `job_fair` (`id`,`title`,`fair_time`,`location`,`host`,`content`,`company_count`,`job_count`,`sign_count`,`status`) VALUES
(7,'2026春季互联网与人工智能双选会','2026-04-20 09:00:00','学校体育馆主馆','校就业指导中心','聚焦前端、后端、算法、测试等技术岗位。',95,2600,540,1),
(8,'教育科技与内容产品专场招聘会','2026-04-26 09:00:00','经管学院大厅','教育学院','面向课程产品、运营、教务与内容岗位。',48,860,240,1),
(9,'设计与新媒体校企对接会','2026-05-06 09:00:00','艺术设计学院展厅','艺术设计学院','覆盖视觉、交互、品牌与新媒体岗位。',36,520,180,1),
(10,'金融科技与数据分析招聘会','2026-05-12 09:00:00','信息楼一楼大厅','校就业指导中心','聚焦数据分析、风控、产品和后端岗位。',62,980,300,1),
(11,'人工智能与数据产品专场招聘会','2026-05-20 09:00:00','信息楼二楼大厅','校就业指导中心','聚焦数据分析、数据产品、AI应用与运维岗位。',40,720,220,1),
(12,'生活服务与校园运营招聘会','2026-05-26 09:00:00','大学生活动中心前广场','后勤与就业办','面向校园服务、活动运营、客户支持等岗位。',28,360,156,1),
(13,'零售管理与新消费专场招聘会','2026-06-02 09:00:00','经管学院一楼大厅','经济管理学院','面向储备店长、零售运营、会员运营和数据分析岗位。',35,480,190,1);

INSERT INTO `activity_sign` (`activity_type`,`activity_id`,`student_id`,`sign_status`) VALUES
(1,1,1,2),(1,1,2,1),(1,2,1,1),(1,3,4,1),(1,3,5,2),(1,4,7,1),(1,5,6,3),
(2,1,1,2),(2,1,3,1),(2,2,2,1),(2,3,4,1),(2,3,5,1),(2,4,6,3),(2,5,7,1);

INSERT INTO `forum_post` (`id`,`student_id`,`author_name`,`title`,`content`,`category`,`view_count`,`like_count`,`comment_count`,`audit_status`,`status`) VALUES
(9,1,'张三','简历完整度提升了，分享下我的修改思路','最近把简历从 68% 补到 92%，主要做了项目量化和成果提炼。','经验分享',74,14,3,1,1),
(10,2,'李四','前端实习面试最常问哪些题','想整理一份面试题清单，欢迎大家补充。','求职交流',83,11,2,1,1),
(11,4,'赵六','算法岗二面复盘','把二面问到的动态规划和机器学习问题记下来，供大家参考。','经验分享',58,16,2,1,1),
(12,5,'孙七','Offer选择纠结中','两家 Offer 都不错，想听听大家怎么做决策。','Offer捷报',91,19,4,1,1);

INSERT INTO `forum_comment` (`post_id`,`student_id`,`author_name`,`content`,`like_count`,`status`) VALUES
(9,2,'李四','量化成果这一步真的很关键，尤其是项目描述。',4,1),
(9,3,'王五','可以把简历关键词和岗位 JD 对齐一下。',2,1),
(10,1,'张三','基础题、浏览器原理、Vue 生态都要准备。',3,1),
(10,4,'赵六','补充一个常见题：前端性能优化怎么做。',2,1),
(11,2,'李四','动态规划题一定要结合题型分类整理。',2,1),
(11,5,'孙七','机器学习基础可以先过一遍概念再刷题。',3,1),
(12,1,'张三','建议从成长性、城市、团队和薪资四个维度看。',5,1),
(12,3,'王五','别忘了看转正概率和项目匹配度。',4,1);

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
;

-- 让展示统计与明细保持一致
UPDATE `job_post` jp SET `apply_count` = (SELECT COUNT(*) FROM `job_apply` ja WHERE ja.`job_id` = jp.`id` AND ja.`deleted` = 0);
UPDATE `forum_post` fp SET `comment_count` = (SELECT COUNT(*) FROM `forum_comment` fc WHERE fc.`post_id` = fp.`id` AND fc.`deleted` = 0 AND fc.`status` = 1);
UPDATE `campus_talk` ct SET `sign_count` = GREATEST(ct.`sign_count`, (SELECT COUNT(*) FROM `activity_sign` s WHERE s.`activity_type` = 1 AND s.`activity_id` = ct.`id` AND s.`deleted` = 0 AND s.`sign_status` <> 3));
UPDATE `job_fair` jf SET `sign_count` = GREATEST(jf.`sign_count`, (SELECT COUNT(*) FROM `activity_sign` s WHERE s.`activity_type` = 2 AND s.`activity_id` = jf.`id` AND s.`deleted` = 0 AND s.`sign_status` <> 3));

-- 样例头像与企业 Logo
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

-- 首页补充样例数据：用于宽屏门户展示，保留原有待审核/驳回/停用样例不变
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

-- 热门岗位补充：加入实习、服务、客服、零售、新媒体等非技术岗位，让门户首页更丰满
INSERT INTO `job_category` (`id`,`name`,`parent_id`,`sort`) VALUES
(27,'客户服务',3,3),(28,'生活服务',3,4),(29,'新媒体运营',2,6),(30,'门店零售',3,5);

INSERT INTO `sys_dict` (`dict_type`,`dict_label`,`dict_value`,`sort`) VALUES
('industry','生活服务','生活服务',10),('industry','酒店餐饮','酒店餐饮',11),('industry','零售连锁','零售连锁',12),
('city','天津','天津',13),('city','厦门','厦门',14),('city','青岛','青岛',15),
('welfare','包吃','包吃',11),('welfare','住宿补贴','住宿补贴',12),('welfare','晋升培训','晋升培训',13);

INSERT INTO `enterprise` (`id`,`username`,`password`,`company_name`,`credit_code`,`industry`,`scale`,`nature`,`address`,`city`,`logo`,`intro`,`welfare`,`contact_name`,`contact_phone`,`email`,`website`,`audit_status`,`status`) VALUES
(13,'orangecafe','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','青橙餐饮管理有限公司','913101001234567903','酒店餐饮','500-999人','民营企业','上海市徐汇区龙华中路','上海','/upload/image/seed/enterprise-company-logo-v2.png','经营校园周边轻食、咖啡和连锁餐饮门店，提供管培生与兼职岗位。','包吃,节日福利,晋升培训','林店长','021-66112233','hr@orangecafe.com','https://www.orangecafe.com',2,1),
(14,'haiyuehotel','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','海悦酒店集团有限公司','913502001234567904','生活服务','1000人以上','民营企业','厦门市思明区环岛路','厦门','/upload/image/seed/enterprise-fintech-logo-v2.png','覆盖酒店前厅、会务接待、客户服务和数字化运营岗位。','五险一金,住宿补贴,带薪年假,晋升培训','陈经理','0592-88776655','campus@haiyuehotel.com','https://www.haiyuehotel.com',2,1),
(15,'starretail','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','星桥零售服务有限公司','913702001234567905','零售连锁','1000人以上','民营企业','青岛市市南区香港中路','青岛','/upload/image/seed/enterprise-eduonline-logo-v2.png','提供便利零售、会员运营、门店管理和线上客服岗位。','五险一金,绩效奖金,节日福利,晋升培训','赵主管','0532-88996677','join@starretail.com','https://www.starretail.com',2,1);

INSERT INTO `job_post` (`id`,`enterprise_id`,`category_id`,`title`,`job_type`,`recruit_num`,`city`,`salary_min`,`salary_max`,`education`,`major_require`,`experience`,`duty`,`requirement`,`welfare`,`audit_status`,`audit_remark`,`status`,`view_count`,`apply_count`,`publish_time`) VALUES
(29,13,28,'校园咖啡店服务员',2,12,'上海',3,5,'不限','不限','在校生','负责点单、出品协助、门店卫生和顾客引导。','沟通自然，能接受排班，每周到岗3天以上。','包吃,节日福利,晋升培训',1,NULL,1,188,12,'2026-03-29 09:00:00'),
(30,13,28,'餐饮门店管培生',1,8,'上海',5,8,'大专','不限','应届','轮岗学习门店运营、排班管理、成本控制和服务标准。','责任心强，愿意从一线岗位学习门店管理。','五险一金,包吃,晋升培训',1,NULL,1,176,10,'2026-03-30 09:00:00'),
(31,13,29,'新媒体运营实习生',2,5,'上海',3,5,'本科','新闻传播/市场营销/不限','在校生','负责短视频脚本、图文内容、账号互动和活动复盘。','熟悉常见内容平台，有拍摄剪辑或文案经验优先。','实习津贴,节日福利,弹性工作',1,NULL,1,168,9,'2026-03-31 09:00:00'),
(32,14,27,'前台接待实习生',2,10,'厦门',3,4,'大专','旅游管理/酒店管理/不限','在校生','负责入住接待、咨询答复、会务引导和客户信息录入。','形象良好，普通话标准，服务意识强。','实习津贴,住宿补贴,晋升培训',1,NULL,1,160,8,'2026-04-01 09:00:00'),
(33,14,27,'客服专员',1,8,'厦门',5,8,'大专','不限','应届','负责客户咨询、投诉记录、服务回访和工单跟进。','表达清晰，情绪稳定，能熟练使用办公软件。','五险一金,住宿补贴,带薪年假',1,NULL,1,152,7,'2026-04-02 09:00:00'),
(34,14,11,'会务运营助理',1,4,'厦门',5,8,'本科','会展/旅游/工商管理相关','应届','协助会场布置、嘉宾接待、物料统筹和现场执行。','执行力强，能适应活动期间弹性排班。','五险一金,绩效奖金,晋升培训',1,NULL,1,146,6,'2026-04-03 09:00:00'),
(35,15,30,'便利店储备店长',1,10,'青岛',6,9,'大专','不限','应届','负责门店商品陈列、库存盘点、班次管理和销售达成。','愿意从门店一线成长，数据意识和责任心强。','五险一金,绩效奖金,晋升培训',1,NULL,1,182,11,'2026-04-04 09:00:00'),
(36,15,30,'门店兼职导购',2,15,'青岛',2,4,'不限','不限','在校生','负责顾客接待、商品补货、收银协助和活动推广。','时间稳定，服务态度好，每周可到岗3天以上。','实习津贴,节日福利,晋升培训',1,NULL,1,170,10,'2026-04-05 09:00:00'),
(37,15,27,'线上客服实习生',2,8,'青岛',3,4,'大专','不限','在校生','负责线上咨询回复、订单问题记录和客户满意度回访。','打字熟练，耐心细致，能接受早晚班轮换。','实习津贴,弹性工作,节日福利',1,NULL,1,156,8,'2026-04-06 09:00:00'),
(38,15,16,'零售数据分析助理',1,4,'青岛',6,10,'本科','统计学/市场营销/计算机相关','应届','负责门店销售报表、会员数据分析和运营建议输出。','熟悉Excel和SQL基础，有数据分析项目经验优先。','五险一金,绩效奖金,带薪年假',1,NULL,1,148,7,'2026-04-07 09:00:00');

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

INSERT INTO `student` (`id`,`username`,`password`,`real_name`,`school`,`student_no`,`gender`,`college`,`major`,`grade`,`education`,`phone`,`email`,`status`)
SELECT * FROM (
  SELECT 10 AS `id`,'chenjie' AS `username`,'$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO' AS `password`,'陈洁' AS `real_name`,'江南应用科技大学' AS `school`,'2021007001' AS `student_no`,2 AS `gender`,'软件学院' AS `college`,'软件工程' AS `major`,'2021级' AS `grade`,'本科' AS `education`,'13900000010' AS `phone`,'chenjie@stu.com' AS `email`,1 AS `status`
  UNION ALL SELECT 11,'dengyi','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','邓一','星海数据学院','2021008001',1,'人工智能学院','人工智能','2021级','本科','13900000011','dengyi@stu.com',1
  UNION ALL SELECT 12,'linyue','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','林悦','华东数字传媒学院','2021009001',2,'艺术设计学院','视觉传达设计','2021级','本科','13900000012','linyue@stu.com',1
  UNION ALL SELECT 13,'xuhao','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','许昊','江南应用科技大学','2022001002',1,'电子信息学院','电子信息工程','2022级','本科','13900000013','xuhao@stu.com',1
  UNION ALL SELECT 14,'hanqing','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','韩晴','南城财经科技大学','2020006001',2,'经济管理学院','工商管理','2020级','本科','13900000014','hanqing@stu.com',1
  UNION ALL SELECT 15,'yuchen','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','于晨','南城财经科技大学','2021002002',1,'经济管理学院','市场营销','2021级','本科','13900000015','yuchen@stu.com',1
  UNION ALL SELECT 16,'wangjue','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','王觉','江南应用科技大学','2021006002',1,'计算机学院','网络工程','2021级','本科','13900000016','wangjue@stu.com',1
  UNION ALL SELECT 17,'zhouxin','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','周欣','南城财经科技大学','2021003003',2,'经济管理学院','信息管理与信息系统','2021级','本科','13900000017','zhouxin@stu.com',1
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

INSERT INTO `student` (`id`,`username`,`password`,`real_name`,`school`,`student_no`,`gender`,`college`,`major`,`grade`,`education`,`phone`,`email`,`status`)
SELECT * FROM (
  SELECT 18 AS `id`,'liuyang' AS `username`,'$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO' AS `password`,'刘洋' AS `real_name`,'江南应用科技大学' AS `school`,'2021007018' AS `student_no`,1 AS `gender`,'计算机学院' AS `college`,'计算机科学与技术' AS `major`,'2021级' AS `grade`,'本科' AS `education`,'13900000018' AS `phone`,'liuyang@stu.com' AS `email`,1 AS `status`
  UNION ALL SELECT 19,'fangmin','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','方敏','江南应用科技大学','2021007019',2,'软件学院','软件工程','2021级','本科','13900000019','fangmin@stu.com',1
  UNION ALL SELECT 20,'heyu','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','何宇','星海数据学院','2021007020',1,'人工智能学院','人工智能','2021级','本科','13900000020','heyu@stu.com',1
  UNION ALL SELECT 21,'songke','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','宋可','华东数字传媒学院','2021007021',2,'艺术设计学院','视觉传达设计','2021级','本科','13900000021','songke@stu.com',1
  UNION ALL SELECT 22,'tangrui','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','唐睿','南城财经科技大学','2021007022',1,'经济管理学院','市场营销','2021级','本科','13900000022','tangrui@stu.com',1
  UNION ALL SELECT 23,'guojia','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','郭佳','江南应用科技大学','2021007023',2,'电子信息学院','电子信息工程','2021级','本科','13900000023','guojia@stu.com',1
  UNION ALL SELECT 24,'mazhe','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','马哲','江南应用科技大学','2021007024',1,'计算机学院','网络工程','2021级','本科','13900000024','mazhe@stu.com',1
  UNION ALL SELECT 25,'xiaoran','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','肖然','南城财经科技大学','2021007025',2,'经济管理学院','信息管理与信息系统','2021级','本科','13900000025','xiaoran@stu.com',1
  UNION ALL SELECT 26,'lvqing','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','吕晴','南城财经科技大学','2021007026',2,'经济管理学院','工商管理','2021级','本科','13900000026','lvqing@stu.com',1
  UNION ALL SELECT 27,'penghao','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','彭浩','江南应用科技大学','2021007027',1,'软件学院','软件工程','2021级','本科','13900000027','penghao@stu.com',1
  UNION ALL SELECT 28,'caixin','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','蔡欣','华东数字传媒学院','2021007028',2,'艺术设计学院','视觉传达设计','2021级','本科','13900000028','caixin@stu.com',1
  UNION ALL SELECT 29,'yuanbo','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','袁博','星海数据学院','2021007029',1,'人工智能学院','人工智能','2021级','本科','13900000029','yuanbo@stu.com',1
  UNION ALL SELECT 30,'huzhe','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','胡哲','江南应用科技大学','2021007030',1,'计算机学院','计算机科学与技术','2021级','本科','13900000030','huzhe@stu.com',1
  UNION ALL SELECT 31,'yinxin','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','尹欣','南城财经科技大学','2021007031',2,'经济管理学院','市场营销','2021级','本科','13900000031','yinxin@stu.com',1
  UNION ALL SELECT 32,'luohan','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','罗瀚','江南应用科技大学','2021007032',1,'电子信息学院','电子信息工程','2021级','本科','13900000032','luohan@stu.com',1
  UNION ALL SELECT 33,'shenyi','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','沈奕','江南应用科技大学','2021007033',2,'软件学院','软件工程','2021级','本科','13900000033','shenyi@stu.com',1
  UNION ALL SELECT 34,'zhuoyu','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','卓雨','南城财经科技大学','2021007034',2,'经济管理学院','信息管理与信息系统','2021级','本科','13900000034','zhuoyu@stu.com',1
  UNION ALL SELECT 35,'xiechen','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','谢晨','华东数字传媒学院','2021007035',1,'艺术设计学院','视觉传达设计','2021级','本科','13900000035','xiechen@stu.com',1
  UNION ALL SELECT 36,'duanlei','$2a$10$5cl.E33gmXaCawXN8CQIi.htvEQ0FWNhkr3jv8QiixVQmIqmvITSO','段磊','江南应用科技大学','2021007036',1,'计算机学院','网络工程','2021级','本科','13900000036','duanlei@stu.com',1
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

-- ============================================================================
-- 脚本结束
-- ============================================================================


-- 多 HR 模型兼容迁移：旧企业账号迁入 enterprise_hr，并回填历史业务数据负责人。
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
