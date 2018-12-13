#!/bin/bash

launch_servers () {
  docker-compose -f docker-compose-jmeter-servers.yml  up --no-color --detach --renew-anon-volumes
}

destroy_servers () {
  docker-compose -f docker-compose-jmeter-servers.yml down --volumes
}

echo "Launching JMeter Servers"
{
  launch_servers
  EXIT_CODE=$?

  if [ $EXIT_CODE -ne 0 ]; then
    echo "Could not launch JMeter servers"
    destroy_servers
    exit $EXIT_CODE
  fi

  sleep 5

  exit 0
} || {
  echo "Something went horribly wrong"
  destroy_servers
  exit 1
}
