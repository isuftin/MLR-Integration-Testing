#!/bin/bash

SERVICE_NAME="water-auth-server"
OUTPUT_DIR="${OUTPUT_DIR:-`pwd`/tests/output}"
TESTS_DIR="${TESTS_DIR:-`pwd`/tests/integrations}"
JMETER_DOCKER_DIR="${JMETER_DOCKER_DIR:-`pwd`/jmeter-docker}"
DOCKER_NETWORK_NAME="${DOCKER_NETWORK_NAME:-mlr-it-net}"

{
  docker-compose -f docker-compose.yml up -d $SERVICE_NAME jmeter-server-1 jmeter-server-2 jmeter-server-3

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

  docker run --rm \
    --network="${DOCKER_NETWORK_NAME}" \
    -v "${OUTPUT_DIR}:/tests/output/" \
    -v "${TESTS_DIR}:/tests/integrations/" \
    -v "${JMETER_DOCKER_DIR}/jmeter-master.properties:/jmeter/jmeter.properties" \
    -v "${JMETER_DOCKER_DIR}/config/rmi_keystore.jks:/jmeter/rmi_keystore.jks" \
    jmeter-base:latest jmeter \
      -f \
      -n \
      -j /tests/output/waterauth/jmeter-output/jmeter.log \
      -l /tests/output/waterauth/jmeter-output/jmeter-testing.log \
      -JJMETER_OUTPUT_PATH=/tests/output/waterauth/test-output/results.xml \
      -t /tests/integrations/waterauth/waterauth.jmx \
      -Rjmeter.server.1,jmeter.server.2,jmeter.server.3
} || {
  docker-compose -f docker-compose.yml down
  exit 1
}
docker-compose -f docker-compose.yml down
