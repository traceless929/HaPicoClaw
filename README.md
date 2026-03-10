# HaPicoClaw

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

这个仓库用于承载基于 `PicoClaw` 的 Home Assistant add-on。

当前包含一个面向 `aarch64` 设备的 Home Assistant add-on，目标设备是 `x88pro20 / RK3566` 这类盒子，优先验证：

- PicoClaw 在 HAOS add-on 中的常驻运行方式
- 通过 `/data` 持久化配置和工作目录
- 使用 PicoClaw `gateway` 形态承载后续智能家居自动化能力

## 最新发布

最新版本：[`v0.1.0-beta.13`](https://github.com/traceless929/HaPicoClaw/releases/tag/v0.1.0-beta.13)

这一版已经补齐了首个可用的 Home Assistant 集成闭环：

- 新增 Home Assistant API 相关 add-on 配置项
- 自动为 PicoClaw 生成原生 `tools.mcp` 与 `tools.skills`
- 内置本地 `ha-mcp-server`，提供 `ha_get_state`、`ha_list_entities`、`ha_call_service`、`ha_get_history`
- 首次启动时自动生成默认 `AGENTS.md`、`TOOLS.md`、`USER.md` 和 `skills/home-assistant/SKILL.md`
- 补充了 Home Assistant 配置、实体查找和排错文档

## 当前能力

- 以 Home Assistant add-on 方式常驻运行 `PicoClaw gateway`
- 通过 `/data/picoclaw` 持久化 `config.json`、workspace 和日志
- 提供基于 Home Assistant Ingress 的 Web Terminal
- 支持基础 Web Search 配置映射
- 支持通过 Home Assistant API 直连的 MCP 工具能力
- 支持默认 workspace 规则文件与 skill 模板初始化

## 目录结构

- `repository.yaml`：Home Assistant add-on 仓库元数据
- `picoclaw/`：PicoClaw add-on 实现

## 快速入口

- add-on 目录说明：[`picoclaw/README.md`](picoclaw/README.md)
- 安装与配置文档：[`picoclaw/DOCS.md`](picoclaw/DOCS.md)
- 版本记录：[`picoclaw/CHANGELOG.md`](picoclaw/CHANGELOG.md)
- 最新发布页：[GitHub Releases](https://github.com/traceless929/HaPicoClaw/releases)

## 后续方向

- 更完整的 PicoClaw 配置映射
- Home Assistant 实时事件订阅和更丰富的工具能力
- 与 MQTT / Webhook 的联动方案
- 多架构支持和版本发布流程
