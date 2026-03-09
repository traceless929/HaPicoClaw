# Changelog

## 0.1.0-beta.8

- 将 Ingress 首页升级为 `PicoClaw Console`，支持直接编辑运行中的 `config.json`
- 保留终端入口，并支持在控制台页面内嵌显示 terminal
- 新增 `保存`、`保存并重启 Gateway` 等操作按钮

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
