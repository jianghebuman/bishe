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

- 企业注册、登录、修改密码；企业账号采用“公司主体 + HR 登录账号”模型
- 主管 HR 维护企业资料、Logo、企业认证申请和状态查看
- 主管 HR 管理本企业多个 HR 账号，可新增、编辑、启用/禁用、重置密码、调整主管/普通 HR
- 职位发布、编辑、上下架、刷新
- 普通 HR 可发布岗位并处理自己负责的岗位、投递、面试、Offer、人才库
- 简历管理、面试邀请、面试评价、Offer 管理
- 人才库和 ECharts 招聘数据看板

### 管理员端

- 学生、企业、管理员用户管理
- 企业 HR 管理：按企业查看 HR 列表，新增、编辑、启用/禁用、重置密码、调整主管/普通 HR
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

该脚本会创建 `campus_recruitment` 数据库，并初始化 37 张业务表、角色/权限、字典、测试账号和演示数据。

### 数据库同步说明

- 数据库初始化脚本以 [数据库脚本/campus_recruitment.sql](数据库脚本/campus_recruitment.sql) 为准。
- 2026-06-30 已同步企业多 HR 模型：新增 `enterprise_hr` 表，并为 `job_post`、`job_apply`、`interview_notice`、`interview_feedback`、`offer_record`、`talent_pool` 增加 `hr_id`。
- 当前数据库口径为 37 张表、434 个字段；演示数据约包含 64 家企业、77 个企业 HR、72 名学生、80 个岗位、101 条投递、18 条面试通知、20 条 Offer、54 条人才库记录。
- 本地数据库在项目运行后会产生业务数据漂移，`system_notice`、`operation_log`、`job_apply` 等表记录数可能高于初始化脚本。如需恢复到初始演示数据，请重新导入 SQL 脚本。

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

如果 `8080` 端口已被占用，可临时执行 `npm run dev -- --port 5173`，再访问 `http://localhost:5173`。

## 默认测试账号

所有账号初始密码均为：`123456`

| 角色 | 账号 | 说明 |
|---|---|---|
| 管理员 | admin | 系统超级管理员 |
| 管理员 | jiuyeban | 就业办老师 |
| 学生 | student | 张三 |
| 学生 | lisi | 李四 |
| 企业主管 HR | company | 字节跳动科技有限公司 |
| 企业普通 HR | bytedance-recruit-a | 字节跳动后端招聘 |
| 企业主管 HR | bytedance-campus | 字节跳动校招主管 |
| 企业主管 HR | tencent | 腾讯科技有限公司 |
| 企业普通 HR | tencent-product | 腾讯产品招聘 |
| 企业普通 HR | aliyun-data | 阿里云数据招聘 |
| 企业主管 HR | newcorp | 待审核企业 |

企业登录时 `userId` 表示 HR 账号 ID，`enterpriseId` 表示公司主体 ID；主管 HR 可查看本企业全部招聘数据，普通 HR 仅能查看和处理自己负责的数据。

## 生产部署

部署模板和说明见：

[deploy/README.md](deploy/README.md)

如果服务器内存较小，推荐改用“本地构建前端、服务器仅部署产物”的方式：

[deploy/本地构建前端-服务器部署流程.md](deploy/本地构建前端-服务器部署流程.md)

已提供：

- `application-prod.yml`：生产环境变量配置
- `deploy/.env.example`：服务器环境变量模板
- `deploy/nginx/campus-recruitment.conf`：Nginx 示例配置
- `deploy/linux/start-campus-recruitment.sh`：Linux 后端启动脚本

## 说明

本系统不接入真实短信、真实支付、真实 AI 或第三方招聘渠道。通知、面试、Offer 等流程均采用站内消息与模拟业务数据实现，适合毕业设计演示与论文功能验证。
