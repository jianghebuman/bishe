#!/usr/bin/env bash
set -Eeuo pipefail

APP="${APP:-/www/campus-recruitment}"
NGINX="${NGINX:-/www/server/nginx/sbin/nginx}"
HEALTH_URL="${HEALTH_URL:-http://127.0.0.1:8081/api/public/home}"

RELEASE=""
RUN_DB=0

for arg in "$@"; do
  case "$arg" in
    --db)
      RUN_DB=1
      ;;
    -*)
      echo "Unknown option: $arg" >&2
      exit 2
      ;;
    *)
      RELEASE="$arg"
      ;;
  esac
done

if [ -z "$RELEASE" ]; then
  echo "Usage: $0 /path/to/bishe-release.zip [--db]" >&2
  exit 2
fi

if [ ! -f "$RELEASE" ]; then
  echo "Release package not found: $RELEASE" >&2
  exit 2
fi

command -v unzip >/dev/null 2>&1 || { echo "unzip is required" >&2; exit 2; }
command -v curl >/dev/null 2>&1 || { echo "curl is required" >&2; exit 2; }

ENV_FILE="${ENV_FILE:-$APP/.env}"
if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  . "$ENV_FILE"
  set +a
fi

TMP="/tmp/bishe-release-$(date +%Y%m%d%H%M%S)-$$"
trap 'rm -rf "$TMP"' EXIT

echo "1. Unpack release"
mkdir -p "$TMP"
unzip -q "$RELEASE" -d "$TMP"

[ -f "$TMP/backend/campus-recruitment.jar" ] || { echo "Missing backend jar in release" >&2; exit 1; }
[ -f "$TMP/frontend/dist/index.html" ] || { echo "Missing frontend dist in release" >&2; exit 1; }

mkdir -p "$APP/backend" "$APP/frontend" "$APP/upload" "$APP/logs" "$APP/run" "$APP/backups"

if [ "$RUN_DB" -eq 1 ]; then
  echo "2. Backup and update database"
  DB_NAME="${DB_NAME:-campus_recruitment}"
  DB_USERNAME="${DB_USERNAME:-root}"
  : "${DB_PASSWORD:?DB_PASSWORD is required in $ENV_FILE when --db is used}"
  DB_BACKUP="$APP/backups/${DB_NAME}_$(date +%Y%m%d-%H%M%S).sql"

  mysqldump -u"$DB_USERNAME" -p"$DB_PASSWORD" "$DB_NAME" > "$DB_BACKUP"
  mysql -u"$DB_USERNAME" -p"$DB_PASSWORD" "$DB_NAME" < "$TMP/database/update-data.sql"
  echo "Database backup: $DB_BACKUP"
else
  echo "2. Skip database update"
fi

echo "3. Replace backend jar"
cp -f "$TMP/backend/campus-recruitment.jar" "$APP/backend/campus-recruitment.jar"

echo "4. Replace frontend dist"
rm -rf "$APP/frontend/dist.new" "$APP/frontend/dist.old"
cp -a "$TMP/frontend/dist" "$APP/frontend/dist.new"
if [ -d "$APP/frontend/dist" ]; then
  mv "$APP/frontend/dist" "$APP/frontend/dist.old"
fi
mv "$APP/frontend/dist.new" "$APP/frontend/dist"

echo "5. Sync upload assets"
if [ -d "$TMP/upload" ]; then
  cp -a "$TMP/upload/." "$APP/upload/"
fi

echo "6. Restart backend"
if [ -f "$APP/run/campus-recruitment.pid" ]; then
  OLD_PID="$(cat "$APP/run/campus-recruitment.pid" || true)"
  if [ -n "$OLD_PID" ]; then
    kill "$OLD_PID" 2>/dev/null || true
    sleep 2
    kill -9 "$OLD_PID" 2>/dev/null || true
  fi
  rm -f "$APP/run/campus-recruitment.pid"
fi

APP_HOME="$APP" "$APP/scripts/start-campus-recruitment.sh"

echo "7. Reload nginx"
if [ -x "$NGINX" ]; then
  "$NGINX" -t
  "$NGINX" -s reload
else
  echo "Nginx binary not found or not executable: $NGINX" >&2
fi

echo "8. Verify"
sleep 5
curl -fsS "$HEALTH_URL" >/tmp/bishe-api-check.json
if [ -f "$APP/frontend/dist/version.txt" ]; then
  cat "$APP/frontend/dist/version.txt"
fi

rm -rf "$APP/frontend/dist.old"
echo "Done: https://bishe.ryvyn.online"
