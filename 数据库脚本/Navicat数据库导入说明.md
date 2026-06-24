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

如密码不同，请在导入后修改 [backend/src/main/resources/application.yml](../backend/src/main/resources/application.yml)。

## 2. SQL 文件位置

数据库脚本位于：

```text
docs/sql/campus_recruitment.sql
```

该脚本包含：

- 自动创建数据库 `campus_recruitment`
- 33 张业务表
- 角色、字典、岗位类别初始化数据
- 管理员、学生、企业测试账号
- 首页轮播图、公告、宣讲会、招聘会、职位、简历、投递、面试、Offer、论坛等演示数据

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
6. 打开文件 [docs/sql/campus_recruitment.sql](sql/campus_recruitment.sql)，复制全部 SQL 内容。
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

## 5. 默认测试账号

所有测试账号密码均为：`123456`

| 角色 | 账号 | 说明 |
|---|---|---|
| 管理员 | admin | 超级管理员 |
| 管理员 | jiuyeban | 就业办老师 |
| 学生 | student | 张三 |
| 学生 | lisi | 李四 |
| 企业 | company | 字节跳动科技有限公司 |
| 企业 | tencent | 腾讯科技有限公司 |
| 企业 | newcorp | 待审核企业 |

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
3. [backend/src/main/resources/application.yml](../backend/src/main/resources/application.yml) 中账号密码是否正确。
4. MySQL 端口是否为 3306。
