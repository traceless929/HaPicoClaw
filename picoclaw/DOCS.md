# PicoClaw Gateway

## 简介

这个 add-on 会在 Home Assistant OS 中运行 `PicoClaw gateway`，用于验证轻量化 AI Agent 在智能家居盒子上的常驻部署方式。

## 安装前说明

- 当前仅支持 `aarch64`
- 默认使用 `18790/tcp` 作为 PicoClaw Gateway 端口
- 需要你自行准备 LLM API Key，或者接入本地兼容接口

## 配置项

- `model_name`：PicoClaw 内部使用的模型别名
- `model`：实际模型标识，例如 `openai/gpt-5.2`、`zhipu/glm-4.7`、`ollama/llama3`
- `api_key`：模型服务的 API Key，本地 `ollama` 场景可留空
- `api_base`：自定义 OpenAI 兼容接口地址，可选
- `request_timeout`：请求超时时间，单位秒
- `enable_duckduckgo`：是否启用 DuckDuckGo Web Search
- `brave_api_key`：Brave Search API Key，可选
- `tavily_api_key`：Tavily API Key，可选
- `searxng_base_url`：SearXNG 服务地址，可选

## 首次使用建议

1. 先填入 `model_name`、`model` 和 `api_key`
2. 启动 add-on，确认日志中已经开始运行 `picoclaw gateway`
3. 再按需补充 Web Search 配置
4. 后续再继续扩展 Home Assistant 自动化联动

## 持久化路径

add-on 会把 PicoClaw 的配置和工作目录保存在：

- `/data/picoclaw/config.json`
- `/data/picoclaw/workspace`

## 已知限制

- 目前没有覆盖 PicoClaw 的全部高级配置
- 还没有提供 Home Assistant Ingress 页面
- 当前实现更适合作为开发和验证基础版本
