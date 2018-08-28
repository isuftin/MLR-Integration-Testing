#!/bin/bash

SERVICE_NAME="water-auth-server"
OUTPUT_DIR="${OUTPUT_DIR:-`pwd`/tests/output/}"
TESTS_DIR="${TESTS_DIR:-`pwd`/tests/integrations/}"
{
  docker-compose -f docker-compose.yml up -d $SERVICE_NAME

  count=1
  limit=60
  until docker ps --filter "name=$SERVICE_NAME" --filter "health=healthy" --format "{{.Names}}" | grep "$SERVICE_NAME"
  do
    echo "Testing container health $count of $limit"
    if [ $count -eq $limit ]; then
      echo "Docker container $SERVICE_NAME never reached a healthy status in $limit tries"
      docker-compose -f docker-compose.yml down
      exit 1
    fi
    sleep 1
    count=$((count + 1))
  done

  docker run --rm --network="mlr-integration-testing_mlr-it-net" -v "${OUTPUT_DIR}:/tests/output/" -v "${TESTS_DIR}:/tests/integrations/" jmeter-base:latest jmeter -n -j /tests/output/waterauth/jmeter.log -l /tests/output/waterauth/jmeter-testing.log -t /tests/integrations/waterauth/waterauth.jmx
} || {
  docker-compose -f docker-compose.yml down
}
docker-compose -f docker-compose.yml down
