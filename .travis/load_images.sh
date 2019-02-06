#!/bin/bash

declare -a IMAGES=(
  "water_auth_server"
  "mlr/mlr-legacy-db"
  "mlr/mlr-legacy"
  "mlr/mlr-notification"
  "mlr/mlr-legacy-transformer"
  "mlr/mlr-wsc-file-exporter"
  "mlr/mlr-validator"
  "mlr/mlr-gateway"
  "mlr/mlr-ddot-ingester"
)

for IMAGE in "${IMAGES[@]}"; do
  docker load -i "$HOME/docker/${IMAGE////.}.tar" || true
done

docker load -i "$HOME/docker/jmeter.tar" || true
