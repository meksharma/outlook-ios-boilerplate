#!/bin/bash

set -u

if [[ "${PLATFORM_NAME:-}" != "iphonesimulator" && "${SDK_NAME:-}" != iphonesimulator* ]]; then
  exit 0
fi

bridge_url="http://127.0.0.1:8765/health"
tools_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
log_dir="$HOME/Library/Logs/Outlook-iOS-Boilerplate"
log_file="$log_dir/workiq-bridge.log"

if /usr/bin/curl --silent --fail --max-time 1 "$bridge_url" >/dev/null 2>&1; then
  exit 0
fi

export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.volta/bin:$PATH"
node_bin="$(command -v node 2>/dev/null || true)"
npm_bin="$(command -v npm 2>/dev/null || true)"

if [[ -z "$node_bin" ]]; then
  node_bin="$(/bin/zsh -lc 'command -v node' 2>/dev/null || true)"
fi
if [[ -z "$npm_bin" ]]; then
  npm_bin="$(/bin/zsh -lc 'command -v npm' 2>/dev/null || true)"
fi

if [[ -z "$node_bin" || -z "$npm_bin" ]]; then
  echo "warning: Work IQ bridge was not started because Node.js and npm were not found."
  exit 0
fi

if [[ ! -d "$tools_dir/node_modules/@modelcontextprotocol/sdk" ]]; then
  echo "Installing Work IQ bridge dependencies..."
  if ! "$npm_bin" --prefix "$tools_dir" install --no-audit --no-fund; then
    echo "warning: Work IQ bridge dependencies could not be installed."
    exit 0
  fi
fi

/bin/mkdir -p "$log_dir"
/usr/bin/nohup "$node_bin" "$tools_dir/workiq_bridge.js" >>"$log_file" 2>&1 </dev/null &

for _ in {1..20}; do
  if /usr/bin/curl --silent --fail --max-time 1 "$bridge_url" >/dev/null 2>&1; then
    echo "Work IQ bridge is ready."
    exit 0
  fi
  /bin/sleep 0.25
done

echo "warning: Work IQ bridge did not start. See $log_file."
