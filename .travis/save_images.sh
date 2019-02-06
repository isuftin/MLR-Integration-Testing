#!/bin/bash

for img in $(docker image ls --format "{{ .Repository }}:{{ .Tag }}"); do
  docker save $img -o "$HOME/docker/$img.tar"

done

if [ ! -f "$HOME/docker/jmeter.tar" ]; then
  docker-compose -f docker-compose-jmeter-servers.yml build
  docker save "jmeter-base:latest" -o "$HOME/docker/jmeter.tar"
fi
