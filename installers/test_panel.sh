#!/bin/bash
set -e
REPO_URL="https://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@github.com/NaufalYuPra/Pterodactyl.git"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y nginx mariadb-server git php php-fpm php-cli php-mysql php-mbstring php-xml php-curl php-zip php-gd php-bcmath certbot python3-certbot-nginx
[ -f /usr/local/bin/composer ] || (curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer)
DB_NAME="pterotest"; DB_USER="pterotest"; DB_PASS=$(openssl rand -hex 16)
mysql -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'127.0.0.1' IDENTIFIED BY '$DB_PASS';"
mysql -e "GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'127.0.0.1'; FLUSH PRIVILEGES;"
rm -rf /var/www/pterotest && git clone "$REPO_URL" /var/www/pterotest
cd /var/www/pterotest && cp .env.example .env
sed -i "s/DB_DATABASE=.*/DB_DATABASE=$DB_NAME/" .env
sed -i "s/DB_USERNAME=.*/DB_USERNAME=$DB_USER/" .env
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASS/" .env
composer install --no-dev --optimize-autoloader
php artisan key:generate --force
php artisan migrate --force --seed || true
php artisan migrate --force || true
chown -R www-data:www-data /var/www/pterotest
cat >/etc/nginx/sites-available/pterotest.conf <<'NGINX'
server {
    listen 8080;
    server_name _;
    root /var/www/pterotest/public;
    index index.php;
    location / { try_files $uri $uri/ /index.php?$query_string; }
    location ~ \.php$ { include snippets/fastcgi-php.conf; fastcgi_pass unix:/run/php/php-fpm.sock; }
}
NGINX
ln -sf /etc/nginx/sites-available/pterotest.conf /etc/nginx/sites-enabled/pterotest.conf
nginx -t && systemctl restart nginx
echo "✅ Test Panel up on :8080. DB: $DB_NAME user: $DB_USER pass: $DB_PASS"
