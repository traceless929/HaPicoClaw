#!/usr/bin/with-contenv bashio
set -euo pipefail

OPTIONS_FILE="/data/options.json"
PICOCLAW_HOME="/data/picoclaw"
CONFIG_DIR="${PICOCLAW_HOME}/.picoclaw"
CONFIG_FILE="${CONFIG_DIR}/config.json"
WORKSPACE_DIR="${PICOCLAW_HOME}/workspace"
RESTART_REQUEST_FILE="${PICOCLAW_HOME}/restart-gateway"
LOG_DIR="${PICOCLAW_HOME}/logs"
GENERATED_CONFIG_TEMP="${CONFIG_DIR}/config.generated.$$.$(date +%s).json"
MERGED_CONFIG_TEMP="${CONFIG_DIR}/config.merged.$$.$(date +%s).json"

cleanup() {
    rm -f "${GENERATED_CONFIG_TEMP}" "${MERGED_CONFIG_TEMP}"
}

trap cleanup EXIT

mkdir -p "${PICOCLAW_HOME}" "${CONFIG_DIR}" "${WORKSPACE_DIR}" "${LOG_DIR}"

normalize_ha_mcp_url() {
    local raw_value="$1"
    local trimmed="${raw_value%/}"

    if [ -z "${trimmed}" ]; then
        printf '%s\n' ""
        return
    fi

    case "${trimmed}" in
        */api/mcp)
            printf '%s\n' "${trimmed}"
            ;;
        */api)
            printf '%s/mcp\n' "${trimmed}"
            ;;
        *)
            printf '%s/api/mcp\n' "${trimmed}"
            ;;
    esac
}

use_raw_config="$(jq -r '.use_raw_config // false' "${OPTIONS_FILE}")"
raw_config="$(jq -r '.raw_config // ""' "${OPTIONS_FILE}")"
model_name="$(jq -r '.model_name // "gpt-5.2"' "${OPTIONS_FILE}")"
model="$(jq -r '.model // "openai/gpt-5.2"' "${OPTIONS_FILE}")"
qq_enabled="$(jq -r '.qq_enabled // false' "${OPTIONS_FILE}")"
qq_app_id="$(jq -r '.qq_app_id // ""' "${OPTIONS_FILE}")"
qq_app_secret="$(jq -r '.qq_app_secret // ""' "${OPTIONS_FILE}")"
qq_allow_from_raw="$(jq -r '.qq_allow_from // ""' "${OPTIONS_FILE}")"
qq_reasoning_channel_id="$(jq -r '.qq_reasoning_channel_id // ""' "${OPTIONS_FILE}")"
feishu_enabled="$(jq -r '.feishu_enabled // false' "${OPTIONS_FILE}")"
feishu_app_id="$(jq -r '.feishu_app_id // ""' "${OPTIONS_FILE}")"
feishu_app_secret="$(jq -r '.feishu_app_secret // ""' "${OPTIONS_FILE}")"
feishu_encrypt_key="$(jq -r '.feishu_encrypt_key // ""' "${OPTIONS_FILE}")"
feishu_verification_token="$(jq -r '.feishu_verification_token // ""' "${OPTIONS_FILE}")"
feishu_allow_from_raw="$(jq -r '.feishu_allow_from // ""' "${OPTIONS_FILE}")"
feishu_reasoning_channel_id="$(jq -r '.feishu_reasoning_channel_id // ""' "${OPTIONS_FILE}")"
discord_enabled="$(jq -r '.discord_enabled // false' "${OPTIONS_FILE}")"
discord_token="$(jq -r '.discord_token // ""' "${OPTIONS_FILE}")"
discord_allow_from_raw="$(jq -r '.discord_allow_from // ""' "${OPTIONS_FILE}")"
discord_mention_only="$(jq -r '.discord_mention_only // false' "${OPTIONS_FILE}")"
discord_reasoning_channel_id="$(jq -r '.discord_reasoning_channel_id // ""' "${OPTIONS_FILE}")"
api_key="$(jq -r '.api_key // ""' "${OPTIONS_FILE}")"
api_base="$(jq -r '.api_base // ""' "${OPTIONS_FILE}")"
request_timeout="$(jq -r '.request_timeout // 300' "${OPTIONS_FILE}")"
enable_duckduckgo="$(jq -r 'if .enable_duckduckgo == null then true else .enable_duckduckgo end' "${OPTIONS_FILE}")"
brave_api_key="$(jq -r '.brave_api_key // ""' "${OPTIONS_FILE}")"
tavily_api_key="$(jq -r '.tavily_api_key // ""' "${OPTIONS_FILE}")"
searxng_base_url="$(jq -r '.searxng_base_url // ""' "${OPTIONS_FILE}")"
ha_enabled="$(jq -r '.ha_enabled // false' "${OPTIONS_FILE}")"
ha_mcp_url_raw="$(jq -r '.ha_mcp_url // ""' "${OPTIONS_FILE}")"
ha_mcp_use_supervisor_token_raw="$(jq -r 'if .ha_mcp_use_supervisor_token == null then "" else .ha_mcp_use_supervisor_token end' "${OPTIONS_FILE}")"
ha_mcp_token="$(jq -r '.ha_mcp_token // ""' "${OPTIONS_FILE}")"
legacy_ha_url="$(jq -r '.ha_url // ""' "${OPTIONS_FILE}")"
legacy_ha_use_supervisor_token="$(jq -r 'if .ha_use_supervisor_token == null then "" else .ha_use_supervisor_token end' "${OPTIONS_FILE}")"
legacy_ha_token="$(jq -r '.ha_token // ""' "${OPTIONS_FILE}")"

if [ -n "${ha_mcp_url_raw}" ]; then
    ha_mcp_url="$(normalize_ha_mcp_url "${ha_mcp_url_raw}")"
elif [ -n "${legacy_ha_url}" ]; then
    ha_mcp_url="$(normalize_ha_mcp_url "${legacy_ha_url}")"
else
    ha_mcp_url="http://supervisor/core/api/mcp"
fi

if [ -n "${ha_mcp_use_supervisor_token_raw}" ]; then
    ha_mcp_use_supervisor_token="${ha_mcp_use_supervisor_token_raw}"
elif [ -n "${legacy_ha_use_supervisor_token}" ]; then
    ha_mcp_use_supervisor_token="${legacy_ha_use_supervisor_token}"
else
    ha_mcp_use_supervisor_token="true"
fi

if [ -z "${ha_mcp_token}" ] && [ -n "${legacy_ha_token}" ]; then
    ha_mcp_token="${legacy_ha_token}"
fi

if [ -z "${model_name}" ] || [ -z "${model}" ]; then
    echo "model_name and model must not be empty" >&2
    exit 1
fi

if [ -z "${api_key}" ] && [[ "${model}" != ollama/* ]]; then
    echo "warning: api_key is empty; this is only expected for local providers like ollama" >&2
fi

if [ "${qq_enabled}" = "true" ] && { [ -z "${qq_app_id}" ] || [ -z "${qq_app_secret}" ]; }; then
    echo "qq_app_id and qq_app_secret must not be empty when qq_enabled is true" >&2
    exit 1
fi

if [ "${feishu_enabled}" = "true" ] && { [ -z "${feishu_app_id}" ] || [ -z "${feishu_app_secret}" ]; }; then
    echo "feishu_app_id and feishu_app_secret must not be empty when feishu_enabled is true" >&2
    exit 1
fi

if [ "${discord_enabled}" = "true" ] && [ -z "${discord_token}" ]; then
    echo "discord_token must not be empty when discord_enabled is true" >&2
    exit 1
fi

if [ "${ha_enabled}" = "true" ] && [ -z "${ha_mcp_url}" ]; then
    echo "ha_mcp_url must not be empty when ha_enabled is true" >&2
    exit 1
fi

if [ "${ha_enabled}" = "true" ] && [ "${ha_mcp_use_supervisor_token}" != "true" ] && [ -z "${ha_mcp_token}" ]; then
    echo "ha_mcp_token must not be empty when ha_enabled is true and ha_mcp_use_supervisor_token is false" >&2
    exit 1
fi

qq_allow_from_json="$(
    printf '%s' "${qq_allow_from_raw}" \
        | tr ',\r' '\n\n' \
        | jq -Rsc 'split("\n") | map(gsub("^\\s+|\\s+$"; "")) | map(select(length > 0))'
)"

feishu_allow_from_json="$(
    printf '%s' "${feishu_allow_from_raw}" \
        | tr ',\r' '\n\n' \
        | jq -Rsc 'split("\n") | map(gsub("^\\s+|\\s+$"; "")) | map(select(length > 0))'
)"

discord_allow_from_json="$(
    printf '%s' "${discord_allow_from_raw}" \
        | tr ',\r' '\n\n' \
        | jq -Rsc 'split("\n") | map(gsub("^\\s+|\\s+$"; "")) | map(select(length > 0))'
)"

export HOME="${PICOCLAW_HOME}"
export PICOCLAW_HOME="${PICOCLAW_HOME}"
export PICOCLAW_CONFIG="${CONFIG_FILE}"

if [ "${use_raw_config}" = "true" ]; then
    if [ -z "${raw_config}" ]; then
        echo "raw_config must not be empty when use_raw_config is enabled" >&2
        exit 1
    fi

    printf '%s' "${raw_config}" | jq '.' > "${CONFIG_FILE}"
else
    jq -n \
        --arg workspace "${WORKSPACE_DIR}" \
        --arg model_name "${model_name}" \
        --arg model "${model}" \
        --arg ha_mcp_url "${ha_mcp_url}" \
        --arg ha_mcp_use_supervisor_token "${ha_mcp_use_supervisor_token}" \
        --arg ha_mcp_token "${ha_mcp_token}" \
        --arg qq_app_id "${qq_app_id}" \
        --arg qq_app_secret "${qq_app_secret}" \
        --arg qq_reasoning_channel_id "${qq_reasoning_channel_id}" \
        --arg feishu_app_id "${feishu_app_id}" \
        --arg feishu_app_secret "${feishu_app_secret}" \
        --arg feishu_encrypt_key "${feishu_encrypt_key}" \
        --arg feishu_verification_token "${feishu_verification_token}" \
        --arg feishu_reasoning_channel_id "${feishu_reasoning_channel_id}" \
        --arg discord_token "${discord_token}" \
        --arg discord_reasoning_channel_id "${discord_reasoning_channel_id}" \
        --arg api_key "${api_key}" \
        --arg api_base "${api_base}" \
        --arg searxng_base_url "${searxng_base_url}" \
        --arg brave_api_key "${brave_api_key}" \
        --arg tavily_api_key "${tavily_api_key}" \
        --argjson qq_enabled "${qq_enabled}" \
        --argjson qq_allow_from "${qq_allow_from_json}" \
        --argjson feishu_enabled "${feishu_enabled}" \
        --argjson feishu_allow_from "${feishu_allow_from_json}" \
        --argjson discord_enabled "${discord_enabled}" \
        --argjson discord_allow_from "${discord_allow_from_json}" \
        --argjson discord_mention_only "${discord_mention_only}" \
        --argjson ha_enabled "${ha_enabled}" \
        --argjson request_timeout "${request_timeout}" \
        --argjson enable_duckduckgo "${enable_duckduckgo}" \
        '
        {
          agents: {
            defaults: {
              workspace: $workspace,
              model_name: $model_name,
              restrict_to_workspace: true,
              max_tool_iterations: 20
            }
          },
          model_list: [
            (
              {
                model_name: $model_name,
                model: $model,
                request_timeout: $request_timeout
              }
              + (if $api_key != "" then {api_key: $api_key} else {} end)
              + (if $api_base != "" then {api_base: $api_base} else {} end)
            )
          ],
          channels: {
            qq: (
              {
                enabled: $qq_enabled,
                allow_from: $qq_allow_from,
                reasoning_channel_id: $qq_reasoning_channel_id
              }
              + (if $qq_app_id != "" then {app_id: $qq_app_id} else {} end)
              + (if $qq_app_secret != "" then {app_secret: $qq_app_secret} else {} end)
            ),
            feishu: (
              {
                enabled: $feishu_enabled,
                allow_from: $feishu_allow_from,
                reasoning_channel_id: $feishu_reasoning_channel_id
              }
              + (if $feishu_app_id != "" then {app_id: $feishu_app_id} else {} end)
              + (if $feishu_app_secret != "" then {app_secret: $feishu_app_secret} else {} end)
              + (if $feishu_encrypt_key != "" then {encrypt_key: $feishu_encrypt_key} else {} end)
              + (if $feishu_verification_token != "" then {verification_token: $feishu_verification_token} else {} end)
            ),
            discord: (
              {
                enabled: $discord_enabled,
                allow_from: $discord_allow_from,
                mention_only: $discord_mention_only,
                reasoning_channel_id: $discord_reasoning_channel_id
              }
              + (if $discord_token != "" then {token: $discord_token} else {} end)
            )
          },
          tools: {
            web: {
              duckduckgo: {
                enabled: $enable_duckduckgo,
                max_results: 5
              },
              brave: {
                enabled: ($brave_api_key != ""),
                api_key: $brave_api_key,
                max_results: 5
              },
              tavily: {
                enabled: ($tavily_api_key != ""),
                api_key: $tavily_api_key,
                max_results: 5
              },
              searxng: (
                if $searxng_base_url != "" then
                  {
                    enabled: true,
                    base_url: $searxng_base_url,
                    max_results: 5
                  }
                else
                  {
                    enabled: false,
                    base_url: "",
                    max_results: 5
                  }
                end
              )
            },
            mcp: {
              enabled: $ha_enabled,
              servers: (
                if $ha_enabled then
                  {
                    homeassistant: {
                      enabled: true,
                      command: "/usr/bin/ha-mcp-proxy-launcher",
                      env: {
                        HA_MCP_URL: $ha_mcp_url,
                        HA_MCP_USE_SUPERVISOR_TOKEN: $ha_mcp_use_supervisor_token,
                        HA_MCP_TOKEN: $ha_mcp_token
                      }
                    }
                  }
                else
                  {}
                end
              )
            },
            skills: {
              registries: {
                clawhub: {
                  enabled: true,
                  base_url: "https://clawhub.ai",
                  search_path: "/api/v1/search",
                  skills_path: "/api/v1/skills",
                  download_path: "/api/v1/download"
                }
              }
            }
          },
          gateway: {
            host: "0.0.0.0",
            port: 18790
          }
        }
        ' > "${GENERATED_CONFIG_TEMP}"

    if [ -f "${CONFIG_FILE}" ] && jq empty "${CONFIG_FILE}" >/dev/null 2>&1; then
        jq -s '
            def merge_agents($old; $new):
              ($old // {}) * ($new // {})
              | .defaults = (($old.defaults // {}) * ($new.defaults // {}));

            def merge_channels($old; $new):
              ($old // {}) * ($new // {})
              | .qq = (($old.qq // {}) * ($new.qq // {}))
              | .feishu = (($old.feishu // {}) * ($new.feishu // {}))
              | .discord = (($old.discord // {}) * ($new.discord // {}));

            def merge_tools($old; $new):
              ($old // {}) * ($new // {})
              | .web = (($old.web // {}) * ($new.web // {}))
              | .mcp = (($old.mcp // {}) * ($new.mcp // {}))
              | .mcp.servers = (($old.mcp.servers // {}) * ($new.mcp.servers // {}))
              | .mcp.servers.homeassistant =
                  (($old.mcp.servers.homeassistant // {}) * ($new.mcp.servers.homeassistant // {}))
              | .mcp.servers.homeassistant.env =
                  ((($old.mcp.servers.homeassistant.env // {}) * ($new.mcp.servers.homeassistant.env // {}))
                    | del(.HA_URL, .HA_USE_SUPERVISOR_TOKEN, .HA_TOKEN, .HA_READONLY, .HA_ALLOWED_DOMAINS, .HA_ALLOWED_ENTITIES, .HA_AUDIT_LOG))
              | .skills = (($old.skills // {}) * ($new.skills // {}))
              | .skills.registries = (($old.skills.registries // {}) * ($new.skills.registries // {}))
              | .skills.registries.clawhub =
                  (($old.skills.registries.clawhub // {}) * ($new.skills.registries.clawhub // {}));

            def merge_model_list($old; $new):
              ($new // [])
              + (
                  ($old // [])
                  | map(select(.model_name != (($new[0].model_name // ""))))
                );

            (.[0] // {}) as $old
            | (.[1] // {}) as $new
            | ($old * $new)
            | .agents = merge_agents($old.agents; $new.agents)
            | .model_list = merge_model_list($old.model_list; $new.model_list)
            | .channels = merge_channels($old.channels; $new.channels)
            | .tools = merge_tools($old.tools; $new.tools)
            | .gateway = (($old.gateway // {}) * ($new.gateway // {}))
        ' "${CONFIG_FILE}" "${GENERATED_CONFIG_TEMP}" > "${MERGED_CONFIG_TEMP}"

        mv "${MERGED_CONFIG_TEMP}" "${CONFIG_FILE}"
        echo "Merged existing PicoClaw config with generated add-on settings" >&2
    else
        if [ -f "${CONFIG_FILE}" ]; then
            invalid_backup="${CONFIG_FILE}.bak-invalid-$(date +%Y%m%d%H%M%S)"
            cp "${CONFIG_FILE}" "${invalid_backup}"
            echo "Existing config was invalid JSON, backed up to ${invalid_backup}" >&2
        fi

        mv "${GENERATED_CONFIG_TEMP}" "${CONFIG_FILE}"
        echo "Generated fresh PicoClaw config at ${CONFIG_FILE}" >&2
    fi
fi

chmod 600 "${CONFIG_FILE}"
rm -f "${PICOCLAW_HOME}/config.json"
rm -f "${RESTART_REQUEST_FILE}"

echo "Generated PicoClaw config at ${CONFIG_FILE}" >&2
echo "PicoClaw model alias: ${model_name}" >&2
echo "PicoClaw upstream model: ${model}" >&2

# Print a redacted config snapshot so add-on logs can show the final structure
# without leaking provider credentials.
jq '
  .model_list |= map(
    if has("api_key") and .api_key != "" then
      .api_key = "***redacted***"
    else
      .
    end
  )
  | if .tools.web.brave.api_key? != null and .tools.web.brave.api_key != "" then
      .tools.web.brave.api_key = "***redacted***"
    else
      .
    end
  | if .tools.web.tavily.api_key? != null and .tools.web.tavily.api_key != "" then
      .tools.web.tavily.api_key = "***redacted***"
    else
      .
    end
  | if .tools.mcp.servers.homeassistant.env.HA_MCP_TOKEN? != null and .tools.mcp.servers.homeassistant.env.HA_MCP_TOKEN != "" then
      .tools.mcp.servers.homeassistant.env.HA_MCP_TOKEN = "***redacted***"
    else
      .
    end
' "${CONFIG_FILE}" >&2
