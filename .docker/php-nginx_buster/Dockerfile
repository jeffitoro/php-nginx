FROM php:fpm-buster


ENV XDEBUG="true"

ENV TZ='Europe/Brussels'
# ENV TZ='Pacific/Kiritimati'

RUN echo $TZ > /etc/timezone && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean

RUN apt-get update && \
    apt-get install -y \
    libmemcached-dev \
    libz-dev \
    libpq-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libssl-dev \
    libmcrypt-dev \
    openssh-server \
    libmagickwand-dev \
    git \
    cron \
    vim \
    libxml2-dev \
    libzip-dev \
    zip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    nginx \
    vim
# && docker-php-ext-configure gd --with-freetype --with-jpeg \
# && docker-php-ext-install -j$(nproc) gd

# Install soap extention
RUN docker-php-ext-install soap

# Install for image manipulation
RUN docker-php-ext-install exif

# Install the PHP mcrypt extention (from PECL, mcrypt has been removed from PHP 7.2)
RUN pecl install mcrypt
RUN docker-php-ext-enable mcrypt

# Install the PHP pcntl extention
RUN docker-php-ext-install pcntl

# Install the PHP zip extention
# RUN docker-php-ext-configure zip --with-libzip
RUN docker-php-ext-install zip

# Install the PHP pdo_mysql extention
RUN docker-php-ext-install pdo_mysql

# Install the PHP pdo_pgsql extention
RUN docker-php-ext-install pdo_pgsql

# Install the PHP bcmath extension
RUN docker-php-ext-install bcmath

RUN docker-php-ext-install sockets

#####################################
# Imagick:
#####################################

RUN pecl install imagick && \
    docker-php-ext-enable imagick

#####################################
# GD:
#####################################

# Install the PHP gd library
RUN apt install -y \
 libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd
# RUN docker-php-ext-install gd && \
#     docker-php-ext-configure gd \
#     --enable-gd-native-ttf \
#     --with-jpeg-dir=/usr/lib \
#     --with-freetype-dir=/usr/include/freetype2 && \
#     docker-php-ext-install gd

#####################################
# xDebug:
#####################################

# Install the xdebug extension
# RUN pecl install xdebug && docker-php-ext-enable xdebug
RUN yes | pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_handler=dbgp" >>  /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_port=9000" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_connect_back=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.idekey=docker" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_log=/var/log/xdebug.log" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.default_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini
# Copy xdebug configration for remote debugging
# COPY ./.docker/php-nginx_buster/config/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

#####################################
# PHP Memcached:
#####################################

# Install the php memcached extension
RUN pecl install memcached && docker-php-ext-enable memcached

#####################################
# Composer:
#####################################

# Install composer and add its bin to the PATH.
RUN curl -s http://getcomposer.org/installer | php && \
    echo "export PATH=${PATH}:/var/www/html/laravel/vendor/bin" >> ~/.bashrc && \
    mv composer.phar /usr/local/bin/composer
# Source the bash
RUN . ~/.bashrc

#####################################
# Laravel Schedule Cron Job:
#####################################

RUN echo "* * * * * root /usr/local/bin/php /var/www/html/laravel/artisan schedule:run >> /dev/null 2>&1"  >> /etc/cron.d/laravel-scheduler
RUN chmod 0644 /etc/cron.d/laravel-scheduler

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

ADD ./.docker/php-nginx_buster/config/laravel.ini /usr/local/etc/php/conf.d

RUN sed -i -e 's/pm = .+?/pm = dynamic/' \
 -e 's/pm\.max_children = \d/pm\.max_children = 70/' \
 -e 's/pm\.start_servers = \d/pm\.start_servers = 20/' \
 -e 's/pm\.min_spare_servers = \d/pm\.min_spare_servers = 20/' \
 -e 's/pm\.max_spare_servers = \d/pm\.max_spare_servers = 35/' \
 -e 's/pm\.max_requests = \d/pm\.max_requests = 500/' \
 -e 's/pm\.process_idle_timeout = .+?/pm\.process_idle_timeout = 10s/' \
 /usr/local/etc/php-fpm.d/www.conf


#####################################
# Aliases:
#####################################
# docker-compose exec php-fpm dep --> locally installed Deployer binaries
# RUN echo '#!/bin/bash\n/usr/local/bin/php /var/www/vendor/bin/dep "$@"' > /usr/bin/dep
# RUN chmod +x /usr/bin/dep
# docker-compose exec php-fpm art --> php artisan
# RUN echo '#!/bin/bash\n/usr/local/bin/php /var/www/artisan "$@"' > /usr/bin/art
# RUN chmod +x /usr/bin/art
# docker-compose exec php-fpm migrate --> php artisan migrate
# RUN echo '#!/bin/bash\n/usr/local/bin/php /var/www/artisan migrate "$@"' > /usr/bin/migrate
# RUN chmod +x /usr/bin/migrate
# docker-compose exec php-fpm fresh --> php artisan migrate:fresh --seed
# RUN echo '#!/bin/bash\n/usr/local/bin/php /var/www/artisan migrate:fresh --seed' > /usr/bin/fresh
# RUN chmod +x /usr/bin/fresh
# docker-compose exec php-fpm t --> run the tests for the project and generate testdox
# RUN echo '#!/bin/bash\n/usr/local/bin/php /var/www/artisan config:clear\n/var/www/vendor/bin/phpunit -d memory_limit=2G --stop-on-error --stop-on-failure --testdox-text=tests/report.txt "$@"' > /usr/bin/t
# RUN chmod +x /usr/bin/t
# docker-compose exec php-fpm d --> run the Laravel Dusk browser tests for the project
# RUN echo '#!/bin/bash\n/usr/local/bin/php /var/www/artisan config:clear\n/bin/bash\n/usr/local/bin/php /var/www/artisan dusk -d memory_limit=2G --stop-on-error --stop-on-failure --testdox-text=tests/report-dusk.txt "$@"' > /usr/bin/d
# RUN chmod +x /usr/bin/d


# COPY ./.docker/php-nginx_buster/config/docker-entrypoint.sh /usr/local/bin/
# RUN chmod +x /usr/local/bin/docker-entrypoint.sh
# RUN ln -s /usr/local/bin/docker-entrypoint.sh /
# RUN /bin/bash docker-entrypoint.sh
# ENTRYPOINT ["docker-entrypoint.sh"]

#####################################
# Node installation node
#####################################
# Using Debian, as root
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install nodejs -y
RUN npm install npm

RUN rm -r /var/lib/apt/lists/*
RUN usermod -u 1000 www-data


#######################################
# NGINX:
#######################################
COPY ./.docker/php-nginx_buster/config/default.conf /etc/nginx/sites-available/default
COPY ./.docker/php-nginx_buster/config/start.sh /

COPY --chown=www-data:www-data ./ /var/www/html/laravel

EXPOSE 80 443 6001

ADD ./.docker/php-nginx_buster/config/start.sh /start.sh
RUN chmod 755 /start.sh

WORKDIR /var/www/html/laravel

ENTRYPOINT [ "sh", "/start.sh"]