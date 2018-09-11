#!/bin/bash

SERVICE_NAMES="mlr-gateway \
  mlr-legacy \
  mlr-notification \
  mlr-legacy-transformer \
  mlr-ddot-ingester \
  mlr-validator \
  mlr-wsc-file-exporter \
  mlr-legacy-db \
  water-auth-server"

get_healthy_services () {
  docker ps -f "name=${SERVICE_NAMES// /|}" -f "health=healthy" --format "{{ .Names }}"
}

launch_services () {
  docker-compose -f docker-compose.yml up --no-color --detach --renew-anon-volumes
}

destroy_services () {
  docker-compose -f docker-compose.yml down --volumes
}

echo "Launching MLR services..."
{
  EXIT_CODE=$(launch_services)

  if [[ $EXIT_CODE -ne 0 ]]; then
    echo "Could not launch MLR services"
  destroy_services
    exit $EXIT_CODE
  fi

  HEALTHY_SERVICES=$(get_healthy_services)
  SERVICE_NAMES_ARRAY=( $SERVICE_NAMES )
  HEALTHY_SERVICES_ARRAY=( $HEALTHY_SERVICES )
  count=1
  limit=120
  until [[ ${#HEALTHY_SERVICES_ARRAY[@]} -eq ${#SERVICE_NAMES_ARRAY[@]} ]]; do
    echo "Testing service health. Attempt $count of $limit"

    sleep 1
    count=$((count + 1))

    UNHEALTHY_SERVICES_ARRAY=()
    for SERVICE_NAME in "${SERVICE_NAMES_ARRAY[@]}"; do
      skip=
      for HEALTHY_SERVICE in "${HEALTHY_SERVICES_ARRAY[@]}"; do
        [[ $SERVICE_NAME == $HEALTHY_SERVICE ]] && { skip=1;break; }
      done
      [[ -n $skip ]] || UNHEALTHY_SERVICES_ARRAY+=("$SERVICE_NAME")
    done

    # Did we hit our testing limit? If so, bail.
    if [ $count -eq $limit ]; then
      echo "Docker containers coult not reach a healthy status in $limit tries"
      echo "Services still not healthy: ${UNHEALTHY_SERVICES_ARRAY[@]}"
      destroy_services
      exit 1
    fi

    # Update the healthy services
    HEALTHY_SERVICES=$(get_healthy_services)
    HEALTHY_SERVICES_ARRAY=( $HEALTHY_SERVICES )
    echo "Not all services healthy yet."
    echo "Services still not healthy: ${UNHEALTHY_SERVICES_ARRAY[@]}"
  done

  echo "All services healthy: ${HEALTHY_SERVICES_ARRAY[@]}"

  exit 0
} || {
  echo "Something went horribly wrong"
  destroy_services
  exit 1
}
