# Navicat Premium 17 数据库导入说明

本文档说明如何使用 Navicat Premium 17 导入校园求职招聘系统数据库脚本。

## 1. 准备环境

请确认本机已安装并启动 MySQL 服务，推荐版本：

- MySQL 5.7+
- MySQL 8.0+

本项目默认连接信息：

| 配置项 | 默认值 |
|---|---|
| 主机 | 127.0.0.1 |
| 端口 | 3306 |
| 用户名 | root |
| 密码 | 12345678 |
| 数据库 | campus_recruitment |

如密码不同，请在导入后修改 [application.yml](../项目源码/基于SpringBoot框架的校园求职招聘系统设计与实现/backend/src/main/resources/application.yml)。

## 2. SQL 文件位置

数据库脚本位于：

```text
数据库脚本/campus_recruitment.sql
```

该脚本包含：

- 自动创建数据库 `campus_recruitment`
- 36 张业务表（共 425 个字段）
- 角色、字典、岗位类别初始化数据
- 管理员、学生、企业主管 HR、企业普通 HR 测试账号
- 公告、宣讲会、招聘会、职位、简历、投递、面试、Offer、人才库、论坛等演示数据
- 企业多 HR 模型：`enterprise` 为公司主体，`enterprise_hr` 为 HR 登录账号；岗位、投递、面试、Offer、人才库均记录 `hr_id`

## 3. 使用 Navicat Premium 17 导入步骤

1. 打开 Navicat Premium 17。
2. 点击左上角「连接」→ 选择「MySQL」。
3. 填写连接信息：
   - 主机：`127.0.0.1`
   - 端口：`3306`
   - 用户名：`root`
   - 密码：`12345678`（如不同请填你的实际密码）
4. 点击「测试连接」，提示成功后点击「确定」。
5. 在左侧连接上右键，选择「新建查询」。
6. 打开文件 [campus_recruitment.sql](./campus_recruitment.sql)，复制全部 SQL 内容。
7. 粘贴到 Navicat 查询窗口。
8. 点击「运行」或按 F6 执行。
9. 执行完成后，左侧刷新连接，应出现数据库 `campus_recruitment`。
10. 展开数据库，确认表结构与初始化数据已生成。

## 4. 验证导入结果

导入成功后，可以执行：

```sql
USE campus_recruitment;
SHOW TABLES;
SELECT * FROM admin_user;
SELECT * FROM student;
SELECT * FROM enterprise;
```

应能看到管理员、学生、企业测试账号。

也可以继续执行：

```sql
SELECT COUNT(*) AS table_count
FROM information_schema.tables
WHERE table_schema = 'campus_recruitment';
```

正常情况下应返回 `37`。

## 5. 默认测试账号

所有测试账号密码均为：`123456`

| 角色 | 账号 | 说明 |
|---|---|---|
| 管理员 | admin | 超级管理员 |
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

主展示企业已配置多 HR，例如字节跳动 4 个 HR、腾讯 4 个 HR、阿里云 4 个 HR、美团 3 个 HR、星火 AI 3 个 HR。所有账号默认密码均为 `123456`。

## 6. 常见问题

### 6.1 导入乱码

请确认 SQL 文件使用 UTF-8 编码，并在脚本开头保留：

```sql
SET NAMES utf8mb4;
```

### 6.2 数据库已存在

脚本会执行：

```sql
CREATE DATABASE IF NOT EXISTS campus_recruitment;
```

如果数据库已存在且你想重新导入，可先在 Navicat 中删除该数据库，或手动执行：

```sql
DROP DATABASE campus_recruitment;
```

然后重新运行 SQL 脚本。

### 6.3 后端连接失败

请检查：

1. MySQL 服务是否启动。
2. 数据库是否已导入。
3. [application.yml](../项目源码/基于SpringBoot框架的校园求职招聘系统设计与实现/backend/src/main/resources/application.yml) 中账号密码是否正确。
4. MySQL 端口是否为 3306。

## 7. 脚本同步说明

- 仓库中的权威初始化脚本为 [campus_recruitment.sql](./campus_recruitment.sql)。
- 2026-06-30 已同步企业收藏表和企业多 HR 模型；2026-07-02 已移除轮播图功能，当前初始化脚本为 36 张表、425 个字段。
- 同日已将 `enterprise_hr` 表补入本机 `campus_recruitment` 数据库，并为 `job_post`、`job_apply`、`interview_notice`、`interview_feedback`、`offer_record`、`talent_pool` 增加 `hr_id`。
- 当前演示数据约包含 64 家企业、77 个企业 HR、72 名学生、80 个岗位、101 条投递、18 条面试通知、20 条 Offer、54 条人才库记录。
- 本地数据库在系统运行后会新增业务数据，因此 `operation_log`、`system_notice`、`activity_sign`、`job_apply` 等表的记录数可能高于初始化脚本，这是正常现象；若需要回到初始演示数据，请重新导入脚本。
