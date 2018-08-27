#!/bin/bash

# docker run -d -p 8444:443 -p 8080:80 -v `pwd`/.travis/nginx.conf:/etc/nginx/nginx.conf -v `pwd`/configuration/config/certificates/wildcard.crt:/etc/nginx/wildcard.crt -v `pwd`/configuration/config/certificates/wildcard.key:/etc/nginx/wildcard.key  nginx:latest

NGINX_ADDRESS=${NGINX_ADDRESS:-localhost}
export IMAGES="
wma/wma-spring-boot-base:latest
mlr-python-base-docker:latest
water_auth_server
mlr/mlr-legacy-db:latest
mlr/mlr-legacy:latest
mlr/mlr-notification:latest
mlr/mlr-legacy-transformer:latest
mlr/mlr-wsc-file-exporter:latest
mlr/mlr-validator:latest
mlr/mlr-gateway:latest
mlr/mlr-ddot-ingester:latest
"
for IMAGE in $IMAGES; do
  docker pull $NGINX_ADDRESS:8444/$IMAGE
  docker tag $NGINX_ADDRESS:8444/$IMAGE cidasdpdasartip.cr.usgs.gov:8447/$IMAGE
done
