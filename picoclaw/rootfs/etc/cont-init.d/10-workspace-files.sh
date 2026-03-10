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

refresh_file_if_legacy() {
    local source_path="$1"
    local target_path="$2"
    local legacy_pattern="$3"
    local current_pattern="$4"
    local backup_path=""

    if [ ! -e "${target_path}" ]; then
        cp "${source_path}" "${target_path}"
        return
    fi

    if grep -q "${legacy_pattern}" "${target_path}" && ! grep -q "${current_pattern}" "${target_path}"; then
        backup_path="${target_path}.bak-legacy-$(date +%Y%m%d%H%M%S)"
        cp "${target_path}" "${backup_path}"
        cp "${source_path}" "${target_path}"
    fi
}

refresh_skill_if_invalid() {
    local source_path="$1"
    local target_path="$2"
    local backup_path=""

    if [ ! -e "${target_path}" ]; then
        cp "${source_path}" "${target_path}"
        return
    fi

    if ! sed -n '1,8p' "${target_path}" | grep -q '^description:'; then
        backup_path="${target_path}.bak-invalid-$(date +%Y%m%d%H%M%S)"
        cp "${target_path}" "${backup_path}"
        cp "${source_path}" "${target_path}"
    fi
}

mkdir -p \
    "${WORKSPACE_DIR}/sessions" \
    "${WORKSPACE_DIR}/memory" \
    "${WORKSPACE_DIR}/state" \
    "${WORKSPACE_DIR}/cron" \
    "${WORKSPACE_DIR}/skills/home-assistant"

refresh_file_if_legacy \
    "${TEMPLATE_DIR}/AGENTS.md" \
    "${WORKSPACE_DIR}/AGENTS.md" \
    'ha_get_state' \
    'mcp_homeassistant_ha_get_state'
refresh_file_if_legacy \
    "${TEMPLATE_DIR}/TOOLS.md" \
    "${WORKSPACE_DIR}/TOOLS.md" \
    'ha_get_state' \
    'mcp_homeassistant_ha_get_state'
install_if_missing "${TEMPLATE_DIR}/AGENTS.md" "${WORKSPACE_DIR}/AGENTS.md"
install_if_missing "${TEMPLATE_DIR}/TOOLS.md" "${WORKSPACE_DIR}/TOOLS.md"
install_if_missing "${TEMPLATE_DIR}/USER.md" "${WORKSPACE_DIR}/USER.md"
refresh_skill_if_invalid \
    "${TEMPLATE_DIR}/skills/home-assistant/SKILL.md" \
    "${WORKSPACE_DIR}/skills/home-assistant/SKILL.md"
refresh_file_if_legacy \
    "${TEMPLATE_DIR}/skills/home-assistant/SKILL.md" \
    "${WORKSPACE_DIR}/skills/home-assistant/SKILL.md" \
    'ha_get_state' \
    'mcp_homeassistant_ha_get_state'
