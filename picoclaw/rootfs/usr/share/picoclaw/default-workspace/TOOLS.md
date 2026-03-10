# Home Assistant Tools

本工作区默认启用了以下 Home Assistant MCP 工具。

PicoClaw 会把 `homeassistant` MCP server 暴露的工具注册为带前缀的实际工具名，因此你在推理和调用时，应优先使用这些名字：

- `mcp_homeassistant_ha_get_state`
- `mcp_homeassistant_ha_list_entities`
- `mcp_homeassistant_ha_call_service`
- `mcp_homeassistant_ha_get_history`

## 使用顺序建议

1. 先判断用户是在问状态、找设备、执行控制，还是排查历史。
2. 不确定目标实体时，先用 `mcp_homeassistant_ha_list_entities`。
3. 要执行控制时，优先先用 `mcp_homeassistant_ha_get_state`。
4. 只有目标明确且策略允许时，才使用 `mcp_homeassistant_ha_call_service`。
5. 需要判断过去一段时间内发生过什么时，使用 `mcp_homeassistant_ha_get_history`。

## `mcp_homeassistant_ha_get_state`

读取单个实体的当前状态与属性。

适合：
- 查看灯是否开启
- 查看温湿度、功率、门磁等传感器状态

输入：
- `entity_id`

输出重点：
- `state`
- `attributes`
- `friendly_name`

## `mcp_homeassistant_ha_list_entities`

列出当前允许访问的 Home Assistant 实体，可选按域过滤。

适合：
- 当用户只说“客厅灯”但你还不知道具体 `entity_id`
- 先浏览 `light`、`switch`、`scene`、`script` 等可用实体

输入：
- 可选 `domain`

输出重点：
- `entity_id`
- `friendly_name`
- 当前 `state`

## `mcp_homeassistant_ha_call_service`

调用 Home Assistant 服务，例如 `light.turn_on`、`switch.turn_off`、`scene.turn_on`。

调用前要点：
- 仅在实体或目标足够明确时使用
- 先读状态再写会更稳妥
- 如果当前处于只读模式，这个工具会被拒绝

常见调用模式：
- `domain=light`, `service=turn_on`
- `domain=light`, `service=turn_off`
- `domain=switch`, `service=turn_on`
- `domain=switch`, `service=turn_off`
- `domain=scene`, `service=turn_on`
- `domain=script`, `service=turn_on`

常见 `data` 示例：

```json
{"entity_id":"light.living_room_main"}
```

```json
{"entity_id":"light.bedroom_main","brightness_pct":30}
```

## `mcp_homeassistant_ha_get_history`

查询某个实体在一段时间内的历史状态。

适合：
- 判断最近是否开过灯
- 查看温度变化趋势
- 辅助排查自动化没有生效的时间窗口

输入：
- `entity_id`
- 可选 `start_time`
- 可选 `end_time`

说明：
- 如果不传时间范围，默认查询最近 24 小时
- 时间建议使用 ISO-8601 格式

## 常见注意事项

- 所有工具都受 `ha_allowed_domains` 和 `ha_allowed_entities` 约束。
- `mcp_homeassistant_ha_call_service` 还会受 `ha_readonly` 影响。
- 如果用户只是问“开了吗”，不要直接执行写操作。
- 如果工具报错，优先把错误原因翻译成用户能理解的说明，再给排查建议。
