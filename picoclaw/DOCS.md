# PicoClaw Gateway

## 简介

这个 add-on 会在 Home Assistant OS 中运行 `PicoClaw gateway`，用于验证轻量化 AI Agent 在智能家居盒子上的常驻部署方式。

同时提供一个基于 Home Assistant Ingress 的控制页，内置 MCP 自检、Home Assistant API 检测、Supervisor API 检测和 Web Terminal，方便直接在 add-on 容器内查看配置、执行调试命令和触发辅助脚本。

## 安装前说明

- 当前仅支持 `aarch64`
- add-on 使用宿主机网络，`PicoClaw Gateway` 会直接监听本机 `18790`
- 需要你自行准备 LLM API Key，或者接入本地兼容接口

## 配置项

- `use_raw_config`：是否启用完整 `config.json` 直写模式
- `raw_config`：完整的 `PicoClaw config.json` 内容，启用直写模式后会直接生效
- `model_name`：PicoClaw 内部使用的模型别名
- `model`：实际模型标识，例如 `openai/gpt-5.2`、`zhipu/glm-4.7`、`ollama/llama3`
- `qq_enabled`：是否启用 QQ 频道
- `qq_app_id`：QQ App ID
- `qq_app_secret`：QQ App Secret
- `qq_allow_from`：允许访问机器人的 QQ 用户 ID，支持逗号或换行分隔
- `qq_reasoning_channel_id`：可选的推理输出频道 ID
- `feishu_enabled`：是否启用飞书频道
- `feishu_app_id`：飞书 App ID
- `feishu_app_secret`：飞书 App Secret
- `feishu_encrypt_key`：可选的飞书 Encrypt Key
- `feishu_verification_token`：可选的飞书 Verification Token
- `feishu_allow_from`：允许访问机器人的飞书用户 ID，支持逗号或换行分隔
- `feishu_reasoning_channel_id`：可选的推理输出频道 ID
- `discord_enabled`：是否启用 Discord 频道
- `discord_token`：Discord Bot Token
- `discord_allow_from`：允许访问机器人的 Discord 用户 ID，支持逗号或换行分隔
- `discord_mention_only`：群聊中仅在被提及时响应
- `discord_reasoning_channel_id`：可选的推理输出频道 ID
- `api_key`：模型服务的 API Key，本地 `ollama` 场景可留空
- `api_base`：自定义 OpenAI 兼容接口地址，可选
- `request_timeout`：请求超时时间，单位秒
- `enable_duckduckgo`：是否启用 DuckDuckGo Web Search
- `brave_api_key`：Brave Search API Key，可选
- `tavily_api_key`：Tavily API Key，可选
- `searxng_base_url`：SearXNG 服务地址，可选
- `ha_enabled`：是否启用 Home Assistant API 集成
- `ha_url`：Home Assistant API 地址，默认使用 add-on 内部可访问的 `http://supervisor/core/api`
- `ha_use_supervisor_token`：是否优先使用 add-on 自动注入的 Supervisor Token
- `ha_token`：可选的 Home Assistant 长效访问令牌，关闭 Supervisor Token 时需要填写
- `ha_request_timeout`：Home Assistant API 请求超时时间，单位秒
- `ha_readonly`：是否启用只读模式，只允许查询 HA 状态
- `ha_allowed_domains`：允许访问的 Home Assistant 域，支持逗号或换行分隔
- `ha_allowed_entities`：可选的 entity_id 白名单，支持逗号或换行分隔

## 首次使用建议

1. 先填入 `model_name`、`model` 和 `api_key`
2. 启动 add-on，确认日志中已经开始运行 `picoclaw gateway`
3. 如果要接 QQ、飞书或 Discord，再补充对应频道的鉴权和允许用户配置
4. 如果需要让 PicoClaw 直接读取或控制 Home Assistant，再启用 `ha_enabled`
5. 按需调整 `ha_allowed_domains`、`ha_allowed_entities` 和 `ha_readonly`
6. 再按需补充 Web Search 配置

## 高级模式

如果你希望完全控制 `PicoClaw` 配置，可以：

1. 打开 `use_raw_config`
2. 把完整 JSON 粘贴到 `raw_config`
3. 保存后重启 add-on，或者触发 gateway 热重启

启用后，add-on 不再根据单独的模型字段自动生成配置，而是直接使用你提供的完整 `config.json`。

如果你想手工定义 `tools.mcp`、`tools.skills` 或其他上游高级能力，也推荐通过这个模式直接写完整配置。

未启用 `use_raw_config` 时，add-on 会在启动时生成一份托管配置，并尽量与已有的 `config.json` 做兼容合并：

- add-on 托管的模型、频道、HA MCP 和基础 gateway 字段会按当前配置更新
- 已有 `config.json` 中未被 add-on 托管的其他顶层字段会尽量保留
- 旧配置如果不是合法 JSON，会先备份再生成新配置

## Home Assistant API 与 MCP

启用 `ha_enabled` 后，add-on 会自动为 PicoClaw 生成一套可用的 `tools.mcp` 配置，并在容器内通过本地 `ha-mcp-server` 直连 Home Assistant API。

默认行为：

- 优先使用 `http://supervisor/core/api`
- 优先使用 add-on 自动注入的 Supervisor Token
- 自动启用一组基础 Home Assistant MCP 工具
- 默认允许域为 `light,switch,scene,script`
- 默认保留 `ClawHub` skill registry
- gateway 启动前会执行一次 HA MCP 自检，并把 `initialize`、`tools/list` 和工具名输出到 add-on 日志

PicoClaw 会按 `mcp_<server>_<tool>` 的方式注册 MCP 工具，因此当前实际可见的工具名包括：

- `mcp_homeassistant_ha_get_state`
- `mcp_homeassistant_ha_list_entities`
- `mcp_homeassistant_ha_call_service`
- `mcp_homeassistant_ha_get_history`

如果你只想查询状态而不希望执行控制，可以打开：

- `ha_readonly`

如果你想进一步限制实体范围，可以填写：

- `ha_allowed_entities`

## Home Assistant 配置填写指南

下面这些说明适用于 add-on 配置页中的 `ha_*` 字段。

### `ha_enabled`

是否启用 Home Assistant 集成。

可选值：

- `false`：关闭
- `true`：开启

如果你暂时只想把 PicoClaw 当成普通聊天或频道 Agent，可以先保持关闭。

### `ha_url`

这是 Home Assistant API 的基础地址，必须包含 `/api` 路径。

常见值：

- `http://supervisor/core/api`
- `http://homeassistant.local:8123/api`
- `http://你的HA_IP:8123/api`
- `https://你的域名/api`

推荐：

- 在 HAOS add-on 场景中，优先使用默认值 `http://supervisor/core/api`
- 只有在内部代理不可用时，再改成外部 HA 地址

### `ha_use_supervisor_token`

是否优先使用 add-on 自动注入的 Supervisor Token。

可选值：

- `true`
- `false`

推荐：

- 如果 add-on 运行在 HAOS 中，先保持 `true`
- 如果你希望显式使用自己的长效令牌，改成 `false` 并填写 `ha_token`

### `ha_token`

这是 Home Assistant 的长效访问令牌。

获取方式：

1. 打开 Home Assistant 前端
2. 进入当前用户的个人资料页
3. 找到“长期访问令牌”
4. 创建新令牌并复制

填写建议：

- 当 `ha_use_supervisor_token=true` 时通常可以留空
- 当 `ha_use_supervisor_token=false` 时必须填写

### `ha_readonly`

是否只允许查询，不允许执行控制类动作。

可选值：

- `true`：只读
- `false`：允许调用服务

推荐：

- 首次联调建议先用 `true`
- 确认实体范围和权限都没问题后，再改成 `false`

### `ha_request_timeout`

这是 Home Assistant API 请求超时时间，单位秒。

可选值：

- 任意正整数，例如 `10`
- 默认值是 `15`

推荐：

- 联调阶段建议先保持 `10` 到 `15`
- 如果你的 HA 环境响应比较慢，再适当调高

### `ha_allowed_domains`

这是允许 PicoClaw 访问或控制的 Home Assistant 域白名单。

填写方式：

- 逗号分隔，例如 `light,switch,scene,script`
- 或换行分隔

域名通常就是 `entity_id` 的前缀，例如：

- `light.living_room_main` 的域是 `light`
- `switch.water_heater` 的域是 `switch`
- `scene.good_night` 的域是 `scene`

常见可选项：

- `light`
- `switch`
- `scene`
- `script`
- `fan`
- `climate`
- `media_player`
- `cover`
- `lock`
- `vacuum`
- `input_boolean`

推荐：

- 第一版先只开 `light,switch,scene,script`
- `cover`、`lock`、`alarm_control_panel` 这类高风险域建议先不要开放

### `ha_allowed_entities`

这是更细粒度的实体白名单，用来进一步限制允许访问的 `entity_id`。

获取方式：

- 打开 Home Assistant 的“开发者工具 -> 状态”
- 或进入“设置 -> 设备与服务 -> 实体”
- 找到实际的 `entity_id`

示例：

- `light.living_room_main`
- `switch.water_heater`
- `scene.good_night`
- `script.leave_home`

填写方式：

- 逗号分隔
- 或换行分隔

说明：

- 留空表示只按 `ha_allowed_domains` 控制
- 如果你想先做更安全的灰度测试，建议只填少量明确的实体

## 推荐配置示例

### 方案一：HAOS 内部最省事

适合先跑通读取状态和基础控制。

- `ha_enabled=true`
- `ha_url=http://supervisor/core/api`
- `ha_use_supervisor_token=true`
- `ha_token=` 留空
- `ha_readonly=true`
- `ha_allowed_domains=light,switch,scene,script`
- `ha_allowed_entities=` 留空

### 方案二：更安全的灰度测试

适合先只放开少量实体。

- `ha_enabled=true`
- `ha_url=http://supervisor/core/api`
- `ha_use_supervisor_token=true`
- `ha_token=` 留空
- `ha_readonly=false`
- `ha_allowed_domains=light,scene`
- `ha_allowed_entities=light.living_room_main,scene.good_night`

### 方案三：手工 Token 模式

适合不想依赖 Supervisor Token 的场景。

- `ha_enabled=true`
- `ha_url=http://你的HA_IP:8123/api`
- `ha_use_supervisor_token=false`
- `ha_token=你的长期访问令牌`
- `ha_readonly=false`
- `ha_allowed_domains=light,switch,scene,script`

## 如何找到 `entity_id` 和 service 名称

如果你要配置 `ha_allowed_entities`，或者想理解 PicoClaw 最终会调用什么 Home Assistant 服务，可以按下面的方法查。

### 查找 `entity_id`

方法一，开发者工具：

1. 打开 Home Assistant 前端
2. 进入“开发者工具”
3. 打开“状态”
4. 在列表里搜索设备名称、房间名或域名
5. 复制对应的 `entity_id`

方法二，实体列表：

1. 打开“设置 -> 设备与服务 -> 实体”
2. 搜索设备名称
3. 打开目标实体详情
4. 查看并复制 `entity_id`

常见例子：

- `light.living_room_main`
- `switch.water_heater`
- `sensor.bedroom_temperature`
- `scene.good_night`
- `script.leave_home`

经验建议：

- `entity_id` 一般由 `域名.实体名` 组成
- 如果只是想限制某几个设备，优先把这些具体 `entity_id` 填进 `ha_allowed_entities`
- 如果用户日常叫法和 `entity_id` 差异很大，建议把这些映射关系写进 `/data/picoclaw/workspace/USER.md`

### 查找 service 名称

Home Assistant 的控制动作通常通过 service 调用完成，格式一般是：

- `<domain>.<service>`

例如：

- `light.turn_on`
- `light.turn_off`
- `switch.turn_on`
- `switch.turn_off`
- `scene.turn_on`
- `script.turn_on`

获取方式：

1. 打开“开发者工具”
2. 进入“动作”或“服务”
3. 在下拉列表中搜索域名，例如 `light`
4. 查看该域下可用的 service

说明：

- `ha_call_service` 工具内部会分别接收 `domain` 和 `service`
- 例如 `light.turn_on` 会拆成 `domain=light` 和 `service=turn_on`

### 常见控制示例

这些例子有助于你判断需要开放哪些域和实体。

开灯：

- `domain=light`
- `service=turn_on`
- 目标实体示例：`light.living_room_main`

关插座：

- `domain=switch`
- `service=turn_off`
- 目标实体示例：`switch.desk_power_strip`

执行场景：

- `domain=scene`
- `service=turn_on`
- 目标实体示例：`scene.good_night`

执行脚本：

- `domain=script`
- `service=turn_on`
- 目标实体示例：`script.leave_home`

### 推荐的排查方式

如果 PicoClaw 控制失败，可以按这个顺序排查：

1. 先确认 `entity_id` 是否真实存在
2. 确认对应域是否已经加入 `ha_allowed_domains`
3. 如果配置了 `ha_allowed_entities`，确认目标实体是否在白名单里
4. 确认当前是否开启了 `ha_readonly`
5. 在 Home Assistant“开发者工具 -> 服务”里手工执行一次同样的 service
6. 查看 `/data/picoclaw/logs/homeassistant-mcp-audit.log`

## 默认工作区文件

add-on 首次启动时会在 workspace 中补齐一些 PicoClaw 原生可识别的文件；如果你已经手工创建过同名文件，则不会覆盖。

默认会生成：

- `/data/picoclaw/workspace/AGENTS.md`
- `/data/picoclaw/workspace/TOOLS.md`
- `/data/picoclaw/workspace/USER.md`
- `/data/picoclaw/workspace/skills/home-assistant/SKILL.md`

你可以直接在 Web Terminal 中编辑这些文件，让 PicoClaw 更了解你的家庭环境和控制偏好。

## 持久化路径

add-on 会把 PicoClaw 的配置和工作目录保存在：

- `/data/picoclaw/.picoclaw/config.json`
- `/data/picoclaw/workspace`
- `/data/picoclaw/logs/homeassistant-mcp-audit.log`

## 控制页与 Terminal

安装并启动 add-on 后，可以直接从 Home Assistant 侧边栏或 add-on 页面打开：

- `PicoClaw Control`

控制页内提供：

- `MCP 自检`
- `Home Assistant API 检测`
- `Supervisor API 检测`
- `重启 Gateway`
- 内置 Terminal iframe
- 在新标签页打开 Terminal 的快捷入口

相关日志：

- MCP 自检结果会直接输出到 add-on 日志
- HA 工具调用审计日志保存在 `/data/picoclaw/logs/homeassistant-mcp-audit.log`
- 审计日志会包含 `request_id`、耗时、HTTP 状态和错误类型等信息

终端内默认已经带上这些环境变量：

- `HOME=/data/picoclaw`
- `PICOCLAW_HOME=/data/picoclaw`
- `PICOCLAW_CONFIG=/data/picoclaw/.picoclaw/config.json`

你可以直接在终端里执行：

- `restart-picoclaw-gateway`
- `ls /data/picoclaw`
- `cat /data/picoclaw/.picoclaw/config.json`
- `cat /data/picoclaw/workspace/AGENTS.md`
- `cat /data/picoclaw/logs/homeassistant-mcp-audit.log`

## `raw_config` 示例

如果你希望完全手写上游 PicoClaw 的 MCP 配置，可以在 `raw_config` 中直接使用类似结构：

```json
{
  "agents": {
    "defaults": {
      "workspace": "/data/picoclaw/workspace",
      "model_name": "gpt-5.2"
    }
  },
  "model_list": [
    {
      "model_name": "gpt-5.2",
      "model": "openai/gpt-5.2",
      "api_key": "YOUR_API_KEY"
    }
  ],
  "tools": {
    "mcp": {
      "enabled": true,
      "servers": {
        "homeassistant": {
          "enabled": true,
          "command": "/usr/bin/ha-mcp-server",
          "env": {
            "HA_URL": "http://supervisor/core/api",
            "HA_USE_SUPERVISOR_TOKEN": "true",
            "HA_READONLY": "false",
            "HA_ALLOWED_DOMAINS": "light,switch,scene,script",
            "HA_ALLOWED_ENTITIES": ""
          }
        }
      }
    }
  }
}
```

## Gateway 重启

除了直接重启整个 add-on，你还可以在容器内执行：

- `restart-picoclaw-gateway`

或者手动创建这个触发文件：

- `/data/picoclaw/restart-gateway`

`run` 脚本会检测到该文件后重启 `picoclaw gateway` 进程。

## 网络行为

当前 add-on 已启用 `host_network`：

- `picoclaw gateway` 会直接绑定宿主机 `0.0.0.0:18790`
- 不再依赖 Home Assistant add-on 的额外端口映射
- 局域网内可直接通过盒子 IP 加端口访问该 gateway
- Ingress Terminal 改为使用内部监听端口 `17681`，避免与 HAOS 预设服务占用的 `7681` 冲突

## 已知限制

- 目前没有覆盖 PicoClaw 的全部高级配置
- 当前 Home Assistant 集成仍以 REST API 为主，还没有做实时事件订阅
- 高风险域默认不建议开放，需要你自行评估白名单
- 当前实现更适合作为开发和验证基础版本
