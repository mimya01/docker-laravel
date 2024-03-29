FROM php:7.2-fpm

# Copy composer.lock and composer.json
#COPY ./src/current/composer.lock ./src/current/composer.json /var/www/current/

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    default-mysql-client \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
RUN docker-php-ext-install gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 docker_carpooling
RUN useradd -u 1000 -ms /bin/bash -g docker_carpooling docker_carpooling

# Copy existing application directory contents
COPY ./src /var/www

# Copy existing application directory permissions
#COPY --chown=deployer_carpooling:deployer_carpooling ./src /var/www
#
RUN chown -R docker_carpooling:docker_carpooling /var/www
#RUN chmod 755 /var/www
#
# Change current user to docker_carpooling
USER docker_carpooling
#RUN chown -R $USER /var/www
# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
