#!/usr/bin/with-contenv bashio
set -euo pipefail

WORKSPACE_DIR="/data/picoclaw/workspace"
TEMPLATE_DIR="/usr/share/picoclaw/default-workspace"

install_if_missing() {
    local source_path="$1"
    local target_path="$2"

    mkdir -p "$(dirname "${target_path}")"
    if [ ! -e "${target_path}" ]; then
        cp "${source_path}" "${target_path}"
    fi
}

mkdir -p \
    "${WORKSPACE_DIR}/sessions" \
    "${WORKSPACE_DIR}/memory" \
    "${WORKSPACE_DIR}/state" \
    "${WORKSPACE_DIR}/cron" \
    "${WORKSPACE_DIR}/skills/home-assistant"

install_if_missing "${TEMPLATE_DIR}/AGENTS.md" "${WORKSPACE_DIR}/AGENTS.md"
install_if_missing "${TEMPLATE_DIR}/TOOLS.md" "${WORKSPACE_DIR}/TOOLS.md"
install_if_missing "${TEMPLATE_DIR}/USER.md" "${WORKSPACE_DIR}/USER.md"
install_if_missing \
    "${TEMPLATE_DIR}/skills/home-assistant/SKILL.md" \
    "${WORKSPACE_DIR}/skills/home-assistant/SKILL.md"
