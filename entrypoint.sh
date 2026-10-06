#!/bin/sh
set -e

: "${UUID:?UUID env var is required}"
PORT="${PORT:-8080}"
APP_PATH="${APP_PATH:-/ws}"

# Basic sanity checks so a typo doesn't produce broken JSON
echo "$UUID" | grep -Eq '^[0-9a-fA-F-]{36}$' || { echo "invalid UUID: $UUID" >&2; exit 1; }
echo "$PORT" | grep -Eq '^[0-9]+$' || { echo "invalid PORT: $PORT" >&2; exit 1; }
echo "$APP_PATH" | grep -Eq '^/[A-Za-z0-9._~/-]*$' || { echo "invalid APP_PATH (must start with /): $APP_PATH" >&2; exit 1; }

cat > /tmp/config.json <<JSON
{
  "log": {"loglevel": "warning"},
  "inbounds": [{
    "listen": "0.0.0.0",
    "port": ${PORT},
    "protocol": "vless",
    "settings": {"clients": [{"id": "${UUID}"}], "decryption": "none"},
    "streamSettings": {"network": "ws", "wsSettings": {"path": "${APP_PATH}"}}
  }],
  "outbounds": [{"protocol": "freedom"}]
}
JSON

echo "web-runtime: listening on 0.0.0.0:${PORT}, path ${APP_PATH}"
exec /usr/local/bin/xray run -c /tmp/config.json
