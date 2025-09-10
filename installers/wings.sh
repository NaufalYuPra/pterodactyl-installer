#!/bin/bash
set -e
if ! command -v docker >/dev/null 2>&1; then curl -fsSL https://get.docker.com | bash && systemctl enable --now docker; fi
mkdir -p /etc/pterodactyl /var/lib/pterodactyl
curl -L -o /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64
chmod +x /usr/local/bin/wings
cat >/etc/systemd/system/wings.service <<'SRV'
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service
[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
ExecStart=/usr/local/bin/wings
Restart=on-failure
[Install]
WantedBy=multi-user.target
SRV
systemctl daemon-reload && systemctl enable wings
systemctl restart wings || true
echo "✅ Wings installed. Paste config.yml to /etc/pterodactyl/config.yml"
