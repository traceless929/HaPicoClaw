# PicoClaw Gateway Add-on

这个目录包含 Home Assistant add-on `picoclaw_gateway` 的首版实现。

## 这个 add-on 做什么

它将 `PicoClaw` 的 `gateway` 常驻模式封装为 HAOS add-on，优先面向 `aarch64` 设备，适合在 `x88pro20` 这类 `RK3566` 盒子上验证轻量化智能家居 Agent 的运行模型。

## 当前能力

- 随仓库携带并解压 `PicoClaw` 官方 `aarch64` 二进制 tar 包
- 随仓库携带 `mcp-proxy` wheel，避免构建时再从外部 Python 包源下载
- 通过 add-on 选项生成 `config.json`
- 支持直接粘贴完整 `PicoClaw config.json`
- 使用 `/data/picoclaw` 持久化配置与工作目录
- 以 `gateway` 服务形态常驻运行
- 使用宿主机网络直接监听本机 `18790`
- 支持通过触发文件请求 `gateway` 热重启
- 提供基于 Home Assistant Ingress 的控制页与内置 Terminal
- 控制页支持检测 `mcp-proxy` 启动状态，并手动启动、停止和重启
- 提供基础 Web Search 配置映射
- 支持通过 `mcp-proxy` 桥接 Home Assistant 官方 `mcp_server`
- 在 workspace 中自动生成 `AGENTS.md`、`TOOLS.md`、`USER.md` 与默认 Home Assistant skill
- 支持 HA API / Supervisor API 检测、`mcp-proxy` 进程管理与 Ingress 控制页诊断

## 当前限制

- 首版只支持 `aarch64`
- 只映射了部分 PicoClaw 高级配置项，复杂场景仍建议使用 `raw_config`
- 当前 Home Assistant 集成依赖官方 `mcp_server` 暴露的工具集合与实体范围
- 还没有把 MQTT / Webhook 能力深度接入
- 还没有做完整的图形配置向导和发布流程

## 一键安装入口

安装 Home Assistant 官方 MCP：

[![Open your Home Assistant and add the MCP integration](https://my.home-assistant.io/badges/config_flow_start.svg)](https://my.home-assistant.io/redirect/config_flow_start?domain=mcp_server)

把本仓库加入 Home Assistant add-on 仓库：

[![Open your Home Assistant and add this add-on repository](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Ftraceless929%2FHaPicoClaw)

国内网络环境如果访问 GitHub 较慢，也可以使用这个镜像仓库入口：

[![Open your Home Assistant and add the CN mirror add-on repository](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgh-proxy.org%2Fhttps%3A%2F%2Fgithub.com%2Ftraceless929%2FHaPicoClaw.git)

## 快速预览

### 官方 MCP 安装入口

![Home Assistant 集成安装入口](assets/quickstart/02-add-integration-search-mcp.png)

### Add-on 配置页

![PicoClaw Gateway 配置页](assets/quickstart/06b-addon-config-ha-mcp.png)

### 控制页与运行状态

![PicoClaw Control 与 mcp-proxy 状态](assets/quickstart/07-control-page-and-status.png)

## MCP 调用流程

这个 add-on 里的 Home Assistant 集成采用的是“官方 MCP + 本地桥接”的方式，而不是继续维护自研 MCP 协议层。

涉及三个角色：

- [Home Assistant `mcp_server`](https://www.home-assistant.io/integrations/mcp_server/)：官方 MCP 服务，提供 `/api/mcp`
- [`mcp-proxy`](https://github.com/sparfenyuk/mcp-proxy)：把远程 `Streamable HTTP` MCP 桥接成本地 `stdio`
- [`PicoClaw`](https://github.com/sipeed/picoclaw)：从 `tools.mcp` 配置加载本地 MCP server 并注册工具

运行时流程如下：

```text
Home Assistant official mcp_server
        ->
  /api/mcp (Streamable HTTP)
        ->
      mcp-proxy
        ->
    local stdio MCP process
        ->
      PicoClaw gateway
        ->
  registered tools: mcp_homeassistant_*
```

更具体地说：

1. add-on 启动时会生成 PicoClaw 的 `config.json`
2. 其中 `tools.mcp.servers.homeassistant.command` 指向 `/usr/bin/ha-mcp-proxy-launcher`
3. PicoClaw 在需要该 MCP server 时，会自动拉起这个本地进程
4. `ha-mcp-proxy-launcher` 再调用 `mcp-proxy --transport=streamablehttp --stateless`
5. `mcp-proxy` 连接到 Home Assistant 官方 `/api/mcp`
6. Home Assistant 按官方 MCP 集成中“已暴露实体”的范围返回工具能力和执行结果

这意味着：

- PicoClaw 侧看到的是本地 `stdio` MCP server
- Home Assistant 侧暴露的是官方 `Streamable HTTP` MCP
- 权限控制主要由 Home Assistant 官方 MCP 集成负责
- 你在 PicoClaw 里实际看到的工具名会以 `mcp_homeassistant_` 开头，但具体后缀取决于当前 HA 暴露的工具集合

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
- `rootfs/usr/bin/ha-mcp-proxy-manager`：`mcp-proxy` 状态检测与手动启停脚本
- `rootfs/usr/bin/ha-api-selftest`：Home Assistant API 连通性检测
- `rootfs/usr/bin/supervisor-api-selftest`：Supervisor API 连通性检测
- `rootfs/usr/bin/picoclaw-control-panel`：控制页与诊断接口
- `DOCS.md`：面向用户的安装说明
- `QUICKSTART.zh-Hans.md`：中文快速开始
- `QUICKSTART.en.md`：English quick start
- `CHANGELOG.md`：版本记录
- `translations/`：配置项名称与说明
