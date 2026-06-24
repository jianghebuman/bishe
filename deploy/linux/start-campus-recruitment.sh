#!/usr/bin/env bash
set -euo pipefail

APP_HOME="${APP_HOME:-/opt/campus-recruitment}"
ENV_FILE="${ENV_FILE:-$APP_HOME/.env}"
JAR_FILE="${JAR_FILE:-$APP_HOME/backend/campus-recruitment.jar}"
PID_FILE="${PID_FILE:-$APP_HOME/run/campus-recruitment.pid}"
OUT_FILE="${OUT_FILE:-$APP_HOME/logs/campus-recruitment.out}"

if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  . "$ENV_FILE"
  set +a
fi

: "${DB_PASSWORD:?DB_PASSWORD is required. Set it in $ENV_FILE or the shell environment.}"
: "${JWT_SECRET:?JWT_SECRET is required. Set it in $ENV_FILE or the shell environment.}"

mkdir -p "$APP_HOME/run" "$APP_HOME/logs" "${CAMPUS_UPLOAD_PATH:-$APP_HOME/upload/}"

if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  echo "campus-recruitment is already running, pid=$(cat "$PID_FILE")"
  exit 0
fi

nohup java ${JAVA_OPTS:-} -jar "$JAR_FILE" \
  --spring.profiles.active=prod \
  > "$OUT_FILE" 2>&1 &

echo $! > "$PID_FILE"
echo "campus-recruitment started, pid=$(cat "$PID_FILE")"
echo "log: $OUT_FILE"
