FROM ubuntu:16.04

MAINTAINER Mathieu Alorent <hub.docker@kumy.net>

ENV DEBIAN_FRONTEND noninteractive

# Install php7-cli
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		php-fpm \
		php-cli \
		php-xml \
		php-zip \
		php-curl \
		php-mysql \
		php-json \
		php-gd \
		ca-certificates \
		vim \
		net-tools \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
        && echo "date.timezone = UTC" > /etc/php/php.ini \
        && mkdir /run/php \
        && ln -s /dev/stderr /var/log/php7.0-fpm.log

COPY fpm/php-fpm.conf /etc/php/7.0/fpm/
COPY fpm/php.ini /etc/php/7.0/fpm/
COPY fpm/pool.d/www.conf /etc/php/7.0/fpm/pool.d/

ADD gkm /var/www/html

EXPOSE 9000

CMD ["/usr/sbin/php-fpm7.0", "--nodaemonize", "--fpm-config", "/etc/php/7.0/fpm/php-fpm.conf"]
