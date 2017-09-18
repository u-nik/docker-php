#!/usr/bin/env bash

# Xdebug settings
export PHP_XDEBUG_ENABLED=${PHP_XDEBUG_ENABLED:-false}
export PHP_XDEBUG_REMOTE_HOST=${PHP_XDEBUG_REMOTE_HOST:-"localhost"}
export PHP_XDEBUG_IDEKEY=${PHP_XDEBUG_IDEKEY:-"dockerizr-php"}

# Default INI settings.
export PHP_INI_MEMORY_LIMIT=${PHP_INI_MEMORY_LIMIT:-1G}

# Create on demand php settings.
defaultSettings=$(php-cli /usr/local/bin/settings.php)

if ${PHP_XDEBUG_ENABLED}; then

    # PHPStorm ide config
    export PHP_IDE_CONFIG="serverName=docker"

    if [ "$PHP_XDEBUG_REMOTE_HOST" = "localhost" ]; then
        echo "INFO: No remote host for xdebug found. Use PHP_XDEBUG_REMOTE_HOST env variable to set it"
    fi

    exec php-fpm \
        -dzend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20131226/xdebug.so \
        -dhtml_errors=false \
        -dxdebug.remote_enable=1 \
        -dxdebug.remote_autostart=1 \
        -dxdebug.remote_connect_back=0 \
        -dxdebug.remote_host=$PHP_XDEBUG_REMOTE_HOST \
        -dxdebug.idekey=$PHP_XDEBUG_IDEKEY \
        -dxdebug.default_enable=off ${defaultSettings} \
        "$@"

else
    exec php-fpm ${defaultSettings} "$@"
fi;