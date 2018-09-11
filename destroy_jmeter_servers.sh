#!/bin/bash
echo "Bringing down JMeter server services..."

docker-compose -f docker-compose-jmeter-servers.yml down --volumes

sleep 5

echo "Done"
