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
  docker save "cidasdpdasartip.cr.usgs.gov:8447/${IMAGE}:latest" "$HOME/docker/${IMAGE////.}.tar"
done
