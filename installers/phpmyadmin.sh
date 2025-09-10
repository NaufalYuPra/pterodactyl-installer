#!/bin/bash
set -e
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y phpmyadmin
ln -sf /usr/share/phpmyadmin /var/www/html/pma || true
systemctl restart nginx || true
echo "✅ phpMyAdmin at http://SERVER_IP/pma"
