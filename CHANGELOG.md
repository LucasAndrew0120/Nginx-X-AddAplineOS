# Changelog

Based on [Xiuyixx/Nginx-X](https://github.com/Xiuyixx/Nginx-X) (upstream).

Only fork-specific additions and changes are documented below.

---

## [2.0.0] - 2026-07-02

### Added
- 脚本自更新功能（主菜单一键拉取最新代码）

### Fixed
- 修复 `select_cert_mode_interactive` 中 `warn`/`error` 输出到 stdout 被 `$()` 捕获，导致选择 DNS-01 后误触发 HTTP-01 自检
- 证书选择菜单提示改为输出到 stderr，避免返回值污染

### Changed
- 版本号后增加代码修改日期 `(YYYY-MM-DD)`
- 新增 CHANGELOG.md

---

## [1.8.0] - 2026-06

### Added
- **Alpine Linux / OpenWrt 兼容**：BusyBox 适配、包管理器自动检测、Nginx 安装后 `CONF_DIR` 重新检测
- **DNS-01 证书验证**：支持 Cloudflare / DNSPod / 阿里云 / HE.net / GoDaddy / 华为云 / AWS Route53 / Google Cloud
- **DNS API 配置管理菜单**：独立管理 DNS 服务商 Token
- **交互式证书验证方式选择**：HTTP-01 / DNS-01 二选一，适配 NAT / 无 80 端口场景
- OpenSSL 依赖自动安装 + acme.sh 引导安装
- 安装时根据系统 locale 自动切换中英文提示

### Fixed
- 证书模式菜单编码问题（Alpine 下改用 ASCII）
- 未安装 Nginx 时 WebSocket map 检查不再报错
- WebSocket map 注入时 grep 转义修正
- 克隆仓库时指定 `alpine-support` 分支

### Changed
- REPO_URL 指向 fork 仓库 `LucasAndrew0120/Nginx-X-AddAplineOS`
