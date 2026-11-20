#!/bin/sh
set -eu

cd /var/www/html

sed -i "s/__PORT__/${PORT:-10000}/" /etc/nginx/sites-available/default

if [ "${DB_CONNECTION:-sqlite}" = "sqlite" ]; then
    touch database/database.sqlite
    chown www-data:www-data database/database.sqlite
fi

php artisan config:cache
php artisan view:cache
php artisan migrate --force

php-fpm -D
exec nginx -g 'daemon off;'
