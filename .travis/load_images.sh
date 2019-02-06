#!/bin/bash

date

ls -al $HOME/docker

for archive in $HOME/docker/*; do
  docker load -i $archive || true
done
