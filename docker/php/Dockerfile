ARG PHP_VERSION=8.2
FROM ubuntu:22.04

LABEL maintainer="PHP Docker"

ARG WWWGROUP
ARG NODE_VERSION=20
ARG PHP_VERSION

WORKDIR /var/www/html

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=UTC
ENV PHP_VERSION=${PHP_VERSION}

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y \
    gnupg gosu curl ca-certificates zip unzip git supervisor sqlite3 \
    libcap2-bin libpng-dev python3 software-properties-common gettext-base \
    && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository -y ppa:ondrej/php && apt-get update

RUN apt-get install -y php${PHP_VERSION} php${PHP_VERSION}-fpm php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-pgsql php${PHP_VERSION}-sqlite3 php${PHP_VERSION}-gd php${PHP_VERSION}-curl \
    php${PHP_VERSION}-mbstring php${PHP_VERSION}-xml php${PHP_VERSION}-zip php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-intl php${PHP_VERSION}-redis php${PHP_VERSION}-imap php${PHP_VERSION}-soap \
    php${PHP_VERSION}-tidy php${PHP_VERSION}-xdebug

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
RUN apt-get install -y nodejs

RUN apt-get install -y nginx

RUN apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN groupadd --force -g $WWWGROUP sail
RUN useradd -ms /bin/bash --no-user-group -g $WWWGROUP -u 1337 sail

COPY start-container /usr/local/bin/start-container
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY php.ini /etc/php/${PHP_VERSION}/cli/conf.d/99-sail.ini
COPY php.ini /etc/php/${PHP_VERSION}/fpm/conf.d/99-sail.ini
COPY xdebug.ini /etc/php/${PHP_VERSION}/fpm/conf.d/20-xdebug.ini
COPY xdebug.ini /etc/php/${PHP_VERSION}/cli/conf.d/20-xdebug.ini
COPY fpm-env.conf /etc/php/${PHP_VERSION}/fpm/pool.d/z-env.conf
COPY nginx-default /etc/nginx/sites-available/default

RUN sed -i "s/\${PHP_VERSION}/${PHP_VERSION}/g" /etc/supervisor/supervisord.conf
RUN sed -i "s/\${PHP_VERSION}/${PHP_VERSION}/g" /etc/nginx/sites-available/default

RUN chmod +x /usr/local/bin/start-container

EXPOSE 80

ENTRYPOINT ["start-container"]
