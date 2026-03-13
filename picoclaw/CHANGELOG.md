# Changelog

## 0.1.1-beta.1

- 升级随仓库携带的 `picoclaw` 二进制到 `0.2.2`

## 0.1.1

- 发布首个稳定版 Home Assistant add-on，基于官方 `mcp_server`、`mcp-proxy` 和 PicoClaw 的组合方案
- 移除旧版 `MCP 自检` 脚本、控制页入口和相关配置项，控制页聚焦为 HA API / Supervisor API 检测与 `mcp-proxy` 管理
- 补充 Home Assistant 官方 `mcp_server`、`mcp-proxy` 与 PicoClaw 的 MCP 调用原理说明
- 新增中英双语快速开始文档，并加入配置页、控制页和最终效果截图
- 增加 `My Home Assistant` 一键安装入口，支持官方 MCP 集成、GitHub 原始仓库和国内镜像仓库

## 0.1.0-beta.23

- 移除旧版 `MCP 自检` 脚本、控制页入口和相关配置项，控制页聚焦为 HA API / Supervisor API 检测与 `mcp-proxy` 管理
- 补充 Home Assistant 官方 `mcp_server`、`mcp-proxy` 与 PicoClaw 的 MCP 调用原理说明
- 新增中英双语快速开始文档，并加入控制页、配置页和最终效果截图
- 增加 `My Home Assistant` 一键安装入口，支持官方 MCP 集成、GitHub 原始仓库和国内镜像仓库

## 0.1.0-beta.22

- 在 `PicoClaw Control` 中新增 `mcp-proxy` 运行状态检测
- 支持从控制页手动启动、停止和重启 `mcp-proxy`，便于排障和进程管理
- 新增 `ha-mcp-proxy-manager` 管理脚本，用于汇总活动进程状态并执行显式启停

## 0.1.0-beta.21

- 将 `mcp-proxy` 改为随仓库携带的 wheel 包安装，减少构建时对外部 Python 包源的依赖
- 镜像构建时改用独立 Python venv 安装本地 wheel，绕过 Alpine / Home Assistant 基础镜像上的 `PEP 668` 限制

## 0.1.0-beta.20

- 改为通过 `mcp-proxy` 对接 Home Assistant 官方 `mcp_server`，由 PicoClaw 继续以本地 `stdio` MCP 进程方式消费
- 新增 `ha_mcp_url`、`ha_mcp_use_supervisor_token` 和 `ha_mcp_token` 配置项，并兼容旧版 `ha_url` / `ha_token` 配置回退
- MCP 自检、HA API 检测、默认 workspace 提示词与用户文档同步切换到官方 MCP 模型，不再依赖固定自研工具名

## 0.1.0-beta.19

- 修复控制页代理 `ttyd` Terminal 时仍可能请求到压缩资源、导致 iframe 内终端页面显示乱码的问题
- 代理上游时显式请求未压缩响应，并避免 HTTP 客户端自动补充 `Accept-Encoding`

## 0.1.0-beta.18

- 新增 `ha_request_timeout` 配置项，并增强 MCP 自检与 HA 工具调用日志的耗时、阶段和错误信息
- 收紧默认 `AGENTS.md` 与 Home Assistant skill 的触发条件，简单寒暄和在线测试消息不再进入 HA 工具链
- 启动时会自动迁移旧版不包含闲聊保护规则的 `AGENTS.md` 和 `SKILL.md`

## 0.1.0-beta.17

- 修复控制页反向代理 Terminal 时对压缩响应的 header/body 处理不一致，减少 HA Ingress 下的 gzip 解码错误
- 代理上游 `ttyd` 时不再转发 `Accept-Encoding`，并避免透传 `Content-Encoding`
- 新增 `ha_request_timeout` 配置项，并增强 MCP 自检与 HA 工具调用日志的耗时和错误信息

## 0.1.0-beta.16

- 修复 Ingress 控制页下诊断接口仍使用绝对路径，导致在 HA Ingress 中返回非 JSON 响应的问题
- 修复内置 Terminal 在控制页内使用绝对路径和错误代理路径导致无法显示的问题
- 终端服务显式启用 `ttyd --base-path /terminal`，并由控制页按完整路径代理

## 0.1.0-beta.15

- 新增 Home Assistant Ingress 控制页，内置 MCP 自检、Home Assistant API 检测、Supervisor API 检测和 Terminal
- add-on 额外启用 `hassio_api` 权限，便于检测 Supervisor API 可用性
- 将原有 Terminal 调整到内部端口 `17682`，由控制页统一代理和嵌入
- 增加 `ha-api-selftest`、`supervisor-api-selftest` 与 `picoclaw-control-panel` 脚本

## 0.1.0-beta.14

- 调整默认 workspace 规则文件和 Home Assistant skill，引导 agent 使用 PicoClaw 实际注册的 `mcp_homeassistant_*` 工具名
- 启动时会自动迁移旧版引用 `ha_*` 工具名或缺少 skill 元数据的 `AGENTS.md`、`TOOLS.md` 和 `SKILL.md`
- 自动配置模式下会兼容合并已有 `config.json`，减少升级时对非托管配置的覆盖
- gateway 启动前新增 HA MCP 自检日志，便于确认 `initialize`、`tools/list` 和实际注册工具名
- 新增 Ingress 控制页，支持 MCP 自检、Home Assistant API 检测、Supervisor API 检测和内置 Terminal
- add-on 额外启用 `hassio_api` 权限，便于检测 Supervisor API

## 0.1.0-beta.13

- 新增 Home Assistant API 相关 add-on 配置项，并启用 `homeassistant_api` 权限
- 自动为 PicoClaw 生成 `tools.mcp` 与 `tools.skills`，默认接入本地 `ha-mcp-server`
- 新增基于 stdio 的 `ha_get_state`、`ha_list_entities`、`ha_call_service`、`ha_get_history` MCP 工具
- 首次启动时自动补齐 workspace 下的 `AGENTS.md`、`TOOLS.md`、`USER.md` 和默认 Home Assistant skill
- 增加 Home Assistant MCP 审计日志路径 `/data/picoclaw/logs/homeassistant-mcp-audit.log`

## 0.1.0-beta.12

- 升级随仓库携带的 `picoclaw` 二进制到 `0.2.1`
- 切换到 `picoclaw 0.2.1` 的配置路径语义，主配置固定为 `/data/picoclaw/.picoclaw/config.json`
- 移除对 `/data/picoclaw/config.json` 兼容副本的持续维护

## 0.1.0-beta.11

- 新增 QQ 频道基础配置项，并自动拼接到运行时 `config.json`
- 新增飞书频道基础配置项，并自动拼接到运行时 `config.json`
- 优化配置页字段顺序，按核心配置、频道配置、Web Search 和高级配置分组展示
- Ingress Terminal 改用内部端口 `17681`，避免与 HAOS 预设 `7681` 冲突

## 0.1.0-beta.10

- 在配置页新增 Discord 频道基础字段
- 将 Discord 配置拼接到运行时 `config.json` 的 `channels.discord`
- 支持从配置页直接配置 Discord Token、允许用户、提及响应和推理频道

## 0.1.0-beta.9

- 将 Ingress 入口调整回单一 `PicoClaw Terminal`
- 移除配置编辑器首页与 `nginx/python` 相关组件
- 保留 Web Terminal、`use_raw_config` 和 gateway 热重启能力

## 0.1.0-beta.6

- 新增基于 Home Assistant Ingress 的 Web Terminal
- 在容器内提供带 PicoClaw 环境变量的交互式 shell
- 支持直接粘贴完整 `PicoClaw config.json`
- 保留 `restart-picoclaw-gateway` 等调试辅助能力

## 0.1.0-beta.5

- 修复 `picoclaw v0.2.0` 实际读取配置路径与 add-on 写入路径不一致的问题
- 改为主写入 `/data/picoclaw/.picoclaw/config.json`，并兼容保留 `/data/picoclaw/config.json`
- 解决生成配置正确但 `gateway` 仍读取不到默认模型配置的情况

## 0.1.0-beta.4

- 在启动前配置生成脚本中增加脱敏后的 `config.json` 日志输出
- 便于直接从 Home Assistant add-on 日志中确认最终模型配置结构
- 用于继续排查 `gateway` 启动阶段的模型解析问题

## 0.1.0-beta.3

- 修复生成的 `config.json` 默认模型字段，改为 `agents.defaults.model_name`
- 解决 `picoclaw gateway` 启动时报 `model "" not found in model_list` 的问题
- 便于在 Home Assistant 中升级到包含该修复的新测试版

## 0.1.0-beta.2

- 改为随仓库携带官方 `aarch64` 二进制 tar 包，避免构建时依赖外部下载
- 调整 add-on `Dockerfile`，在镜像构建阶段直接解压并安装 `picoclaw`
- 同步更新仓库文档，说明当前二进制打包方式

## 0.1.0-beta.1

- 发布首个 GitHub 测试版，便于在盒子上拉取仓库后进行部署验证
- 补充仓库级校验工作流和 issue 模板，方便后续问题回收
- 增加 `MIT` 许可证声明与 README 许可证徽章

## 0.1.0

- 初始化 `HaPicoClaw` 仓库
- 新增 `PicoClaw Gateway` Home Assistant add-on 骨架
- 支持在启动时生成基础 `PicoClaw` 配置文件
- 支持以 `gateway` 方式运行 `PicoClaw`
- 首版目标平台限定为 `aarch64`
