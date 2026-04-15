#!/usr/bin/env bash
# Build and run Atlantis locally (Docker) with Terragrunt. Secrets live in scripts/.env.atlantis.local
# Optional: --with-ngrok (or ATLANTIS_WITH_NGROK=1) starts ngrok and prints the public https URL + webhook path.
# Optional: --update-github-webhook PATCHes repo webhook URL (needs GITHUB_WEBHOOK_ID + token; use with --with-ngrok).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="${ATLANTIS_ENV_FILE:-$ROOT/scripts/.env.atlantis.local}"
IMAGE="${ATLANTIS_LOCAL_IMAGE:-react-app-infra-atlantis:local}"
CONTAINER_NAME="${ATLANTIS_CONTAINER_NAME:-atlantis-local}"
PORT="${ATLANTIS_PORT:-4141}"
DOCKERFILE="$ROOT/docker/atlantis/Dockerfile"
NGROK_PID_FILE="$ROOT/scripts/.atlantis-ngrok.pid"
NGROK_LOG="$ROOT/scripts/.atlantis-ngrok.log"

WITH_NGROK="${ATLANTIS_WITH_NGROK:-0}"
UPDATE_GH_WEBHOOK="${ATLANTIS_UPDATE_GITHUB_WEBHOOK:-0}"

load_env_for_shell() {
  # shellcheck disable=SC1090
  set -a && . "$ENV_FILE" && set +a
}

# PATCH GitHub webhook config.url to ${public_base}/events (public_base has no trailing slash).
update_github_webhook_via_api() {
  local public_base="$1"
  local token hook_id owner repo first
  load_env_for_shell
  token="${GITHUB_WEBHOOK_TOKEN:-${ATLANTIS_GH_TOKEN:-}}"
  hook_id="${GITHUB_WEBHOOK_ID:-}"
  if [[ -z "$token" ]]; then
    echo "update-github-webhook: set ATLANTIS_GH_TOKEN or GITHUB_WEBHOOK_TOKEN in $ENV_FILE" >&2
    return 1
  fi
  if [[ -z "$hook_id" ]]; then
    echo "update-github-webhook: set GITHUB_WEBHOOK_ID in $ENV_FILE (repo Settings -> Webhooks -> URL .../hooks/<id>)" >&2
    return 1
  fi
  first="${ATLANTIS_REPO_ALLOWLIST%%,*}"
  first="${first#github.com/}"
  owner="${first%%/*}"
  repo="${first#*/}"
  if [[ -z "$owner" || -z "$repo" || "$repo" == "$first" ]]; then
    echo "update-github-webhook: could not parse owner/repo from ATLANTIS_REPO_ALLOWLIST=$ATLANTIS_REPO_ALLOWLIST" >&2
    return 1
  fi

  local payload status
  payload="$(python3 -c "
import json, os
base = os.environ['PUBLIC_BASE'].rstrip('/')
url = base + '/events'
cfg = {'url': url, 'content_type': 'json', 'insecure_ssl': '0'}
sec = os.environ.get('ATLANTIS_GH_WEBHOOK_SECRET') or ''
if sec.strip():
    cfg['secret'] = sec
print(json.dumps({'config': cfg}))
" PUBLIC_BASE="$public_base" ATLANTIS_GH_WEBHOOK_SECRET="${ATLANTIS_GH_WEBHOOK_SECRET:-}")"

  echo "PATCH https://api.github.com/repos/${owner}/${repo}/hooks/${hook_id} (webhook URL -> ${public_base}/events) ..."
  status="$(curl -sS -o /tmp/gh-hook-patch.json -w '%{http_code}' -X PATCH \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${token}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/${owner}/${repo}/hooks/${hook_id}" \
    -d "$payload")"

  if [[ "$status" =~ ^2 ]]; then
    echo "GitHub webhook updated (HTTP $status)."
  else
    echo "GitHub API error HTTP $status:" >&2
    cat /tmp/gh-hook-patch.json >&2 || true
    return 1
  fi
  rm -f /tmp/gh-hook-patch.json
}

# Wait until something accepts TCP on 127.0.0.1:$PORT (avoids ngrok "connection refused" to localhost:4141).
wait_for_atlantis() {
  echo "Waiting for Atlantis to listen on 127.0.0.1:$PORT ..."
  local i
  for i in $(seq 1 90); do
    if ! docker inspect -f '{{.State.Running}}' "$CONTAINER_NAME" 2>/dev/null | grep -q true; then
      echo "Container $CONTAINER_NAME is not running." >&2
      docker logs "$CONTAINER_NAME" 2>&1 | tail -40 >&2 || true
      return 1
    fi
    if curl -sS -o /dev/null -m 2 --connect-timeout 1 "http://127.0.0.1:${PORT}/" 2>/dev/null; then
      echo "Atlantis is reachable."
      return 0
    fi
    if (echo >/dev/tcp/127.0.0.1/"$PORT") 2>/dev/null; then
      echo "Port $PORT is open."
      return 0
    fi
    sleep 1
  done
  echo "Timed out: nothing listening on 127.0.0.1:$PORT (ngrok would log 'connection refused')." >&2
  echo "Check: docker logs $CONTAINER_NAME" >&2
  return 1
}

usage() {
  echo "Usage: $0 [build|start|stop|logs] [--with-ngrok] [--update-github-webhook]"
  echo "  (no args)  build image if missing, run Atlantis container"
  echo "  build      docker build only"
  echo "  start      run container only"
  echo "  stop       stop Atlantis container and ngrok (if started by this script)"
  echo "  logs       docker logs -f atlantis-local"
  echo ""
  echo "  --with-ngrok              start ngrok; print https URL and https://<host>/events"
  echo "  --update-github-webhook   PATCH GitHub webhook (needs --with-ngrok, GITHUB_WEBHOOK_ID, token)"
  echo ""
  echo "Env: ATLANTIS_ENV_FILE  ATLANTIS_LOCAL_IMAGE  ATLANTIS_PORT"
  echo "     ATLANTIS_WITH_NGROK=1  ATLANTIS_UPDATE_GITHUB_WEBHOOK=1"
}

# Parse: optional --with-ngrok anywhere; single subcommand build|start|stop|logs
cmd=""
for a in "$@"; do
  case "$a" in
    --with-ngrok) WITH_NGROK=1 ;;
    --update-github-webhook) UPDATE_GH_WEBHOOK=1 ;;
    -h | --help)
      usage
      exit 0
      ;;
    build | start | stop | logs)
      if [[ -n "$cmd" ]]; then
        echo "Unexpected extra argument: $a" >&2
        usage >&2
        exit 1
      fi
      cmd="$a"
      ;;
    *)
      echo "Unknown argument: $a" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ "$UPDATE_GH_WEBHOOK" == "1" && "$WITH_NGROK" != "1" ]]; then
  echo "--update-github-webhook requires --with-ngrok (public URL comes from ngrok)." >&2
  exit 1
fi

if [[ "$cmd" == "stop" ]]; then
  docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
  if [[ -f "$NGROK_PID_FILE" ]]; then
    pid="$(cat "$NGROK_PID_FILE" 2>/dev/null || true)"
    if [[ -n "${pid:-}" ]] && kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
      echo "Stopped ngrok (pid $pid)"
    fi
    rm -f "$NGROK_PID_FILE"
  fi
  echo "Stopped $CONTAINER_NAME"
  exit 0
fi

if [[ "$cmd" == "logs" ]]; then
  docker logs -f "$CONTAINER_NAME"
  exit 0
fi

case "$cmd" in
  "" | build | start) ;;
  *)
    echo "Unknown command: ${cmd:-}" >&2
    usage >&2
    exit 1
    ;;
esac

case "$cmd" in
  "" | start) ;;
  *)
    if [[ "$UPDATE_GH_WEBHOOK" == "1" ]]; then
      echo "--update-github-webhook is only used when starting Atlantis + ngrok (omit build/stop/logs)." >&2
      exit 1
    fi
    ;;
esac

if [[ "$cmd" == "build" || -z "$(docker images -q "$IMAGE" 2>/dev/null)" ]]; then
  echo "Building $IMAGE ..."
  docker build -t "$IMAGE" -f "$DOCKERFILE" "$ROOT/docker/atlantis"
fi

if [[ "$cmd" == "build" ]]; then
  echo "Built $IMAGE"
  exit 0
fi

if [[ ! -f "$ENV_FILE" ]]; then
  EXAMPLE="$ROOT/scripts/.env.atlantis.example"
  if [[ -f "$EXAMPLE" ]]; then
    cp "$EXAMPLE" "$ENV_FILE"
    echo "Created $ENV_FILE from .env.atlantis.example — edit it (GitHub token, repo allowlist, etc.), then run this script again."
    exit 1
  fi
  echo "Missing env file: $ENV_FILE"
  echo "Copy scripts/.env.atlantis.example to scripts/.env.atlantis.local and set values."
  exit 1
fi

docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

echo "Starting $CONTAINER_NAME on http://localhost:$PORT ..."
# No volume on /home/atlantis/.atlantis: a Docker named volume is often root-owned and the
# atlantis user cannot mkdir ~/.atlantis/bin (Terraform downloads). Data is ephemeral per container.
docker run -d --name "$CONTAINER_NAME" \
  --env-file "$ENV_FILE" \
  -p "${PORT}:4141" \
  -v "${HOME}/.aws:/home/atlantis/.aws:ro" \
  "$IMAGE" \
  server --repo-config=/etc/atlantis/repos.yaml

echo ""
echo "Atlantis UI: http://localhost:$PORT"

if [[ "$WITH_NGROK" != "1" ]]; then
  echo "Tip: start ngrok with this script: $0 --with-ngrok"
  echo "     or run: ngrok http $PORT"
  echo "Then set ATLANTIS_ATLANTIS_URL in $ENV_FILE to the https URL, restart, and point GitHub webhook to https://<host>/events"
  echo "Logs: $0 logs"
  exit 0
fi

if ! command -v ngrok >/dev/null 2>&1; then
  echo "WITH_NGROK requested but 'ngrok' not found in PATH. Install https://ngrok.com/download" >&2
  exit 1
fi

if ! wait_for_atlantis; then
  exit 1
fi

# Avoid duplicate ngrok from a previous run
if [[ -f "$NGROK_PID_FILE" ]]; then
  oldpid="$(cat "$NGROK_PID_FILE" 2>/dev/null || true)"
  if [[ -n "${oldpid:-}" ]] && kill -0 "$oldpid" 2>/dev/null; then
    kill "$oldpid" 2>/dev/null || true
  fi
  rm -f "$NGROK_PID_FILE"
fi

echo "Starting ngrok tunnel to localhost:$PORT ..."
nohup ngrok http "$PORT" --log=stdout >"$NGROK_LOG" 2>&1 &
echo $! >"$NGROK_PID_FILE"

fetch_ngrok_https_url() {
  local url="" i
  for i in $(seq 1 40); do
    if curl -sf "http://127.0.0.1:4040/api/tunnels" -o /tmp/atlantis-ngrok-tunnels.json 2>/dev/null; then
      if command -v jq >/dev/null 2>&1; then
        url="$(jq -r '.tunnels[] | select(.proto == "https") | .public_url' /tmp/atlantis-ngrok-tunnels.json 2>/dev/null | head -1)"
      else
        url="$(python3 -c "
import json, sys
try:
    d = json.load(open('/tmp/atlantis-ngrok-tunnels.json'))
    for t in d.get('tunnels', []):
        u = t.get('public_url') or ''
        if u.startswith('https:'):
            print(u)
            sys.exit(0)
except Exception:
    pass
" 2>/dev/null || true)"
      fi
      if [[ -n "$url" && "$url" != "null" ]]; then
        echo "$url"
        return 0
      fi
    fi
    sleep 1
  done
  return 1
}

PUBLIC_URL="$(fetch_ngrok_https_url || true)"
rm -f /tmp/atlantis-ngrok-tunnels.json

if [[ -z "$PUBLIC_URL" ]]; then
  echo "ngrok started (pid $(cat "$NGROK_PID_FILE")), but could not read https URL from http://127.0.0.1:4040/api/tunnels yet."
  echo "Check $NGROK_LOG or open http://127.0.0.1:4040 — then set ATLANTIS_ATLANTIS_URL manually."
  if [[ "$UPDATE_GH_WEBHOOK" == "1" ]]; then
    echo "Skipping --update-github-webhook (no public URL yet)." >&2
  fi
else
  echo ""
  echo "ngrok public URL:  $PUBLIC_URL"
  echo "GitHub webhook URL: ${PUBLIC_URL}/events"
  echo "Set in $ENV_FILE:   ATLANTIS_ATLANTIS_URL=$PUBLIC_URL"
  if [[ "$UPDATE_GH_WEBHOOK" == "1" ]]; then
    echo ""
    if update_github_webhook_via_api "$PUBLIC_URL"; then
      :
    else
      echo "You can still set the webhook manually to ${PUBLIC_URL}/events" >&2
    fi
  else
    echo "To auto-update this webhook next time: $0 --with-ngrok --update-github-webhook (set GITHUB_WEBHOOK_ID in $ENV_FILE)"
  fi
fi
echo "ngrok logs: $NGROK_LOG  |  stop ngrok: $0 stop"
echo "Logs: $0 logs"
