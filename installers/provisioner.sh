#!/bin/bash
set -e
echo "Installing Yupra domain provision helper..."
cat >/usr/local/bin/yupra-provision-domain <<'BASH'
#!/bin/bash
set -e
DOMAIN="$1"; PORT="$2"; EMAIL="$3"
if [ -z "$DOMAIN" ] || [ -z "$PORT" ]; then echo "Usage: yupra-provision-domain <domain> <port> <email>"; exit 2; fi
cat >/etc/nginx/sites-available/yupra-$DOMAIN.conf <<NGINX
server {
    listen 80;
    server_name $DOMAIN;
    location / {
        proxy_pass http://127.0.0.1:$PORT;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINX
ln -sf /etc/nginx/sites-available/yupra-$DOMAIN.conf /etc/nginx/sites-enabled/yupra-$DOMAIN.conf
nginx -t && systemctl reload nginx
if command -v certbot >/dev/null 2>&1; then
  certbot --nginx -d "$DOMAIN" -m "${EMAIL:-admin@example.com}" --agree-tos --non-interactive --redirect || true
  systemctl reload nginx
fi
echo "OK: $DOMAIN -> 127.0.0.1:$PORT"
BASH
chmod +x /usr/local/bin/yupra-provision-domain
cat >/etc/sudoers.d/yupra-provisioner <<SUDO
www-data ALL=(ALL) NOPASSWD: /usr/local/bin/yupra-provision-domain, /usr/sbin/nginx, /bin/systemctl reload nginx, /usr/bin/certbot
SUDO
chmod 440 /etc/sudoers.d/yupra-provisioner
echo "✅ Provisioner installed."
