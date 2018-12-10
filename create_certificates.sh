#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
openssl genrsa -out $DIR/ssl/wildcard.key 2048
openssl req -nodes -newkey rsa:2048 -keyout $DIR/ssl/wildcard.key -out $DIR/ssl/wildcard.csr -subj "/C=US/ST=Wisconsin/L=Middleon/O=US Geological Survey/OU=WMA/CN=*"
openssl x509 -req -days 9999 -in $DIR/ssl/wildcard.csr -signkey $DIR/ssl/wildcard.key -out $DIR/ssl/wildcard.crt
