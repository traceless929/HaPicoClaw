#!/usr/bin/with-contenv bashio
set -euo pipefail

OPTIONS_FILE="/data/options.json"
PICOCLAW_HOME="/data/picoclaw"
LEGACY_PICOCLAW_HOME="${PICOCLAW_HOME}/.picoclaw"
CONFIG_FILE="${LEGACY_PICOCLAW_HOME}/config.json"
COMPAT_CONFIG_FILE="${PICOCLAW_HOME}/config.json"
WORKSPACE_DIR="${PICOCLAW_HOME}/workspace"
RESTART_REQUEST_FILE="${PICOCLAW_HOME}/restart-gateway"

mkdir -p "${PICOCLAW_HOME}" "${LEGACY_PICOCLAW_HOME}" "${WORKSPACE_DIR}"

use_raw_config="$(jq -r '.use_raw_config // false' "${OPTIONS_FILE}")"
raw_config="$(jq -r '.raw_config // ""' "${OPTIONS_FILE}")"
model_name="$(jq -r '.model_name // "gpt-5.2"' "${OPTIONS_FILE}")"
model="$(jq -r '.model // "openai/gpt-5.2"' "${OPTIONS_FILE}")"
discord_enabled="$(jq -r '.discord_enabled // false' "${OPTIONS_FILE}")"
discord_token="$(jq -r '.discord_token // ""' "${OPTIONS_FILE}")"
discord_allow_from_raw="$(jq -r '.discord_allow_from // ""' "${OPTIONS_FILE}")"
discord_mention_only="$(jq -r '.discord_mention_only // false' "${OPTIONS_FILE}")"
discord_reasoning_channel_id="$(jq -r '.discord_reasoning_channel_id // ""' "${OPTIONS_FILE}")"
api_key="$(jq -r '.api_key // ""' "${OPTIONS_FILE}")"
api_base="$(jq -r '.api_base // ""' "${OPTIONS_FILE}")"
request_timeout="$(jq -r '.request_timeout // 300' "${OPTIONS_FILE}")"
enable_duckduckgo="$(jq -r '.enable_duckduckgo // true' "${OPTIONS_FILE}")"
brave_api_key="$(jq -r '.brave_api_key // ""' "${OPTIONS_FILE}")"
tavily_api_key="$(jq -r '.tavily_api_key // ""' "${OPTIONS_FILE}")"
searxng_base_url="$(jq -r '.searxng_base_url // ""' "${OPTIONS_FILE}")"

if [ -z "${model_name}" ] || [ -z "${model}" ]; then
    echo "model_name and model must not be empty" >&2
    exit 1
fi

if [ -z "${api_key}" ] && [[ "${model}" != ollama/* ]]; then
    echo "warning: api_key is empty; this is only expected for local providers like ollama" >&2
fi

if [ "${discord_enabled}" = "true" ] && [ -z "${discord_token}" ]; then
    echo "discord_token must not be empty when discord_enabled is true" >&2
    exit 1
fi

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
        --arg discord_token "${discord_token}" \
        --arg discord_reasoning_channel_id "${discord_reasoning_channel_id}" \
        --arg api_key "${api_key}" \
        --arg api_base "${api_base}" \
        --arg searxng_base_url "${searxng_base_url}" \
        --arg brave_api_key "${brave_api_key}" \
        --arg tavily_api_key "${tavily_api_key}" \
        --argjson discord_enabled "${discord_enabled}" \
        --argjson discord_allow_from "${discord_allow_from_json}" \
        --argjson discord_mention_only "${discord_mention_only}" \
        --argjson request_timeout "${request_timeout}" \
        --argjson enable_duckduckgo "${enable_duckduckgo}" \
        '
        {
          agents: {
            defaults: {
              workspace: $workspace,
              model_name: $model_name,
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
            }
          }
        }
        ' > "${CONFIG_FILE}"
fi

chmod 600 "${CONFIG_FILE}"
cp "${CONFIG_FILE}" "${COMPAT_CONFIG_FILE}"
chmod 600 "${COMPAT_CONFIG_FILE}"
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
' "${CONFIG_FILE}" >&2
