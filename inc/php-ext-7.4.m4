# Deps required for running "phpize". These get automatically installed and
# removed by "docker-php-ext-*" (unless they're already installed)
ENV PHPIZE_DEPS \
    autoconf \
    cmake \
    file \
    g++ \
    gcc \
    git \
    libc-dev \
    make \
    openssl-dev \
    pcre-dev \
    pkgconf \
    re2c \
    # For GD
    freetype-dev \
    libpng-dev  \
    libjpeg-turbo-dev \
    # For intl extension
    icu-dev \
    # For xslt
    libxslt-dev \
    # For zip
    libzip-dev \
    zlib-dev

# Persistent / runtime deps
RUN apk add --no-cache --virtual .persistent-deps \
    acl \
    file \
    git \
    libgcrypt \
    # For bz2
    bzip2-dev \
    # For amqp
    libressl-dev \
    # For GD
    freetype \
    libpng \
    libjpeg-turbo \
    # For intl extension
    gettext \
    gettext-dev \
    icu-libs \
    # For mbstring
    oniguruma-dev \
    # For postgres
    postgresql-dev \
    # For soap
    libxml2-dev \
    # For xslt
    libxslt \
    # For zip
    libzip

# For iconv - https://github.com/docker-library/php/issues/240#issuecomment-305038173
RUN apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing gnu-libiconv
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

ARG APCU_VERSION=5.1.18
RUN set -xe \
    # Workaround for rabbitmq linking issue
    && ln -s /usr/lib /usr/local/lib64 \
    # Hack to link libgcrypt
    && ln -s /usr/lib/libgcrypt.so.20 /usr/lib/libgcrypt.so \
    && ln -s /usr/lib/libgpg-error.so.0 /usr/lib/libgpg-error.so \
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
    && docker-php-ext-configure bcmath --enable-bcmath \
    && docker-php-ext-configure gettext --with-gettext \
    && docker-php-ext-configure gd \
        --enable-gd \
        --with-freetype=/usr/include/ \
        --with-jpeg=/usr/include/ \
    && docker-php-ext-configure intl --enable-intl \
    && docker-php-ext-configure mbstring --enable-mbstring \
    && docker-php-ext-configure mysqli --with-mysqli \
    && docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql \
    && docker-php-ext-configure pdo_pgsql --with-pdo-pgsql \
    && docker-php-ext-configure soap --enable-soap \
    && docker-php-ext-configure zip --with-zip \
    && docker-php-ext-install -j$(nproc) \
        bcmath \
        bz2 \
        gettext \
        gd \
        iconv \
        intl \
        mbstring \
        mysqli \
        opcache \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        soap \
        xsl \
        zip \
    && pecl install apcu-${APCU_VERSION} \
    && pecl clear-cache \
    && docker-php-ext-enable \
        apcu \
    && runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
        )" \
    && apk add --no-cache --virtual .phpexts-rundeps $runDeps

# Copy configuration
COPY config/php7.ini /usr/local/etc/php/conf.d/
