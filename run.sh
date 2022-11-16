#!/bin/sh

php artisan config:cache --no-interaction && php artisan view:cache --no-interaction

php-fpm &
nginx -g "daemon off;"
