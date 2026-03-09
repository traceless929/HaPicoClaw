# Changelog

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
