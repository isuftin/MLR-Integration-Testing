#!/bin/bash
echo "Bringing down MLR services..."

docker-compose -f docker-compose-jmeter-servers.yml down --volumes

sleep 5

echo "Done"
