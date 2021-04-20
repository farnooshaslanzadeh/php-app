FROM php:5.6.30-fpm-alpine
RUN apk update && apk add build-base postgresql postgresql-dev
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
RUN docker-php-ext-install pdo pdo_pgsql pgsql
RUN apk add zlib-dev git zip
RUN docker-php-ext-install zip && 
    \curl -sS https://getcomposer.org/installer | php &&
    \mv composer.phar /usr/local/bin/ && 
    \ln -s /usr/local/bin/composer.phar /usr/local/bin/composer
COPY . /app
WORKDIR /app
RUN composer install --prefer-source --no-interaction
ENV PATH="~/.composer/vendor/bin:./vendor/bin:${PATH}"
