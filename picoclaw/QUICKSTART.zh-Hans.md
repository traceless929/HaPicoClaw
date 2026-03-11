# PicoClaw Gateway 快速开始

> 适用前提：你已经安装好 Home Assistant OS，并且可以正常进入 Home Assistant 前端。

相关项目与文档：

- Home Assistant 官方 MCP：<https://www.home-assistant.io/integrations/mcp_server/>
- `mcp-proxy`：<https://github.com/sparfenyuk/mcp-proxy>
- PicoClaw：<https://github.com/sipeed/picoclaw>

## 架构速览

这个 add-on 使用的是“官方 MCP + 本地桥接”方案：

```text
Home Assistant mcp_server (/api/mcp)
        ->
      mcp-proxy
        ->
PicoClaw tools.mcp server
        ->
  PicoClaw Gateway / Agent
```

核心含义：

- Home Assistant 官方 `mcp_server` 负责暴露 MCP 能力
- `mcp-proxy` 把官方 `Streamable HTTP` MCP 转成 PicoClaw 更容易消费的本地 `stdio` MCP
- PicoClaw 按自己的 `tools.mcp` 机制加载这个本地进程

## 开始前准备

在开始之前，请先确认：

- Home Assistant OS 已正常运行
- 你可以进入 Home Assistant 的“设置”
- 你的设备架构是 `aarch64`
- 你已经准备好 PicoClaw 所用的大模型 API Key，或者本地兼容模型接口

## 步骤 1：安装 Home Assistant 官方 MCP

1. 打开 Home Assistant 前端。
2. 进入 `设置 -> 设备与服务`。
3. 点击 `添加集成`。
4. 搜索并安装 `Model Context Protocol Server`。
5. 在集成配置里允许它控制 Home Assistant。

如果你的浏览器已经登录了 Home Assistant，也可以直接点击下面的徽标开始安装：

[![Open your Home Assistant and add the MCP integration](https://my.home-assistant.io/badges/config_flow_start.svg)](https://my.home-assistant.io/redirect/config_flow_start?domain=mcp_server)

![步骤 1-1：进入设备与服务](assets/quickstart/01-settings-devices-services.png)

![步骤 1-2：添加集成并搜索 Model Context Protocol Server](assets/quickstart/02-add-integration-search-mcp.png)

![步骤 1-3：官方文档中的集成安装入口](assets/quickstart/03-official-doc-install-entry.png)

![步骤 1-4：官方 MCP 集成安装后的系统选项页](assets/quickstart/04-mcp-integration-options.png)

安装完成后，请继续做一件关键的事：

1. 打开 Home Assistant 的实体暴露页面。
2. 把你希望 PicoClaw 可以读取或控制的实体暴露给官方 MCP。

如果实体没有暴露：

- PicoClaw 侧就算连通了 MCP，也拿不到对应工具能力
- 控制请求也可能被 Home Assistant 拒绝

## 步骤 2：安装本项目 add-on

1. 在 Home Assistant 中添加本仓库对应的 add-on 仓库地址。
2. 打开本仓库里的 `PicoClaw Gateway` add-on。
3. 点击安装。

如果你希望直接把本仓库加入到 Home Assistant，也可以点击下面的徽标：

[![Open your Home Assistant and add this add-on repository](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Ftraceless929%2FHaPicoClaw)

如果你在国内网络环境下访问 GitHub 仓库较慢，也可以使用国内友好镜像入口：

[![Open your Home Assistant and add the CN mirror add-on repository](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgh-proxy.org%2Fhttps%3A%2F%2Fgithub.com%2Ftraceless929%2FHaPicoClaw.git)

安装完成后，不要急着启动，先看下一步配置。

![步骤 2-1：添加本项目 add-on 仓库](assets/quickstart/05a-add-addon-repository.png)

![步骤 2-2：在仓库中打开 PicoClaw Gateway](assets/quickstart/05b-open-addon-card.png)

## 步骤 3：填写 add-on 配置

最小可用配置通常包括：

- `model_name`
- `model`
- `api_key`
- `api_base`（可选，但使用自定义 OpenAI 兼容接口时很常见）
- `ha_enabled=true`
- `ha_mcp_url=http://supervisor/core/api/mcp`
- `ha_mcp_use_supervisor_token=true`
- `ha_mcp_token=` 留空

推荐的最小示例：

```yaml
model_name: "gpt-5.2"
model: "openai/gpt-5.2"
api_key: "YOUR_API_KEY"
api_base: ""
ha_enabled: true
ha_mcp_url: "http://supervisor/core/api/mcp"
ha_mcp_use_supervisor_token: true
ha_mcp_token: ""
```

字段说明：

- `ha_mcp_url`
  默认推荐 `http://supervisor/core/api/mcp`，适合 HAOS add-on 内部访问
- `ha_mcp_use_supervisor_token`
  设为 `true` 时，优先使用 add-on 自动注入的 `SUPERVISOR_TOKEN`
- `ha_mcp_token`
  如果你不想依赖 `SUPERVISOR_TOKEN`，可以关闭上面的开关并填写长期访问令牌
- `api_base`
  如果你使用官方默认地址以外的 OpenAI 兼容接口，例如中转服务、自建代理或本地兼容网关，可以在这里填写完整基础地址；如果直接使用模型默认官方地址，可以留空

什么时候需要手工填写 `ha_mcp_token`：

- 你明确想使用 Home Assistant 的长期访问令牌
- 你不想依赖 Supervisor Token
- 你使用的是外部 HA 地址而不是 add-on 内部地址

![步骤 3-1：add-on 配置页整体视图](assets/quickstart/06a-addon-config-full.png)

![步骤 3-2：Home Assistant MCP 关键配置区域](assets/quickstart/06b-addon-config-ha-mcp.png)

## 步骤 4：启动 add-on

1. 保存配置。
2. 启动 `PicoClaw Gateway` add-on。
3. 等待 add-on 启动完成。

启动后，系统会做这些事：

- 生成 PicoClaw 的运行时 `config.json`
- 启动 PicoClaw `gateway`
- 在需要 Home Assistant MCP 时，由 PicoClaw 自动拉起 `/usr/bin/ha-mcp-proxy-launcher`
- `ha-mcp-proxy-launcher` 再调用 `mcp-proxy` 连接到官方 `/api/mcp`

## 步骤 5：打开控制页测试

启动完成后，打开：

- `PicoClaw Control`

建议按这个顺序测试：

1. 看 `mcp-proxy 状态`
   期望能看到状态信息，并且需要时可以手动启动/停止/重启
2. 点击 `检查 HA API`
   期望返回成功
3. 点击 `检查 Supervisor API`
   期望返回成功
4. 打开内置 `Terminal`
   确认终端页面正常显示，不乱码

如果你想看最终配置，可以在 Terminal 里执行：

```bash
cat /data/picoclaw/.picoclaw/config.json
```

下面这张图同时展示了控制页、`mcp-proxy` 状态，以及 HA / Supervisor 检测区域的整体布局：

![步骤 5：PicoClaw Control 与 mcp-proxy 状态](assets/quickstart/07-control-page-and-status.png)

## 步骤 6：验证 MCP 真的可用

控制页能通过，只说明：

- add-on 启动正常
- HA API / Supervisor API 基本可达
- `mcp-proxy` 可以被管理

要验证 Home Assistant MCP 真的能被 PicoClaw 使用，建议再做一次实际功能验证：

1. 通过你启用的频道把请求发给 PicoClaw
2. 让它读取一个已暴露实体的状态
3. 或执行一个低风险的控制动作，比如打开某个测试灯

建议先测试：

- 查询状态，例如“客厅灯现在开着吗”
- 低风险控制，例如“打开测试灯”

下面这张图展示的是 PicoClaw 通过 Home Assistant MCP 成功读取到已暴露设备后的实际对话效果：

![步骤 6：PicoClaw 通过 Home Assistant MCP 返回设备结果](assets/quickstart/08-final-chat-example.png)

如果这里失败，优先排查：

1. `Model Context Protocol Server` 是否已安装
2. 目标实体是否已经暴露给官方 MCP
3. `ha_mcp_url` 是否正确
4. `ha_mcp_use_supervisor_token` / `ha_mcp_token` 是否配置正确
5. 控制页中的 `mcp-proxy` 状态是否正常

## 常见问题

### 1. `mcp-proxy` 显示未运行

这不一定代表故障。

原因是：

- PicoClaw 正常情况下会按需启动 MCP 进程
- 所以在没有实际调用 Home Assistant MCP 时，`mcp-proxy` 可能暂时没跑起来

如果你在排障：

- 可以先在控制页手动点击 `启动`
- 再看状态是否变成运行中

### 2. HA API 能通，但 PicoClaw 还是不能控制设备

常见原因：

- 官方 MCP 没安装
- 实体没有暴露给 MCP
- 你测的实体不是暴露列表里的那个
- 认证 token 配置不正确

### 3. 我应该先看哪里

推荐排查顺序：

1. Home Assistant 官方 MCP 集成是否已启用
2. 目标实体是否已暴露
3. add-on 配置是否正确
4. `PicoClaw Control` 里的 `mcp-proxy` 状态
5. add-on 运行日志

## 配图说明

当前文档已经包含：

1. Home Assistant `设置 -> 设备与服务`
2. 添加集成并搜索 `Model Context Protocol Server`
3. 官方文档中的 MCP 安装入口
4. 官方 MCP 集成安装后的系统选项页
5. add-on 仓库添加与 `PicoClaw Gateway` 入口
6. add-on 配置页整体图与 Home Assistant MCP 关键字段局部图
7. `PicoClaw Control` 与 `mcp-proxy` 状态图

如果后续你还想补更细的图文说明，最值得追加的是：

- 实体暴露页面
- `HA API` 成功结果的单独截图
- `Supervisor API` 成功结果的单独截图
