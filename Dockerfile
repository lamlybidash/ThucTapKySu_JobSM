#Sử dụng PHP 8.2 + extensions cần
FROM php:8.2-fpm

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    libpq-dev \
    libonig-dev \
    libssl-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libicu-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev\
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    opcache \
    intl \
    zip \
    bcmath \
    soap \
    gd\
    && pecl install redis xdebug \
    && docker-php-ext-enable redis xdebug\
    && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Cài extensions cho laravel
RUN docker-php-ext-install pdo mbstring exif pcntl


#Cài Composer
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

#Đặt thư mục làm việc (Set working dir)
WORKDIR /var/www

# Copy composer files trước
COPY composer.json composer.lock ./

#Cài dependencies
RUN composer install --no-dev --optimize-autoloader --no-scripts

#Copy code vào container
COPY . .

# Gọi artisan
RUN composer dump-autoload --optimize && php artisan package:discover --ansi || true

#Set quyèn cho storage & butstrap/cache
RUN chown -R www-data:www-data storage bootstrap/cache && chmod -R 775 storage bootstrap/cache

#Tăng giới hạn ảnh lưu trữ
RUN echo "upload_max_filesize=100M" > /usr/local/etc/php/conf.d/uploads.ini && echo "post_max_size=100M" >> /usr/local/etc/php/conf.d/uploads.ini