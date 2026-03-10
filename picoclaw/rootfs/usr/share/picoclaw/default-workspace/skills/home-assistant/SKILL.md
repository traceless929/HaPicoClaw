---
name: home-assistant
description: Use when querying Home Assistant entity states, listing available entities, controlling allowed devices, running scenes or scripts, or checking recent entity history through the built-in mcp_homeassistant_ha_* MCP tools.
---

# Home Assistant Control

## 何时使用

当用户想要查询 Home Assistant 实体状态、执行设备控制、运行场景脚本，或排查自动化执行结果时，优先使用这份 skill。

## 目标

- 用 Home Assistant 实时状态回答问题
- 在安全边界内完成控制类操作
- 在失败时给出可执行的排错建议

## 使用前提

- 仅在 Home Assistant 相关问题上使用这份 skill。
- 优先参考 `AGENTS.md`、`TOOLS.md` 和 `USER.md` 中的约束与偏好。
- 如果用户提供的名称和系统里的 `entity_id` 不一致，优先尝试结合 `USER.md` 做映射。
- 优先使用 PicoClaw 实际注册出来的工具名：`mcp_homeassistant_ha_get_state`、`mcp_homeassistant_ha_list_entities`、`mcp_homeassistant_ha_call_service`、`mcp_homeassistant_ha_get_history`。

## 推荐步骤

1. 先确认用户想查询还是想控制。
2. 如果实体不明确，先调用 `mcp_homeassistant_ha_list_entities` 查找候选项，或请用户澄清。
3. 如果要控制设备，先调用 `mcp_homeassistant_ha_get_state` 了解当前状态。
4. 目标明确且策略允许时，再调用 `mcp_homeassistant_ha_call_service`。
5. 如果用户在问“刚才有没有发生过”，使用 `mcp_homeassistant_ha_get_history`。

## 标准操作流程

### 查询状态

1. 判断用户是否已经给出明确 `entity_id` 或足够明确的设备名称。
2. 如果名称模糊，先列出候选实体。
3. 调用 `mcp_homeassistant_ha_get_state`。
4. 用自然语言总结状态，不要只复述原始 JSON。

### 执行控制

1. 明确目标实体。
2. 先读取当前状态。
3. 如果当前已经满足目标状态，直接告诉用户，不重复执行。
4. 如果需要执行控制，再调用 `mcp_homeassistant_ha_call_service`。
5. 返回执行结果和目标实体。

### 查询历史

1. 明确目标实体和时间范围。
2. 如果用户没有给时间范围，默认理解为最近 24 小时。
3. 调用 `mcp_homeassistant_ha_get_history`。
4. 总结关键变化，不要把整段原始历史直接抛给用户。

## 控制策略

- 默认遵循“先读后写”。
- 优先控制白名单域中的实体。
- 对高风险动作保持保守，如果工具拒绝则直接向用户说明。
- 如果结果不符合预期，返回工具错误并建议用户检查实体、自动化或 HA 日志。
- 如果有多个同名或相似实体，不要擅自挑一个执行。
- 如果用户说“全部关闭”这类范围很大的命令，先确认范围是否明确。

## 常见模式

### 查看状态

- “客厅灯现在开着吗”
- “卧室温度是多少”
- “有哪些可用的 scene”

### 执行控制

- “打开客厅主灯”
- “关闭书房插座”
- “运行晚安场景”

### 排查问题

- “今天下午热水器什么时候被打开过”
- “为什么这个灯没有被自动化关掉”

## 失败回退

遇到失败时，优先按下面方式处理：

- 实体找不到：建议用户检查 `entity_id`，或先列出候选实体。
- 服务被拒绝：说明当前是只读模式、域不在白名单，或实体不在白名单。
- 返回异常：建议用户检查 add-on 配置、HA API 地址和日志。
- 结果不确定：明确告诉用户当前无法确认，不要假装成功。

## 输出要求

- 先说结论，再补充关键细节。
- 控制成功时说明控制了哪个实体。
- 控制失败时说明原因和下一步排查建议。
- 如果只是查询状态，回答应尽量简洁，不要附带不必要的底层字段。
