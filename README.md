# 基于 Spring Boot 框架的校园求职招聘系统设计与实现

本项目是一个适合毕业设计、论文和答辩展示的校园求职招聘系统，采用前后端分离架构。

- 后端：Spring Boot 2.7 + MyBatis-Plus + MySQL + JWT
- 前端：Vue 3 + Vite + Element Plus + Pinia + Vue Router + Axios + ECharts
- 数据库：MySQL，脚本可通过 Navicat Premium 17 或 MySQL 命令行导入

## 项目目录

```text
.
├── deploy/                      # 服务器部署模板和说明
├── 数据库脚本/                  # MySQL 初始化脚本
├── 论文图表/                    # 论文/答辩用图表
└── 项目源码/
    └── 基于SpringBoot框架的校园求职招聘系统设计与实现/
        ├── backend/             # Spring Boot 后端
        ├── frontend/            # Vue3 前端
        ├── scripts/             # 本地启动/停止脚本
        ├── upload/              # SQL 演示数据引用的素材
        └── README.md            # 更详细的项目运行说明
```

## 功能概览

### 学生端

- 学生注册、登录、退出、修改密码
- 个人信息、头像、求职意向维护
- 在线简历、附件简历、投递记录、面试通知、Offer 管理
- 职位搜索、职位详情、收藏职位、一键投递
- 求职社区、消息中心

### 企业 HR 端

- 企业注册、登录、资料维护、Logo 上传
- 企业认证申请和状态查看
- 职位发布、编辑、上下架、刷新
- 简历管理、面试邀请、面试评价、Offer 管理
- 人才库和 ECharts 招聘数据看板

### 管理员端

- 学生、企业、管理员用户管理
- 企业认证审核、岗位审核、岗位类别和数据字典管理
- 公告资讯、轮播图、宣讲会、招聘会管理
- 论坛审核、留言反馈、系统日志、数据导出
- ECharts 平台数据统计

## 本地运行

详细说明见：

[项目源码/基于SpringBoot框架的校园求职招聘系统设计与实现/README.md](项目源码/基于SpringBoot框架的校园求职招聘系统设计与实现/README.md)

### 环境要求

- JDK 8 或以上
- Maven 3.6+
- Node.js 16+，建议 18+
- MySQL 5.7+ / 8.0+

### 数据库导入

SQL 文件：

[数据库脚本/campus_recruitment.sql](数据库脚本/campus_recruitment.sql)

该脚本会创建 `campus_recruitment` 数据库，并初始化 36 张业务表、角色/权限、字典、测试账号和演示数据。

### 数据库同步说明

- 数据库初始化脚本以 [数据库脚本/campus_recruitment.sql](数据库脚本/campus_recruitment.sql) 为准。
- `git rev-parse HEAD:"数据库脚本/campus_recruitment.sql"` 与 `git rev-parse origin/main:"数据库脚本/campus_recruitment.sql"` 当前一致，说明仓库本地脚本与 GitHub `main` 分支脚本一致。
- 2026-06-30 已将企业收藏表同步到本机 `campus_recruitment`，当前初始化脚本为 36 张表、416 个字段。
- 本地数据库在项目运行后会产生业务数据漂移，当前与初始化脚本存在记录数差异的表主要有：`activity_sign`、`student`、`system_notice`、`operation_log`。如需恢复到初始演示数据，请重新导入 SQL 脚本。

### 启动后端

```bash
cd 项目源码/基于SpringBoot框架的校园求职招聘系统设计与实现/backend
mvn spring-boot:run
```

后端默认地址：

```text
http://localhost:8081/api
```

### 启动前端

```bash
cd 项目源码/基于SpringBoot框架的校园求职招聘系统设计与实现/frontend
npm install
npm run dev
```

前端默认地址：

```text
http://localhost:8080
```

## 默认测试账号

所有账号初始密码均为：`123456`

| 角色 | 账号 | 说明 |
|---|---|---|
| 管理员 | admin | 系统超级管理员 |
| 管理员 | jiuyeban | 就业办老师 |
| 学生 | student | 张三 |
| 学生 | lisi | 李四 |
| 企业 HR | company | 字节跳动科技有限公司 |
| 企业 HR | tencent | 腾讯科技有限公司 |
| 企业 HR | newcorp | 待审核企业 |

## 生产部署

部署模板和说明见：

[deploy/README.md](deploy/README.md)

已提供：

- `application-prod.yml`：生产环境变量配置
- `deploy/.env.example`：服务器环境变量模板
- `deploy/nginx/campus-recruitment.conf`：Nginx 示例配置
- `deploy/linux/start-campus-recruitment.sh`：Linux 后端启动脚本

## 说明

本系统不接入真实短信、真实支付、真实 AI 或第三方招聘渠道。通知、面试、Offer 等流程均采用站内消息与模拟业务数据实现，适合毕业设计演示与论文功能验证。
