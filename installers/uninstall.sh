#!/bin/bash
set -e
echo "1) Remove Panel"
echo "2) Remove Wings"
read -rp "Choose [1-2]: " opt
case "$opt" in
  1) systemctl disable --now pteroq || true
     rm -rf /var/www/pterodactyl
     rm -f /etc/nginx/sites-enabled/pterodactyl.conf /etc/nginx/sites-available/pterodactyl.conf
     systemctl restart nginx || true
     echo "✅ Panel removed." ;;
  2) systemctl disable --now wings || true
     rm -f /etc/systemd/system/wings.service
     rm -rf /etc/pterodactyl /var/lib/pterodactyl /usr/local/bin/wings
     systemctl daemon-reload
     echo "✅ Wings removed." ;;
  *) echo "Invalid" ;;
esac
