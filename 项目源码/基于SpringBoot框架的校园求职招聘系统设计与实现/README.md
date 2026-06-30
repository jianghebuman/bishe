# 基于 Spring Boot 框架的校园求职招聘系统设计与实现

本项目是一个适合毕业设计、论文和答辩展示的校园求职招聘系统，采用前后端分离架构：

- 后端：Spring Boot 2.7 + MyBatis-Plus + MySQL + JWT
- 前端：Vue 3 + Vite + Element Plus + Pinia + Vue Router + Axios + ECharts
- 数据库：MySQL，脚本可通过 Navicat Premium 17 导入

## 主要角色

1. 管理员 / 就业办管理员
2. 企业 HR
3. 学生 / 求职者

## 已实现功能概览

### 学生端

- 学生注册、登录、退出、修改密码
- 个人信息维护、头像上传
- 求职意向维护
- 在线简历管理：基本信息、教育经历、项目经历、实习经历、技能证书、自我评价、完整度计算
- 附件简历上传、预览/下载、删除
- 职位搜索、职位详情、收藏职位、取消收藏
- 一键投递简历、投递记录查看与撤回
- 面试通知查看、确认参加、拒绝面试
- Offer 查看、接受、拒绝
- 求职社区：发帖、评论、点赞、删除自己的帖子
- 消息中心

### 企业 HR 端

- 企业注册、登录、修改密码
- 企业资料维护、Logo 上传
- 企业认证申请、认证状态查看
- 职位发布、编辑、删除、上架/下架、刷新
- 收到的简历管理、状态流转
- 面试邀请、面试信息维护、面试评价
- Offer 发送、撤回、学生确认状态查看
- 人才库管理、候选人检索
- 企业消息中心
- ECharts 数据看板：职位数、投递数、面试数、Offer 数、投递趋势、招聘漏斗

### 管理员端

- 管理员登录、修改密码
- 学生用户管理：新增、编辑、禁用、重置密码
- 企业用户管理：禁用/启用、认证审核
- 岗位审核：通过、驳回、下架
- 岗位类别、数据字典管理
- 公告资讯、轮播图管理
- 宣讲会、招聘会管理
- 论坛帖子审核、删除评论/帖子
- 留言反馈查看与回复
- 系统日志查看
- 数据导出：学生、企业、岗位、投递记录 Excel
- ECharts 数据统计：学生/企业/岗位/投递总数、专业投递统计、岗位类别统计、企业活跃度、招聘漏斗、面试通过率、Offer 接受率

## 项目结构

```text
.
├── backend/                      # Spring Boot 后端
│   ├── pom.xml
│   └── src/main
│       ├── java/com/campus
│       │   ├── common/           # 统一返回、JWT、异常、文件上传、用户上下文
│       │   ├── config/           # Web、拦截器、MyBatis-Plus 配置
│       │   ├── controller/       # 三端与公共接口
│       │   ├── dto/              # 请求 DTO
│       │   ├── entity/           # 36 张表实体
│       │   ├── mapper/           # MyBatis-Plus Mapper
│       │   ├── service/          # Service 接口
│       │   └── service/impl/     # Service 实现
│       └── resources/application.yml
├── frontend/                     # Vue3 前端
│   ├── package.json
│   ├── vite.config.js
│   └── src
│       ├── api/                  # axios 接口封装
│       ├── components/           # 通用组件
│       ├── layout/               # 门户/学生/企业/管理端布局
│       ├── router/               # 路由守卫
│       ├── store/                # Pinia 用户状态
│       └── views/                # 页面
└── ../../数据库脚本/campus_recruitment.sql
```

## 环境要求

- JDK 8 或以上
- Maven 3.6+
- Node.js 16+（建议 18+）
- MySQL 5.7+ / 8.0+
- Navicat Premium 17（可选，用于导入 SQL）

## 数据库配置

默认数据库连接配置在 [backend/src/main/resources/application.yml](backend/src/main/resources/application.yml)：

```yaml
spring:
  datasource:
    url: jdbc:mysql://127.0.0.1:3306/campus_recruitment?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true
    username: root
    password: "12345678"
```

如你的 MySQL 密码不同，请修改该文件。

## 数据库导入

SQL 文件位置：

[../../数据库脚本/campus_recruitment.sql](../../数据库脚本/campus_recruitment.sql)

可用 Navicat Premium 17 执行该脚本，脚本会自动创建数据库 `campus_recruitment`，并初始化 36 张业务表、字典、测试账号和演示数据。

当前数据库连接默认指向 `campus_recruitment`。如果本地数据库已经跑过一段时间，`operation_log`、`system_notice` 等业务表的记录数可能会高于初始化脚本，这是正常的运行数据漂移；如需恢复初始演示数据，重新导入该脚本即可。

## 启动后端

```bash
cd backend
mvn spring-boot:run
```

后端默认地址：

```text
http://localhost:8081/api
```

## 启动前端

```bash
cd frontend
npm install
npm run dev
```

前端默认地址：

```text
http://localhost:8080
```

Vite 已配置代理：前端 `/api` 会代理到 `http://localhost:8081/api`。

## 默认测试账号

所有账号初始密码均为：`123456`

| 角色 | 账号 | 密码 | 说明 |
|---|---|---|---|
| 管理员 | admin | 123456 | 系统超级管理员 |
| 管理员 | jiuyeban | 123456 | 就业办老师 |
| 学生 | student | 123456 | 张三 |
| 学生 | lisi | 123456 | 李四 |
| 企业 HR | company | 123456 | 字节跳动科技有限公司 |
| 企业 HR | tencent | 123456 | 腾讯科技有限公司 |
| 企业 HR | newcorp | 123456 | 待审核企业 |

## 常用访问路径

- 门户首页：http://localhost:8080/
- 登录页：http://localhost:8080/login
- 学生中心：http://localhost:8080/student
- 企业中心：http://localhost:8080/enterprise
- 管理后台：http://localhost:8080/admin

## 说明

本系统不接入真实短信、真实支付、真实 AI 或第三方招聘渠道。通知、面试、Offer 等流程均采用站内消息与模拟业务数据实现，适合毕业设计演示与论文功能验证。
