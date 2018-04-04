#!/bin/bash

docker build -t dockerizr/php:5.6-cli ./5.6/cli
docker build -t dockerizr/php:5.6-fpm ./5.6/fpm