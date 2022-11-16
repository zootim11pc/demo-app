FROM php:8.1.12-fpm-alpine

MAINTAINER Xiaojun


RUN apk add --update $PHPIZE_DEPS

# Setup GD extension
RUN apk add --update --no-cache \
      freetype \
      libjpeg-turbo \
      libpng \
      freetype-dev \
      libjpeg-turbo-dev \
      libpng-dev \
      nginx \
      php8-pdo_pgsql \
      libpq-dev \
      git \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-enable gd \
    && apk del --no-cache \
      freetype-dev \
      libjpeg-turbo-dev \
      libpng-dev \
    && rm -rf /tmp/* \
    && echo -e "expose_php = off" >> /usr/local/etc/php/php.ini

RUN apk add libzip-dev
RUN docker-php-ext-install pdo_pgsql zip bcmath


# add composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php composer-setup.php \
	&& php -r "unlink('composer-setup.php');" \
	&& mv composer.phar /usr/bin/composer


# nginx
RUN rm /etc/nginx/http.d/default.conf
ADD nginx.conf /etc/nginx/http.d


# laravel project
ADD . /app

# composer install
WORKDIR /app
RUN composer self-update --snapshot
RUN composer install --optimize-autoloader --no-dev && composer clear-cache

# run script
ADD run.sh /app
RUN chmod +x /app/run.sh


# change www-data's uid and gid for laravel folder permisstion
RUN apk --no-cache add shadow && \
    usermod -u 1000 www-data && \
    groupmod -g 1000 www-data


# add root to www group
RUN chmod -R ug+w /app/storage/


RUN chown -R www-data:www-data /app/bootstrap/cache \
    && chown -R www-data:www-data /app/storage \
    && chmod -R 775 /app/storage/  \
    && chmod -R 775 /app/bootstrap/cache


EXPOSE 8000

CMD ["/app/run.sh"]

#EOF
