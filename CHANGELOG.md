# Changelog

## [2.0.0] - 2026-07-02

### Added
- DNS-01 证书验证方式（支持 Cloudflare / DNSPod / 阿里云 / HE.net / GoDaddy / 华为云 / AWS Route53 / Google Cloud）
- 交互式证书验证方式选择（HTTP-01 / DNS-01），适配 NAT / 无 80 端口场景
- DNS API 配置管理菜单
- 脚本自更新功能（一键拉取最新代码）
- 安装时根据系统 locale 自动切换中英文提示

### Fixed
- 修复 `select_cert_mode_interactive` 中 `warn`/`error` 输出到 stdout 导致 DNS-01 选择后误触发 HTTP-01 自检
- 修复证书选择菜单提示被 `$(...)` 捕获导致返回值污染
- 修复 Alpine 系统下证书模式菜单编码问题
- 修复 Alpine 安装 Nginx 后 `CONF_DIR` 未重新检测的问题
- 修复未安装 Nginx 时 WebSocket map 检查报错

### Changed
- 版本号后增加代码修改日期

---

## [1.7.0] - 2026-06

### Added
- 证书申请前 HTTP-01 自检（DNS 解析 / 80 端口监听 / challenge 本地命中 / 域名回环可达）
- 证书自检分级提示（硬失败 / 软失败），支持确认后继续或切换 DNS-01
- 实时信息二级菜单与流量统计视图
- 站点健康检查（上游可达性探测、TLS 证书校验、域名匹配）
- 外部反代高级模式：Emby HTTP/HTTPS 推流分离、LilyEmby 方案（访问/推流分离 + sub_filter）
- 多 Emby 推流节点支持
- 外部反代 Stream 模式（禁用缓冲 / 大文件支持）
- 配置导入功能（导入已有 Nginx 配置文件纳入管理）
- IPv6 listen 支持 + IPv6 上游 Host 解析
- Alpine Linux / OpenWrt 兼容（BusyBox 适配、包管理器检测、acme.sh 自动安装）
- 全局 WebSocket map 注入（`connection_upgrade` 映射）并超时优化
- 手动编辑保护（检测非模板生成的配置，阻止重建覆盖）

### Fixed
- 修复流量统计日志未命中时 `set -e` 导致脚本异常退出
- 修复外部反代 HTTPS 启用时上游 Host 丢失与 SNI 缺失导致 502
- 修复同端口多域名外部反代 HTTPS 端口复用配置冲突
- 修复启用 HTTPS 时误报成功的问题
- 修复 `host_header` 变量在 heredoc 中被重复转义导致 Host 头异常
- 修复 `modify_conf` 编辑后流程逻辑问题（HTTPS 确认 / 停用提示）
- 修复配置导入时重复导入已管理文件的问题
- 修复 WebSocket map 未被所有配置写入路径注入的问题
- 修复 Stream 代理超时重复写入
- 修复 Nginx 卸载后缓存路径残留

### Changed
- 安装 Nginx 后自动停用 `default.conf` 避免冲突
- 统一交互确认提示为 `[y/N]`
- 外部反代模式菜单文案简化

---

## [1.5.0] - 2026-05

### Added
- 外部 URL 反代（通过 Nginx 反代远程上游，非本地端口）
- 外部反代模式选择菜单（标准 / Stream / Emby 系列）
- 配置文件命名改为域名+端口，支持同域多端口独立配置
- 证书列表交互式操作菜单（重申 / 启停续期 / 删除）
- 添加配置时优先复用已有证书并提示启用 HTTPS
- 证书列表改为编号选择方式
- 配置列表编辑功能（修改监听端口、后端/上游 URL、域名）
- 卸载菜单增加 Acme 卸载

### Fixed
- 证书启用状态检测兼容旧配置格式
- 证书申请输入不合法时不再退出脚本
- 启用 HTTPS 时继承原监听端口，修复非标端口握手失败
- 添加 IP 地址跳过证书自动申请流程
- 证书申请 429 频率限制识别与可重试时间提示
- ACME challenge 路径自动保留，避免被反代拦截
- 添加配置时允许端口复用，由 `nginx -t` 最终校验

### Changed
- 合并功能 2/3 为"配置管理"二级菜单
- 合并安装/升级为"安装升级 Nginx"
- 实时信息刷新间隔调整为 5 秒
- 精简菜单文案命名

---

## [1.0.0] - 2026-04

### Added
- Nginx 安装 / 升级（自动检测版本，支持官方源编译）
- 反向代理配置管理（添加 / 删除 / 启停）
- 基于 acme.sh 的证书自动申请（HTTP-01）与自动 HTTPS 启用
- 一键安装脚本（install.sh），安装后自动进入 nx 菜单
- 卸载子菜单（Nginx + acme.sh 完整卸载）
- 交互式菜单系统，操作失败不退出
