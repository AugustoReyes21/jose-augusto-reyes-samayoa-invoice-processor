#!/bin/sh
set -eu

CERT_DIR="/etc/nginx/certs"
CERT_PATH="${CERT_DIR}/server.crt"
KEY_PATH="${CERT_DIR}/server.key"
PUBLIC_IP="${PUBLIC_IP:-}"
SERVER_NAME="_"
CERT_HOST="localhost"
CERT_ALT_NAMES="DNS:localhost,DNS:nginx,DNS:localhost.localdomain,IP:127.0.0.1"

if [ -n "${PUBLIC_IP}" ]; then
  CERT_HOST="${PUBLIC_IP}"
  CERT_ALT_NAMES="${CERT_ALT_NAMES},IP:${PUBLIC_IP}"
fi

mkdir -p "${CERT_DIR}"

if [ ! -f "${CERT_PATH}" ] || [ ! -f "${KEY_PATH}" ]; then
  openssl req \
    -x509 \
    -nodes \
    -newkey rsa:2048 \
    -days 365 \
    -keyout "${KEY_PATH}" \
    -out "${CERT_PATH}" \
    -subj "/CN=${CERT_HOST}" \
    -addext "subjectAltName=${CERT_ALT_NAMES}"
fi

cat >/etc/nginx/conf.d/default.conf <<EOF
map \$http_upgrade \$connection_upgrade {
    default upgrade;
    '' close;
}

server {
    listen 80;
    listen [::]:80;
    server_name ${SERVER_NAME};
    client_max_body_size 20m;
    server_tokens off;

    location / {
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${SERVER_NAME};
    client_max_body_size 20m;
    server_tokens off;

    ssl_certificate ${CERT_PATH};
    ssl_certificate_key ${KEY_PATH};
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers off;

    location = /api {
        return 301 /api/;
    }

    location /api/ {
        proxy_pass http://api:3001/;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
    }

    location / {
        proxy_pass http://webapp:3000;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
    }
}
EOF

nginx -t
exec nginx -g "daemon off;"
