# PR 信息（合并到上游 Xiuyixx/Nginx-X）

## 标题

```
feat: 支持 Alpine/OpenWrt、DNS-01 证书验证、多语言安装、脚本自更新
```

## 正文

### 概述

本 PR 为 Nginx-X 新增以下能力：Alpine Linux / OpenWrt 跨发行版兼容、DNS-01 证书验证、交互式证书验证方式选择、安装器多语言支持、脚本一键自更新。

### 改动详情

#### 跨发行版支持
- **Alpine Linux / OpenWrt 兼容**：BusyBox 适配（`grep`/`sed`/`awk` 替代方案）、包管理器自动检测（apt / yum / dnf / apk / opkg）
- Nginx 安装后自动检测配置目录：Alpine 使用 `http.d`，其他系统使用 `conf.d`
- Nginx 安装流程中自动安装 OpenSSL 依赖并引导安装 acme.sh

#### 证书管理
- **DNS-01 证书验证**：支持 Cloudflare、DNSPod、阿里云、HE.net、GoDaddy、华为云、AWS Route53、Google Cloud 共 8 家 DNS 服务商
- **交互式验证方式选择**：每次申请证书时可选择 HTTP-01 或 DNS-01，适配 NAT / 无 80 端口场景
- DNS API 配置管理菜单（Token 持久化存储）
- HTTP-01 自检失败时，若已配置 DNS API，自动提示切换为 DNS-01 方式

#### 安装器
- 多语言支持：根据系统 locale 自动切换中/英文安装提示
- 证书模式菜单改用 ASCII 字符，避免 Alpine 下编码异常

#### 脚本自更新
- 主菜单新增"更新脚本"选项，一键 `git pull` 拉取最新代码并覆盖安装
- 非 Git 仓库目录自动提示确认后重装

#### 修复
- 修复 `select_cert_mode_interactive` 中 `warn`/`error` 输出到 stdout 被 `$()` 捕获，导致选择 DNS-01 后仍触发 HTTP-01 自检的问题
- 修复未安装 Nginx 时 WebSocket map 检查报错
- 修复 BusyBox 下 `grep` 转义兼容性问题

#### 其他
- 版本号升至 2.0.0（附代码修改日期）
- 新增 CHANGELOG.md

### 测试

- `bash -n nx.sh` 通过
- `bash -n install.sh` 通过
- 已在 Alpine Linux 3.19 和 Ubuntu 22.04 上手动测试通过
