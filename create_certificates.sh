#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
base_dir="$DIR/configuration/config/certificates"
dir_key_pair_arr=(
  "mlr-ddot-ingester,mlr.ddot.ingester"
  "mlr-gateway,mlr.gateway"
  "water-auth-server/tomcat-ssl,water.auth.server"
  "water-auth-server/oauth2,*"
  "water-auth-server/saml,*"
  "mlr-legacy,mlr.legacy"
  "mlr-legacy-transformer,mlr.legacy.transformer"
  "mlr-notification,mlr.notification"
  "mlr-validator,mlr.validator"
  "mlr-wsc-file-exporter,mlr.wsc.file.exporter"
  "wildcard,*"
)

for dir_key_pairs in "${dir_key_pair_arr[@]}"; do
    IFS=',' read -ra cb <<< "$dir_key_pairs"
    cert_dir="$base_dir/${cb[0]}"
    if [ ! -d "$cert_dir" ]; then
      mkdir -p "$cert_dir"
    fi

    rm "$base_dir/${cb[0]}/ssl.*"

    openssl genrsa -out "$cert_dir/ssl.key" 2048
    openssl req -nodes -newkey rsa:2048 -sha256 -keyout "$cert_dir/ssl.key" -out "$cert_dir/ssl.csr" -subj "/C=US/ST=Wisconsin/L=Middleon/O=US Geological Survey/OU=WMA/CN=${cb[1]}"
    openssl x509 -req -sha256 -days 9999 -in "$cert_dir/ssl.csr" -signkey "$cert_dir/ssl.key" -out "$cert_dir/ssl.crt"
done
