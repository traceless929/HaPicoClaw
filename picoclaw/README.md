# PicoClaw Gateway Add-on

这个目录包含 Home Assistant add-on `picoclaw_gateway` 的首版实现。

## 这个 add-on 做什么

它将 `PicoClaw` 的 `gateway` 常驻模式封装为 HAOS add-on，优先面向 `aarch64` 设备，适合在 `x88pro20` 这类 `RK3566` 盒子上验证轻量化智能家居 Agent 的运行模型。

## 当前能力

- 随仓库携带并解压 `PicoClaw` 官方 `aarch64` 二进制 tar 包
- 通过 add-on 选项生成 `config.json`
- 支持直接粘贴完整 `PicoClaw config.json`
- 使用 `/data/picoclaw` 持久化配置与工作目录
- 以 `gateway` 服务形态常驻运行
- 使用宿主机网络直接监听本机 `18790`
- 支持通过触发文件请求 `gateway` 热重启
- 提供基于 Home Assistant Ingress 的控制页与内置 Terminal
- 提供基础 Web Search 配置映射
- 支持通过 `mcp-proxy` 桥接 Home Assistant 官方 `mcp_server`
- 在 workspace 中自动生成 `AGENTS.md`、`TOOLS.md`、`USER.md` 与默认 Home Assistant skill
- 支持 MCP 自检、HA API / Supervisor API 检测与 Ingress 控制页诊断

## 当前限制

- 首版只支持 `aarch64`
- 只映射了部分 PicoClaw 高级配置项，复杂场景仍建议使用 `raw_config`
- 当前 Home Assistant 集成依赖官方 `mcp_server` 暴露的工具集合与实体范围
- 还没有把 MQTT / Webhook 能力深度接入
- 还没有做完整的图形配置向导和发布流程

## 目录结构

- `config.yaml`：add-on 元数据与配置 schema
- `build.yaml`：构建参数
- `Dockerfile`：运行镜像定义
- `rootfs/etc/cont-init.d/00-config.sh`：启动前生成 PicoClaw 配置
- `rootfs/etc/cont-init.d/10-workspace-files.sh`：初始化默认 workspace 文件
- `rootfs/etc/services.d/picoclaw/run`：PicoClaw 服务入口
- `rootfs/etc/services.d/webui/run`：Ingress 控制页服务入口
- `rootfs/etc/services.d/terminal/run`：内置终端服务入口
- `rootfs/usr/bin/ha-mcp-proxy-launcher`：官方 Home Assistant MCP 的本地桥接启动脚本
- `rootfs/usr/bin/ha-mcp-selftest`：MCP 自检脚本
- `rootfs/usr/bin/ha-api-selftest`：Home Assistant API 连通性检测
- `rootfs/usr/bin/supervisor-api-selftest`：Supervisor API 连通性检测
- `rootfs/usr/bin/picoclaw-control-panel`：控制页与诊断接口
- `DOCS.md`：面向用户的安装说明
- `CHANGELOG.md`：版本记录
- `translations/`：配置项名称与说明
