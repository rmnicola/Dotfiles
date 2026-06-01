#!/bin/bash

ENV_FILE="$HOME/.config/voxtype/.env"
REMOTE_CONFIG="$HOME/.config/voxtype/remote-config.toml"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
STATE_FILE="$RUNTIME_DIR/voxtype-openai-daemon.pid"
LOG_FILE="$RUNTIME_DIR/voxtype-openai.log"

log() {
  printf '[%s] %s\n' "$(date --iso-8601=seconds)" "$*" >> "$LOG_FILE"
}

if [[ -f "$ENV_FILE" ]]; then
  set -a
  source "$ENV_FILE"
  set +a
fi

restore_local() {
  rm -f "$STATE_FILE"
  systemctl --user start voxtype.service 2>/dev/null
}

if [[ -z "$VOXTYPE_WHISPER_API_KEY" ]]; then
  log "missing VOXTYPE_WHISPER_API_KEY"
  notify-send "Voxtype" "VOXTYPE_WHISPER_API_KEY não está definida" 2>/dev/null
  exit 1
fi

case "$1" in
  start)
    if [[ -f "$STATE_FILE" ]] && kill -0 "$(cat "$STATE_FILE")" 2>/dev/null; then
      log "remote daemon already running"
      voxtype record start
      exit 0
    fi

    log "starting remote voxtype daemon"
    systemctl --user stop voxtype.service 2>/dev/null
    sleep 0.5

    voxtype \
      --config "$REMOTE_CONFIG" \
      --whisper-mode remote \
      --remote-endpoint "https://api.openai.com" \
      --remote-model "whisper-1" \
      --language auto \
      --no-hotkey \
      daemon >> "$LOG_FILE" 2>&1 &
    REMOTE_PID=$!
    echo "$REMOTE_PID" > "$STATE_FILE"
    disown "$REMOTE_PID"

    for _ in {1..30}; do
      voxtype status >/dev/null 2>&1 && break
      sleep 0.1
    done

    voxtype record start
    ;;
  stop)
    log "stopping remote recording"
    voxtype record stop

    for _ in {1..90}; do
      STATUS=$(voxtype status 2>/dev/null)
      [[ "$STATUS" == "idle" ]] && break
      sleep 1
    done

    if [[ -f "$STATE_FILE" ]]; then
      REMOTE_PID=$(cat "$STATE_FILE")
      kill "$REMOTE_PID" 2>/dev/null
    fi

    restore_local
    ;;
  *)
    echo "Usage: $0 {start|stop}" >&2
    exit 2
    ;;
esac
