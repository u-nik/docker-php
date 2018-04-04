#!/bin/bash

docker build -t dockerizr/php:7.1-cli ./7.1/cli
docker build -t dockerizr/php:7.1-fpm ./7.1/fpm
