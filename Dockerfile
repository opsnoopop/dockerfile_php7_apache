FROM php:7.2-apache

ARG USE_C_PROTOBUF=true

# Install vim
RUN apt-get update && apt-get install -y vim

# Install xml
RUN apt-get update && apt-get install -y libxml2

# Install zip
RUN apt-get update && apt-get install -y libzip-dev libzip4 zlib1g-dev
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

# Install and configure the C implementation of Protobuf extension if needed. v.3.13.0
RUN if [ "$USE_C_PROTOBUF" = "false" ]; then echo 'Using PHP implementation of Protobuf'; else echo 'Using C implementation of Protobuf'; pecl install protobuf; echo 'extension=protobuf.so' >> $PHP_INI_DIR/conf.d/protobuf.ini; fi

# Install gd
RUN apt-get update && apt-get install -y libgd-dev
RUN apt-get install -y libwebp-dev
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-webp-dir=/usr/include/
RUN docker-php-ext-install gd

# Install imagick pecl.php.net
RUN apt-get update && apt-get install -y libmagickwand-dev --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN pecl install imagick
RUN docker-php-ext-enable imagick

# Install mongodb pecl.php.net
RUN apt-get update && apt-get install -y libcurl4-openssl-dev pkg-config libssl-dev
RUN pecl install mongodb-1.16.2
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
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash
RUN apt-get install -y nodejs

# Install yarn
RUN curl -o- -L https://yarnpkg.com/install.sh | bash

# Install memcached
RUN apt-get update -y && apt-get install -y libz-dev libmemcached-dev memcached libmemcached-tools
RUN pecl install memcached
RUN docker-php-ext-enable memcached

# Install redis
RUN pecl install redis
RUN docker-php-ext-enable redis

# Install intl for numberformatter 
RUN apt-get install -y zlib1g-dev libicu-dev g++
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl

# Install diseval
#RUN git clone https://github.com/mk-j/PHP_diseval_extension && \
# cd PHP_diseval_extension/source && \
# phpize && \
# ./configure && \
# make && \
# make install && \
# docker-php-ext-enable diseval

# Install locales-all
RUN apt-get update && apt-get install -y locales locales-all
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Install exif
RUN apt-get update && apt-get install -y exiftool
RUN docker-php-ext-configure exif
RUN docker-php-ext-install exif
RUN docker-php-ext-enable exif

# Install pngquant for compress png
RUN apt-get update && apt-get install -y pngquant

# Install webp for convert .webp e.g cwebp, gif2webp
RUN apt-get update && apt-get install -y webp

# Install opcache
RUN docker-php-ext-install opcache

# Remove after install
RUN apt-get -y autoremove
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
