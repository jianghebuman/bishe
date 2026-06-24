# Linux 部署说明

本目录只保存部署模板和说明，不会被 Spring Boot 或 Vue 自动加载。生产配置文件是后端的 `backend/src/main/resources/application-prod.yml`，只有启动后端时指定 `--spring.profiles.active=prod` 才会生效。

## 目录建议

服务器上建议使用如下目录：

```text
/opt/campus-recruitment/
├── backend/
│   └── campus-recruitment.jar
├── frontend/
│   └── dist/
├── upload/
├── logs/
├── run/
└── .env
```

## 环境准备

安装 JDK 8+、Maven、Node.js 16+、MySQL、Nginx。

创建数据库和用户后，导入仓库中的 SQL：

```bash
mysql -uroot -p < 数据库脚本/campus_recruitment.sql
```

## 构建后端

```bash
cd 项目源码/基于SpringBoot框架的校园求职招聘系统设计与实现/backend
mvn clean package -DskipTests
```

构建产物：

```text
target/campus-recruitment.jar
```

复制到服务器：

```bash
mkdir -p /opt/campus-recruitment/backend
cp target/campus-recruitment.jar /opt/campus-recruitment/backend/
```

## 构建前端

```bash
cd 项目源码/基于SpringBoot框架的校园求职招聘系统设计与实现/frontend
npm install
npm run build
```

复制到服务器：

```bash
mkdir -p /opt/campus-recruitment/frontend
cp -r dist /opt/campus-recruitment/frontend/
```

## 配置环境变量

复制示例文件：

```bash
cp deploy/.env.example /opt/campus-recruitment/.env
```

编辑 `/opt/campus-recruitment/.env`，至少修改：

```bash
DB_USERNAME=你的数据库用户
DB_PASSWORD=你的数据库密码
JWT_SECRET=一串足够长的随机密钥
```

## 启动后端

复制并授权启动脚本：

```bash
mkdir -p /opt/campus-recruitment/scripts
cp deploy/linux/start-campus-recruitment.sh /opt/campus-recruitment/scripts/
chmod +x /opt/campus-recruitment/scripts/start-campus-recruitment.sh
```

启动：

```bash
/opt/campus-recruitment/scripts/start-campus-recruitment.sh
```

后端默认监听：

```text
http://127.0.0.1:8081/api
```

## 配置 Nginx

复制示例配置：

```bash
cp deploy/nginx/campus-recruitment.conf /etc/nginx/conf.d/campus-recruitment.conf
```

编辑 `server_name` 为你的域名，然后检查并重载：

```bash
nginx -t
systemctl reload nginx
```

Nginx 会：

- 托管前端 `frontend/dist`
- 把 `/api/` 转发到 Spring Boot
- 直接访问 `/upload/` 下的上传文件

## 说明

`deploy/` 目录只是模板目录。放在仓库里不会影响本地开发，也不会改变线上行为；只有复制配置、设置环境变量、执行脚本后才会参与部署。
