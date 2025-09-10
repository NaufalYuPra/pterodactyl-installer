#!/bin/bash
set -e
read -rp "Domain/Subdomain: " DOMAIN
read -rp "Port (default 3000): " PORT; PORT=${PORT:-3000}
read -rp "Email LE (default admin@example.com): " EMAIL; EMAIL=${EMAIL:-admin@example.com}
/usr/local/bin/yupra-provision-domain "$DOMAIN" "$PORT" "$EMAIL"
