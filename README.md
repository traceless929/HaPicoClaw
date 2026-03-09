# HaPicoClaw

这个仓库用于承载基于 `PicoClaw` 的 Home Assistant add-on。

当前包含一个面向 `aarch64` 设备的首版 add-on 骨架，目标设备是 `x88pro20 / RK3566` 这类盒子，优先验证：

- PicoClaw 在 HAOS add-on 中的常驻运行方式
- 通过 `/data` 持久化配置和工作目录
- 使用 PicoClaw `gateway` 形态承载后续智能家居自动化能力

## 目录结构

- `repository.yaml`：Home Assistant add-on 仓库元数据
- `picoclaw/`：PicoClaw add-on 实现

## 当前状态

这是一个可继续开发的起始版本，已经具备：

- 独立 Git 仓库
- Home Assistant add-on 基本元数据
- PicoClaw 二进制下载式 Dockerfile
- 启动前配置生成脚本
- `gateway` 服务启动脚本

后续可以继续补充：

- 更完整的 PicoClaw 配置映射
- Ingress 或 Web UI 集成策略
- 与 Home Assistant API / MQTT / Webhook 的联动方案
- 多架构支持和版本发布流程
