#!/usr/bin/env bash

# Xdebug settings
PHP_XDEBUG_ENABLED=${PHP_XDEBUG_ENABLED:-false}
PHP_XDEBUG_REMOTE_HOST=${PHP_XDEBUG_REMOTE_HOST:-"localhost"}
PHP_XDEBUG_IDEKEY=${PHP_XDEBUG_IDEKEY:-"dockerizr-php"}

# Default INI settings.
PHP_INI_MEMORY_LIMIT=${PHP_INI_MEMORY_LIMIT:-1G}
PHP_INI_MAX_EXECUTION_TIME=${PHP_INI_MAX_EXECUTION_TIME:-0}

defaultSettings="\
    -dmemory_limit=${PHP_INI_MEMORY_LIMIT} \
    -dmax_execution_time=${PHP_INI_MAX_EXECUTION_TIME} \
"

if ${PHP_XDEBUG_ENABLED}; then

    # PHPStorm ide config
    export PHP_IDE_CONFIG="serverName=docker"

    if [ "$PHP_XDEBUG_REMOTE_HOST" = "localhost" ]; then
        echo "INFO: No remote host for xdebug found. Use PHP_XDEBUG_REMOTE_HOST env variable to set it"
    fi

    exec php-cli \
        -dzend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20151012/xdebug.so \
        -dhtml_errors=false \
        -dxdebug.remote_enable=1 \
        -dxdebug.remote_autostart=1 \
        -dxdebug.remote_connect_back=1 \
        -dxdebug.remote_host=$PHP_XDEBUG_REMOTE_HOST \
        -dxdebug.idekey=$PHP_XDEBUG_IDEKEY \
        -dxdebug.default_enable=off ${defaultSettings} \
        "$@"

else
    exec php-cli ${defaultSettings} "$@"
fi;