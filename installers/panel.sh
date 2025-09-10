#!/bin/bash
set -e
REPO_URL="https://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@github.com/NaufalYuPra/Pterodactyl.git"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y software-properties-common curl ca-certificates gnupg lsb-release
apt-get install -y nginx mariadb-server redis-server tar unzip git ufw certbot python3-certbot-nginx
apt-get install -y php php-cli php-fpm php-mysql php-mbstring php-xml php-curl php-zip php-gd php-bcmath
if ! command -v composer >/dev/null 2>&1; then curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer; fi
DB_NAME="pterodactyl"; DB_USER="pterodactyl"; DB_PASS=$(openssl rand -hex 16)
mysql -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'127.0.0.1' IDENTIFIED BY '$DB_PASS';"
mysql -e "GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'127.0.0.1'; FLUSH PRIVILEGES;"
rm -rf /var/www/pterodactyl && git clone "$REPO_URL" /var/www/pterodactyl
cd /var/www/pterodactyl && cp .env.example .env
sed -i "s/DB_DATABASE=.*/DB_DATABASE=$DB_NAME/" .env
sed -i "s/DB_USERNAME=.*/DB_USERNAME=$DB_USER/" .env
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASS/" .env
composer install --no-dev --optimize-autoloader
php artisan key:generate --force
php artisan migrate --force --seed
php artisan migrate --force || true
chown -R www-data:www-data /var/www/pterodactyl
find /var/www/pterodactyl -type f -exec chmod 0644 {} \;
find /var/www/pterodactyl -type d -exec chmod 0755 {} \;
cat >/etc/nginx/sites-available/pterodactyl.conf <<'NGINX'
server {
    listen 80;
    server_name _;
    root /var/www/pterodactyl/public;
    index index.php;
    location / { try_files $uri $uri/ /index.php?$query_string; }
    location ~ \.php$ { include snippets/fastcgi-php.conf; fastcgi_pass unix:/run/php/php-fpm.sock; }
    location ~* \.(?:ico|css|js|gif|jpe?g|png)$ { expires max; log_not_found off; }
}
NGINX
ln -sf /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf
nginx -t && systemctl restart nginx
cat >/etc/systemd/system/pteroq.service <<'SRV'
[Unit]
Description=Pterodactyl Queue Worker
After=redis-server.service
[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/pterodactyl/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
[Install]
WantedBy=multi-user.target
SRV
systemctl daemon-reload && systemctl enable --now pteroq
echo "✅ Panel installed. DB: $DB_NAME user: $DB_USER pass: $DB_PASS"
