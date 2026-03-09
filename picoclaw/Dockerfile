ARG BUILD_FROM
ARG PICOCLAW_VERSION="v0.2.0"

FROM $BUILD_FROM

ENV LANG=C.UTF-8

RUN apk add --no-cache curl jq \
    && curl -fsSL "https://github.com/sipeed/picoclaw/releases/download/${PICOCLAW_VERSION}/picoclaw-linux-arm64" -o /usr/bin/picoclaw \
    && chmod 755 /usr/bin/picoclaw \
    && (/usr/bin/picoclaw version || /usr/bin/picoclaw --help >/dev/null)

COPY rootfs /
