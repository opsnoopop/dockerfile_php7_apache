FROM php:7.4.1-apache

ARG USE_C_PROTOBUF=true

# Install vim
RUN apt-get update && apt-get install -y vim

# Install xml
RUN apt-get update && apt-get install -y libxml2

# Install zip
RUN apt-get update && apt-get install -y zlib1g-dev libzip-dev
RUN docker-php-ext-configure zip
RUN docker-php-ext-install zip

# Install git
RUN apt-get update && apt-get install -y git

# Install unzip
RUN apt-get update && apt-get install -y unzip

# Install PHP extension(s) required for development.
RUN docker-php-ext-install bcmath

# Install and configure Composer.
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

# Install and configure the gRPC extension. pecl.php.net
RUN pecl install grpc
RUN echo 'extension=grpc.so' >> $PHP_INI_DIR/conf.d/grpc.ini

# Install and configure the C implementation of Protobuf extension if needed.
RUN if [ "$USE_C_PROTOBUF" = "false" ]; then echo 'Using PHP implementation of Protobuf'; else echo 'Using C implementation of Protobuf'; pecl install protobuf; echo 'extension=protobuf.so' >> $PHP_INI_DIR/conf.d/protobuf.ini; fi

# Install gd
RUN apt-get update && apt-get install -y libgd-dev
# for php <= 7.3.9
#RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
# for php >= 7.4
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/
RUN docker-php-ext-install gd

# Install imagick pecl.php.net
RUN apt-get update && apt-get install -y libmagickwand-dev --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN pecl install imagick
RUN docker-php-ext-enable imagick

# Install mongodb pecl.php.net
RUN apt-get update && apt-get install -y libcurl4-openssl-dev pkg-config libssl-dev
RUN pecl install mongodb
RUN docker-php-ext-enable mongodb

# Install mysqli
RUN docker-php-ext-install mysqli

# Install pdo_mysql
RUN docker-php-ext-install pdo_mysql

# Install pdo_pgsql
RUN apt-get update && apt-get install -y libpq-dev
RUN docker-php-ext-install pdo_pgsql

# Install soap
RUN apt-get update && apt-get install -y libxml2-dev
RUN docker-php-ext-install soap

# Install mod_rewrite and mod_headers
RUN a2enmod rewrite headers

# Install sockets
RUN docker-php-ext-install sockets

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_13.x | bash
RUN apt-get install -y nodejs

# Install yarn
RUN curl -o- -L https://yarnpkg.com/install.sh | bash

# Install redis
RUN pecl install redis
RUN docker-php-ext-enable redis

# Install xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    # host.docker.internal does not work on Linux yet: https://github.com/docker/for-linux/issues/264
    # Workaround:
    # ip -4 route list match 0/0 | awk '{print $3 " host.docker.internal"}' >> /etc/hosts \
    && echo "xdebug.remote_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# An IDE key has to be set, but anything works, at least for PhpStorm and VS Code...
ENV XDEBUG_CONFIG="xdebug.idekey=''"

# Remove after install
RUN apt-get -y autoremove
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
