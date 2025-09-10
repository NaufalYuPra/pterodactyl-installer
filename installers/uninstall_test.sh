#!/bin/bash
set -e
rm -rf /var/www/pterotest
rm -f /etc/nginx/sites-available/pterotest.conf /etc/nginx/sites-enabled/pterotest.conf
systemctl restart nginx || true
echo "✅ Test Panel removed."
