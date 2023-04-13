FROM php:8.0-fpm-alpine

LABEL org.opencontainers.image.authors="github@oneiric.com.au"

# Set timezone 
RUN apk --no-cache add tzdata \
    && ln -sf /usr/share/zoneinfo/Australia/Sydney /etc/localtime \
    && echo "Australia/Sydney" > /etc/timezone
    

# Install dependencies 
RUN apk --no-cache add libxml2-dev libpng libjpeg-turbo freetype libpq libldap icu-libs \
    && apk --no-cache add --virtual .build-deps $PHPIZE_DEPS libpng-dev libjpeg-turbo-dev freetype-dev libpq-dev libldap openldap-dev icu-dev \
     && docker-php-ext-configure gd --with-freetype --with-jpeg \
     && docker-php-ext-install -j$(nproc) gd pdo pdo_pgsql pgsql ldap intl xml soap opcache \
     && pecl install apcu \ && docker-php-ext-enable apcu \
     && apk del .build-deps 
     
# Download and install GLPI
ENV GLPI_VERSION=10.0.7
RUN curl -L -o /tmp/glpi.tar.gz "https://github.com/glpi-project/glpi/releases/download/$GLPI_VERSION/glpi-$GLPI_VERSION.tgz" \
    && tar xfz /tmp/glpi.tar.gz -C /var/www/ \
    && rm /tmp/glpi.tar.gz \
    && chown -R www-data:www-data /var/www/glpi \
    && chmod -R 750 /var/www/glpi \
    && find /var/www/glpi -type d -exec chmod 770 {} +

# Configure web server root directory to not allow non-public file access
COPY glpi.conf /etc/apache2/conf.d/

# Set GLPI configuration options 
COPY glpi-config.php /var/www/glpi/config/

# Remove install.php
RUN rm /var/www/glpi/install/install.php

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm", "-F"]