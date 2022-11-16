#!/bin/sh

php artisan config:cache --no-interaction && php artisan view:cache --no-interaction && php artisan route:cache

php-fpm &
nginx -g "daemon off;"
