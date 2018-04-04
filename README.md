# docker-php
[![Build Status](https://travis-ci.org/u-nik/docker-php.svg?branch=master)](https://travis-ci.org/u-nik/docker-php)

A dockerized PHP 5.6/7.x with optional xdebug installed.

## PHP versions available

- PHP 5.6 (cli/fpm)
- PHP 7.0 (cli/fpm)
- PHP 7.1 (cli/fpm)
- PHP 7.2 (cli/fpm)

## Enable xdebug
To enable the XDebug extension, you have to set the environment 
variables `PHP_XDEBUG_ENABLED=true`. Optional you can specify the 
remote host address with `PHP_XDEBUG_REMOTE_HOST=your-host-ip`
and the session id key `PHP_XDEBUG_IDEKEY=your-idekey`

## Override PHP ini settings
You can override every available php.ini setting with environment
variables. Each env var starts with `PHP_INI_*` followed by the
setting name. 

**Some examples:**
- `PHP_INI_MEMORY_LIMIT=512M`
- `PHP_INI_MAX_EXECUTION_TIME=10`
- `PHP_INI_DATE_TIMEZONE=Europe/Berlin`

Every dots and dashes in the setting name is converted to an
underscore `date.timezone => DATE_TIMEZONE`

For a full list of available settings see [PHP manual](http://php.net/manual/de/ini.list.php)
