# Changelog

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
