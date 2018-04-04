#!/bin/bash

docker build -t dockerizr/php:7.2-cli ./7.2/cli
docker build -t dockerizr/php:7.2-fpm ./7.2/fpm
