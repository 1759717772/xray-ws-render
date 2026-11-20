#!/bin/sh
set -e

PORT="${PORT:-10000}"
UUID="${UUID:-}"
WS_PATH="${WS_PATH:-/ws}"

if [ -z "$UUID" ]; then
  UUID="$(cat /proc/sys/kernel/random/uuid)"
  echo "[xray] UUID generated: $UUID"
fi

cat > /tmp/config.json <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": ${PORT},
      "protocol": "vless",
      "settings": {
        "clients": [ { "id": "${UUID}", "level": 0 } ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": { "path": "${WS_PATH}" }
      },
      "sniffing": { "enabled": true, "destOverride": ["http", "tls"] }
    }
  ],
  "outbounds": [
    { "protocol": "freedom", "settings": { "domainStrategy": "UseIPv4" } }
  ]
}
EOF

echo "[xray] listening on 0.0.0.0:${PORT}, ws path ${WS_PATH}"
exec /usr/local/bin/xray run -c /tmp/config.json
