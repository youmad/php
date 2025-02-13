ENV COMPOSER_VERSION 1.10.7
ENV COMPOSER_HOME /home/user
ENV COMPOSER_ALLOW_SUPERUSER 1

RUN set -xe \
    && mkdir -p ${COMPOSER_HOME} \
    && php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');" \
    && php -r "if(hash_file('SHA384','/tmp/composer-setup.php')==='e0012edf3e80b6978849f5eff0d4b4e4c79ff1609dd1e613307e16318854d24ae64f26d17af3ef0bf7cfb710ca74755a'){echo 'Verified';}else{unlink('/tmp/composer-setup.php');}" \
    && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/bin --filename=composer --version=$COMPOSER_VERSION \
    && composer global require 'hirak/prestissimo' --no-interaction --no-suggest --prefer-dist \
    && composer clear-cache \
    && rm -r /tmp/composer-setup.php ${COMPOSER_HOME}/.htaccess ${COMPOSER_HOME}/cache
