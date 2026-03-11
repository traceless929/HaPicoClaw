ARG BUILD_FROM="ghcr.io/home-assistant/aarch64-base:3.23-2026.02.0"

FROM $BUILD_FROM

ENV LANG=C.UTF-8 \
    MCP_PROXY_VENV="/opt/mcp-proxy"

COPY bin/picoclaw_Linux_arm64.tar.gz /tmp/picoclaw_Linux_arm64.tar.gz
COPY bin/mcp_proxy-0.11.0-py3-none-any.whl /tmp/mcp_proxy-0.11.0-py3-none-any.whl

RUN apk add --no-cache ca-certificates curl jq py3-aiohttp py3-pip python3 ttyd tzdata \
    && tar -xzf /tmp/picoclaw_Linux_arm64.tar.gz -C /tmp \
    && install -m 755 /tmp/picoclaw /usr/bin/picoclaw \
    && python3 -m venv "${MCP_PROXY_VENV}" \
    && "${MCP_PROXY_VENV}/bin/pip" install --no-cache-dir /tmp/mcp_proxy-0.11.0-py3-none-any.whl \
    && ln -sf "${MCP_PROXY_VENV}/bin/mcp-proxy" /usr/local/bin/mcp-proxy \
    && rm -f /tmp/picoclaw /tmp/picoclaw_Linux_arm64.tar.gz /tmp/mcp_proxy-0.11.0-py3-none-any.whl \
    && (/usr/bin/picoclaw version || /usr/bin/picoclaw --help >/dev/null)

COPY rootfs /

RUN chmod 755 /usr/bin/ha-mcp-proxy-launcher /usr/bin/ha-mcp-proxy-manager /usr/bin/ha-mcp-server /usr/bin/ha-api-selftest /usr/bin/supervisor-api-selftest /usr/bin/picoclaw-control-panel /etc/cont-init.d/10-workspace-files.sh /etc/services.d/webui/run
