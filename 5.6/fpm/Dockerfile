FROM debian:jessie

# php
ENV GPG_KEYS 6E4F6AB321FDC07F2C332E3AC2BF0BC433CFC8B3
ENV PHP_VERSION 5.6.35
ENV PHP_FILENAME php-${PHP_VERSION}.tar.xz
ENV PHP_SHA256 9985cb64cb8224c289effff5b34f670d14f838175f76daea0507d643eec650d2
ENV PHP_INI_DIR /usr/local/etc/php
ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data

# xdebug (2.5.5 is the latest version with PHP 5.6 support)
ENV PHP_XDEBUG_VERSION 2.5.5
ENV PHP_XDEBUG_ENABLED false

# phpredis
# Set the latest commit of the stable branch in https://github.com/phpredis/phpredis
ENV PHPREDIS_COMMIT 4.0.0

RUN apt-get update && apt-get install -y \

        # phpize deps
		autoconf \
		file \
		g++ \
		gcc \
		libc-dev \
		libcurl3 \
		make \
		pkg-config \
		re2c \

		# persistent / runtime deps
		ca-certificates \
        curl \
        libedit2 \
        libsqlite3-0 \
        libxml2 \

	    --no-install-recommends && rm -r /var/lib/apt/lists/* \
	&& mkdir -p $PHP_INI_DIR/conf.d

RUN set -xe \
	&& buildDeps=" \
		$PHP_EXTRA_BUILD_DEPS \
		libcurl4-openssl-dev \
		libedit-dev \
		libsqlite3-dev \
		libssl-dev \
		libxml2-dev \
		xz-utils \
		unzip \
	" \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	&& curl -fSL "http://php.net/get/$PHP_FILENAME/from/this/mirror" -o "$PHP_FILENAME" \
	&& echo "$PHP_SHA256 *$PHP_FILENAME" | sha256sum -c - \
	&& curl -fSL "http://php.net/get/$PHP_FILENAME.asc/from/this/mirror" -o "$PHP_FILENAME.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& for key in $GPG_KEYS; do \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	done \
	&& gpg --batch --verify "$PHP_FILENAME.asc" "$PHP_FILENAME" \
	&& rm -r "$GNUPGHOME" "$PHP_FILENAME.asc" \
	&& mkdir -p /usr/src/php \
	&& tar -xf "$PHP_FILENAME" -C /usr/src/php --strip-components=1 \
	&& rm "$PHP_FILENAME" \
	&& cd /usr/src/php \
	&& ./configure \
		--with-config-file-path="$PHP_INI_DIR" \
		--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
		$PHP_EXTRA_CONFIGURE_ARGS \
		--disable-cgi \
# --enable-mysqlnd is included here because it's harder to compile after the fact than extensions are (since it's a plugin for several extensions, not an extension in itself)
		--enable-mysqlnd \
# --enable-mbstring is included here because otherwise there's no way to get pecl to use it properly (see https://github.com/docker-library/php/issues/195)
		--enable-mbstring \
		--with-curl \
		--with-libedit \
		--with-openssl \
		--with-zlib \
	&& make -j"$(nproc)" \
	&& make install \
	&& { find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; } \
	&& make clean \

	# Download phpredis sources into /usr/src/php/ext to make it installable via docker-php-ext-install.
    && curl -fSL -o /tmp/phpredis.zip https://github.com/phpredis/phpredis/archive/${PHPREDIS_COMMIT}.zip \
    && unzip /tmp/phpredis.zip \
    && rm -r /tmp/phpredis.zip \
    && mv phpredis-${PHPREDIS_COMMIT} /usr/src/php/ext/redis \

	# Cleanup apt
	&& apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $buildDeps \
	&& apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## Install xdebug
RUN pecl install xdebug-${PHP_XDEBUG_VERSION} \
    && pecl clear-cache \
    && rm -rf /tmp/pear/download/*

WORKDIR /var/www/html

RUN set -ex \
	&& cd /usr/local/etc \
	&& if [ -d php-fpm.d ]; then \
		# for some reason, upstream's php-fpm.conf.default has "include=NONE/etc/php-fpm.d/*.conf"
		sed 's!=NONE/!=!g' php-fpm.conf.default | tee php-fpm.conf > /dev/null; \
		cp php-fpm.d/www.conf.default php-fpm.d/www.conf; \
	else \
		# PHP 5.x don't use "include=" by default, so we'll create our own simple config that mimics PHP 7+ for consistency
		mkdir php-fpm.d; \
		cp php-fpm.conf.default php-fpm.d/www.conf; \
		{ \
			echo '[global]'; \
			echo 'include=etc/php-fpm.d/*.conf'; \
		} | tee php-fpm.conf; \
	fi \
	&& { \
		echo '[global]'; \
		echo 'error_log = /proc/self/fd/2'; \
		echo; \
		echo '[www]'; \
		echo '; if we send this to /proc/self/fd/1, it never appears'; \
		echo 'access.log = /proc/self/fd/2'; \
		echo; \
		echo 'clear_env = no'; \
		echo; \
		echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
		echo 'catch_workers_output = yes'; \
	} | tee php-fpm.d/docker.conf \
	&& { \
		echo '[global]'; \
		echo 'daemonize = no'; \
		echo; \
		echo '[www]'; \
		echo 'listen = [::]:9000'; \
	} | tee php-fpm.d/zz-docker.conf

# Rename original php binary to php-cli and replace it with an shell script wrapper.
COPY docker-php-ext-* *.sh settings.php /usr/local/bin/
RUN mv /usr/local/bin/php /usr/local/bin/php-cli \
    && mv /usr/local/bin/php.sh /usr/local/bin/php \
    && chmod +x /usr/local/bin/php \
    && chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 9000
ENTRYPOINT ["docker-entrypoint.sh"]
