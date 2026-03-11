ARG BUILD_FROM="ghcr.io/home-assistant/aarch64-base:3.23-2026.02.0"

FROM $BUILD_FROM

ENV LANG=C.UTF-8

COPY bin/picoclaw_Linux_arm64.tar.gz /tmp/picoclaw_Linux_arm64.tar.gz

RUN apk add --no-cache ca-certificates curl jq py3-aiohttp py3-pip python3 ttyd tzdata \
    && tar -xzf /tmp/picoclaw_Linux_arm64.tar.gz -C /tmp \
    && install -m 755 /tmp/picoclaw /usr/bin/picoclaw \
    && pip3 install --no-cache-dir mcp-proxy \
    && rm -f /tmp/picoclaw /tmp/picoclaw_Linux_arm64.tar.gz \
    && (/usr/bin/picoclaw version || /usr/bin/picoclaw --help >/dev/null)

COPY rootfs /

RUN chmod 755 /usr/bin/ha-mcp-proxy-launcher /usr/bin/ha-mcp-server /usr/bin/ha-mcp-selftest /usr/bin/ha-api-selftest /usr/bin/supervisor-api-selftest /usr/bin/picoclaw-control-panel /etc/cont-init.d/10-workspace-files.sh /etc/services.d/webui/run
