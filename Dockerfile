#Use Debian 11.3.
FROM php:8.1.17-fpm-bullseye

# LABEL org.opencontainers.image.authors="github@diouxx.be"

#Don't prompt during installation.
ENV DEBIAN_FRONTEND noninteractive

#Installation of PHP 8.1.
RUN apt-get update \ 
&& apt-get -y install apt-transport-https lsb-release ca-certificates curl \
# && curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg \ 
# && sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list' \
&& apt-get update

#Installation of Apache and PHP 8.1 with extensions.
RUN apt install --yes --no-install-recommends \
apache2 \
# php8.1 \
# php8.1-mysql \
# php7.1-ldap \
# php8.1-xmlrpc \
# php8.1-imap \
# php8.1-curl \
# php7.1-gd \
# php8.1-mbstring \
# php8.1-xml \
# php8.1-apcu-bc \
# php-cas \
# php8.1-intl \
# php8.1-zip \
# php8.1-bz2 \
cron \
wget \
ca-certificates \
jq \
libldap-2.4-2 \
libldap-common \
libsasl2-2 \
libsasl2-modules \
libsasl2-modules-db \
&& rm -rf /var/lib/apt/lists/*

#Copying and running the script for the installation and initialization of GLPI.
COPY glpi-start.sh /opt/
RUN chmod +x /opt/glpi-start.sh
ENTRYPOINT ["sh","/opt/glpi-start.sh"]

#Exposing ports.
EXPOSE 80 443
