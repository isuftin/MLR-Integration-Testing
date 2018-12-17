#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

"$DIR/create_certificates.sh"

docker run --rm \
  -d \
  -p 8444:443 \
  -p 8080:80 \
  -v "$DIR/.travis/nginx.conf:/etc/nginx/nginx.conf" \
  -v "$DIR/configuration/config/certificates/wildcard/ssl.crt:/etc/nginx/wildcard.crt" \
  -v "$DIR/configuration/config/certificates/wildcard/ssl.key:/etc/nginx/wildcard.key" \
  --name nginx \
  nginx:latest

# Wait for NGINX to start
sleep 5

NGINX_ADDRESS=${NGINX_ADDRESS:-localhost}

declare -a IMAGES=(
  "water_auth_server:latest"
  "mlr/mlr-legacy-db:latest"
  "mlr/mlr-legacy:latest"
  "mlr/mlr-notification:latest"
  "mlr/mlr-legacy-transformer:latest"
  "mlr/mlr-wsc-file-exporter:latest"
  "mlr/mlr-validator:latest"
  "mlr/mlr-gateway:latest"
  "mlr/mlr-ddot-ingester:latest"
)

for IMAGE in "${IMAGES[@]}"; do
  docker pull "$NGINX_ADDRESS:8444/$IMAGE"
  docker tag "$NGINX_ADDRESS:8444/$IMAGE" "cidasdpdasartip.cr.usgs.gov:8447/$IMAGE"
done

docker stop nginx
