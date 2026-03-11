# HaPicoClaw

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

这个仓库用于承载基于 `PicoClaw` 的 Home Assistant add-on。

当前包含一个面向 `aarch64` 设备的 Home Assistant add-on，目标设备是 `x88pro20 / RK3566` 这类盒子，优先验证：

- PicoClaw 在 HAOS add-on 中的常驻运行方式
- 通过 `/data` 持久化配置和工作目录
- 使用 PicoClaw `gateway` 形态承载后续智能家居自动化能力

## 最新发布

最新版本：[`v0.1.0-beta.23`](https://github.com/traceless929/HaPicoClaw/releases/tag/v0.1.0-beta.23)

这一版已经补齐了首个可用的 Home Assistant 集成闭环：

- 新增 Home Assistant API 相关 add-on 配置项
- 自动为 PicoClaw 生成原生 `tools.mcp` 与 `tools.skills`
- 通过 `mcp-proxy` 对接 Home Assistant 官方 `mcp_server`，并由 PicoClaw 以本地 MCP 进程方式消费
- 随仓库携带 `mcp-proxy` wheel，减少构建时对外部 Python 包源的依赖
- 首次启动时自动生成默认 `AGENTS.md`、`TOOLS.md`、`USER.md` 和 `skills/home-assistant/SKILL.md`
- 补充了 Home Assistant 配置、实体查找和排错文档
- 增强官方 Home Assistant MCP 接入兼容逻辑，并开始提供 Ingress 控制页方向
- 新增 Ingress 控制页，可直接执行 HA API、Supervisor API 检测并管理 `mcp-proxy`
- 修复控制页在 HA Ingress 下的相对路径与内置 Terminal 显示问题
- 修复控制页代理 Terminal 时的 gzip/header 兼容问题
- 增强 HA 工具链日志与超时配置，并收紧闲聊消息的 HA skill 触发条件

## 当前能力

- 以 Home Assistant add-on 方式常驻运行 `PicoClaw gateway`
- 通过 `/data/picoclaw` 持久化 `config.json`、workspace 和日志
- 提供基于 Home Assistant Ingress 的控制页与 Terminal
- 支持基础 Web Search 配置映射
- 支持通过 Home Assistant 官方 `mcp_server` 提供 MCP 工具能力
- 支持默认 workspace 规则文件与 skill 模板初始化

## 一键开始

先把官方 Home Assistant MCP 集成加入到你的 HA：

[![Open your Home Assistant and add the MCP integration](https://my.home-assistant.io/badges/config_flow_start.svg)](https://my.home-assistant.io/redirect/config_flow_start?domain=mcp_server)

再把本仓库加入 Home Assistant add-on 仓库：

[![Open your Home Assistant and add this add-on repository](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Ftraceless929%2FHaPicoClaw)

如果你在国内网络环境下访问 GitHub 较慢，也可以使用国内友好镜像仓库入口：

[![Open your Home Assistant and add the CN mirror add-on repository](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgh-proxy.org%2Fhttps%3A%2F%2Fgithub.com%2Ftraceless929%2FHaPicoClaw.git)

如果按钮没有正常跳转，也可以手动按 `picoclaw/QUICKSTART.zh-Hans.md` 或 `picoclaw/QUICKSTART.en.md` 里的步骤安装。

## 界面预览

下面这张图展示了 add-on 控制页中的 `mcp-proxy` 状态、诊断区域和内置 Terminal：

![PicoClaw Control 预览](picoclaw/assets/quickstart/07-control-page-and-status.png)

## MCP 原理

这个项目不是自己重新实现一套 Home Assistant MCP 协议，而是把三层能力串起来：

1. Home Assistant 官方 [`mcp_server`](https://www.home-assistant.io/integrations/mcp_server/) 负责暴露 `/api/mcp`，并由 HA 自己控制哪些实体会暴露给 MCP。
2. [`mcp-proxy`](https://github.com/sparfenyuk/mcp-proxy) 负责把官方的 `Streamable HTTP` MCP 端点桥接成 PicoClaw 更容易消费的本地 `stdio` MCP 进程。
3. [`PicoClaw`](https://github.com/sipeed/picoclaw) 继续按原生 `tools.mcp` 配置加载本地 MCP server，并把可见工具注册为 `mcp_homeassistant_*` 这类工具名。

调用链路可以简单理解为：

```text
Home Assistant mcp_server (/api/mcp)
        ->
      mcp-proxy
        ->
PicoClaw tools.mcp server
        ->
  PicoClaw Agent / Gateway
```

当用户在 PicoClaw 侧发起家庭控制请求时，实际流程通常是：

1. PicoClaw Agent 根据当前会话里可见的 `mcp_homeassistant_*` 工具做选择。
2. 对应工具调用会通过 `mcp-proxy` 转发到 Home Assistant 官方 MCP。
3. Home Assistant 再根据你在官方 MCP 集成里暴露的实体和权限决定是否允许访问。
4. 结果返回给 PicoClaw，再由 PicoClaw 输出给聊天渠道或控制页。

这套设计的好处是：

- 权限边界尽量交给 Home Assistant 官方 MCP 管理
- PicoClaw 侧仍保持轻量的本地 `stdio` 集成方式
- add-on 不需要长期维护一套自研 Home Assistant MCP 协议实现

## 目录结构

- `repository.yaml`：Home Assistant add-on 仓库元数据
- `picoclaw/`：PicoClaw add-on 实现

## 快速入口

- add-on 目录说明：[`picoclaw/README.md`](picoclaw/README.md)
- 安装与配置文档：[`picoclaw/DOCS.md`](picoclaw/DOCS.md)
- 快速开始中文：[`picoclaw/QUICKSTART.zh-Hans.md`](picoclaw/QUICKSTART.zh-Hans.md)
- Quick Start English: [`picoclaw/QUICKSTART.en.md`](picoclaw/QUICKSTART.en.md)
- 版本记录：[`picoclaw/CHANGELOG.md`](picoclaw/CHANGELOG.md)
- 最新发布页：[GitHub Releases](https://github.com/traceless929/HaPicoClaw/releases)

## 后续方向

- 更完整的 PicoClaw 配置映射
- Home Assistant 实时事件订阅和更丰富的工具能力
- 与 MQTT / Webhook 的联动方案
- 多架构支持和版本发布流程
