#!/bin/bash
set -euxo pipefail

# Basic packages
dnf update -y
dnf install -y docker git

systemctl enable --now docker

# Create directories
mkdir -p /opt/moodle/{nginx,html,logs}
mkdir -p /opt/moodle/data
chmod -R 755 /opt/moodle

# Fetch docker compose file from local baked content (we'll write it to disk)
cat > /opt/moodle/docker-compose.yml <<'YML'
version: "3.8"

services:
  moodle:
    image: bitnami/moodle:latest
    ports:
      - "8080:8080"
    environment:
      - MOODLE_DATABASE_HOST=${DB_HOST}
      - MOODLE_DATABASE_USER=${DB_USER}
      - MOODLE_DATABASE_PASSWORD=${DB_PASSWORD}
      - MOODLE_DATABASE_NAME=${DB_NAME}
      - BITNAMI_DEBUG=true
      - MOODLE_USERNAME=admin
      - MOODLE_PASSWORD=Admin123!
      - MOODLE_SITE_NAME=AWS LMS
      - PHP_MEMORY_LIMIT=512M
    volumes:
      - moodledata:/bitnami/moodle
      - moodledata:/bitnami/moodledata
    restart: always

  nginx:
    image: nginx:stable
    depends_on:
      - moodle
    ports:
      - "80:80"
    volumes:
      - /opt/moodle/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
    restart: always

volumes:
  moodledata:
YML

# Minimal Nginx config to reverse-proxy to Moodle container
cat > /opt/moodle/nginx/nginx.conf <<'NGINX'
worker_processes auto;
events { worker_connections 1024; }
http {
  server {
    listen 80 default_server;
    location / {
      proxy_pass http://127.0.0.1:8080;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
    }
  }
}
NGINX

# Write env file with RDS details from instance tags or SSM (for demo, read from IMDS tags placeholder)
DB_HOST="$(curl -s http://169.254.169.254/latest/meta-data/tags/instance/DB_HOST || echo 'CHANGE_ME_DB_HOST')"
DB_USER="$(curl -s http://169.254.169.254/latest/meta-data/tags/instance/DB_USER || echo 'moodle')"
DB_PASSWORD="$(curl -s http://169.254.169.254/latest/meta-data/tags/instance/DB_PASSWORD || echo 'ChangeMe123!')"
DB_NAME="$(curl -s http://169.254.169.254/latest/meta-data/tags/instance/DB_NAME || echo 'moodle')"

cat > /opt/moodle/.env <<ENV
DB_HOST=${DB_HOST}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
DB_NAME=${DB_NAME}
ENV

# Export env vars and bring up stack
export $(grep -v '^#' /opt/moodle/.env | xargs -d '\n')
cd /opt/moodle && docker compose up -d

# Log to CWL via journald by default; optionally add CloudWatch Agent later.
