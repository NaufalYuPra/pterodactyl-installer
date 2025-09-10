#!/bin/bash
set -e
REPO_URL="https://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@github.com/NaufalYuPra/Pterodactyl.git"
SRC="/var/www/pterodactyl"
BK="$(mktemp -d)"
if [ -d "$SRC" ]; then cp -a "$SRC/.env" "$BK/.env" 2>/dev/null || true; cp -a "$SRC/storage" "$BK/storage" 2>/dev/null || true; fi
rm -rf "$SRC" && git clone "$REPO_URL" "$SRC"
cd "$SRC"
if [ -f "$BK/.env" ]; then cp -f "$BK/.env" .env; else cp .env.example .env; fi
if ! command -v composer >/dev/null 2>&1; then curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer; fi
composer install --no-dev --optimize-autoloader
php artisan key:generate --force || true
php artisan migrate --force || true
rsync -a "$BK/storage/" "$SRC/storage/" 2>/dev/null || true
chown -R www-data:www-data "$SRC"
systemctl restart pteroq || true
systemctl restart nginx || true
echo "✅ Upgrade complete (DB/Wings/Node preserved)."
