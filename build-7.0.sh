#!/bin/bash

docker build -t dockerizr/php:7.0-cli ./7.0/cli
docker build -t dockerizr/php:7.0-fpm ./7.0/fpm
