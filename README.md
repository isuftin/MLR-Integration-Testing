MLR Integration Testing
---

This project is a working set of integration tests that may be run against
the MLR project. The tests are written using JMeter to go against a live, local MLR
stack running on the Docker engine.

#### Running the MLR stack When not on the USGS network

Feel free to skip this section if you are on the USGS network.

The MLR project is a set of Docker images that are served from an Artifactory instance within the Water Mission Area's data center. Through a reverse proxy setup, users on the USGS network are able to point their Docker engine at the Artifactory instance using the internal address to pull images (e.g. `cidasdpdasartip.cr.usgs.gov:8447/mlr/mlr-legacy-db:latest`). As such, no routing magic needs to happen on the user's machine in order to pull the images needed. However, when not on the USGS network, a developer must still be able to pull hosted images from Artifactory. In order to accomplish this, we use a running NGINX Docker container as a reverse proxy for localhost to point to `https://cida.usgs.gov/artifactory/api/docker/owi-docker/v2/` to pull the needed Docker images. This is required because the Docker engine only will pull images against a host at the root context or at a specific port. Therefore Docker cannot pull from `cida.usgs.gov/artifactory/api/docker/owi-docker/v2/` but can from `localhost` which NGINX proxies to Artifactory.

Ensure that the script to pull the images is executable:

`$ chmod +x pull-containers.sh`

Then execute the script:

`$ ./pull-containers.sh`

The script will first create the SSL certificates needed by NGINX to serve as an SSL enabled reverse proxy. It will then launch NGINX, sleep for 5 seconds to give NGINX time to come up and then will use NGINX to pull the images. The script will then shut down NGINX.

The SSL certificates created are stored in the `ssl/` subdirectory. These certificates are part of the `.gitignore` file so they are not checked in.

#### Launching the services

In order to launch all of the required services, ensure that the "launch_services.sh" script is executable:

`$ chmod +x launch_services.sh`

And run it:

`$ ./launch_services.sh`

This script uses the `docker-compose-services.yml` config file to launch the MLR stack as well as two helper containers. One is a mock SMTP server that is required for the mlr-notification service to run. The other is a mock S3 bucket that is also used by MLR services.

When run, the script will attempt to launch the entire MLR stack and will then test the stack health for four minutes. If within four minutes any of the containers running in the stack are still unhealthy, the script will bring down the stack. If you are experiencing issues with the stack not coming up properly, some of the things you may look into is whether or not you have allocated enough RAM to the stack. On my system, I allocate two CPUs and about 5GB of RAM to Docker. Once running, this is what the stack status looks like:

```
$ docker stats

$ docker stats --no-stream
CONTAINER ID        NAME                                    CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
4d1098dfbfb8        mlr-gateway                             0.61%               341.1MiB / 5.825GiB   5.72%               19.5kB / 17.9kB     0B / 2.06MB         36
36308208da57        mlr-legacy                              0.10%               292.3MiB / 5.825GiB   4.90%               15kB / 12.9kB       0B / 557kB          32
b6aa2baa90ba        mlr-ddot-ingester                       0.78%               43.75MiB / 5.825GiB   0.73%               5.9kB / 2.86kB      0B / 283kB          4
e1d9ed51f803        mlr-legacy-transformer                  0.67%               44.02MiB / 5.825GiB   0.74%               5.87kB / 2.78kB     0B / 283kB          4
7cb59bef8d4f        mlr-validator                           0.64%               63.95MiB / 5.825GiB   1.07%               5.87kB / 2.78kB     0B / 283kB          4
9732ee65fd25        mlr-notification                        0.18%               297.1MiB / 5.825GiB   4.98%               8.95kB / 5.8kB      0B / 557kB          31
50aa6533bb83        mlr-wsc-file-exporter                   0.69%               48.02MiB / 5.825GiB   0.81%               5.94kB / 2.86kB     0B / 283kB          4
d5d05d848622        water-auth-server                       0.11%               486.1MiB / 5.825GiB   8.15%               23.7kB / 30.6kB     0B / 147kB          31
ce79713e1782        mlr-integration-testing_mock-s3_1       0.08%               116.3MiB / 5.825GiB   1.95%               2.79kB / 491B       0B / 0B             22
91ede6402494        mlr-integration-testing_smtp-server_1   0.07%               23.4MiB / 5.825GiB    0.39%               4.69kB / 2.82kB     0B / 0B             15
2b3049c69261        mlr-legacy-db                           2.52%               20.05MiB / 5.825GiB   0.34%               26.4kB / 22.9kB     0B / 136MB          17
```

Given these specs, the stack starts and shows as healthy on my system in about 80 seconds.

Once the script has verified that all of the containers are running successfully, it will also create a mock S3 bucket in the S3 container and exit.

An abbreviated example of the script running looks like:

```
$ ./launch_services.sh
Launching MLR services...
Creating network "mlr-it-net" with the default driver
Creating water-auth-server                     ... done
Creating mlr-integration-testing_smtp-server_1 ... done
Creating mlr-legacy-db                         ... done
Creating mlr-integration-testing_mock-s3_1     ... done
Creating mlr-validator                         ... done
Creating mlr-legacy-transformer                ... done
Creating mlr-ddot-ingester                     ... done
Creating mlr-notification                      ... done
Creating mlr-legacy                            ... done
Creating mlr-wsc-file-exporter                 ... done
Creating mlr-gateway                           ... done
Testing service health. Attempt 1 of 240
Services still not healthy: mlr-gateway mlr-legacy mlr-notification mlr-legacy-transformer mlr-ddot-ingester mlr-validator mlr-wsc-file-exporter mlr-legacy-db water-auth-server
Testing service health. Attempt 2 of 240
Services still not healthy: mlr-gateway mlr-legacy mlr-notification mlr-legacy-transformer mlr-ddot-ingester mlr-validator mlr-wsc-file-exporter mlr-legacy-db water-auth-server
Testing service health. Attempt 3 of 240

[...]

Testing service health. Attempt 49 of 240
Services still not healthy: mlr-gateway mlr-legacy mlr-notification
All services healthy: mlr-gateway mlr-notification mlr-validator mlr-legacy mlr-wsc-file-exporter mlr-ddot-ingester mlr-legacy-transformer mlr-legacy-db water-auth-server
Creating test s3 bucket...
Bucket created successfully
```

#### Destroying the MLR stack

Once you're finished testing or you'd like to recreate the MLR stack running in Docker, you can destroy the stack by running the `destroy_services.sh` script after ensuring that it is executable:

```
$ chmod +x destroy_services.sh
$ ./destroy_services.sh
$ ./destroy_services.sh
Bringing down MLR services...
Stopping mlr-gateway                           ... done
Stopping mlr-notification                      ... done
Stopping mlr-validator                         ... done
Stopping mlr-legacy                            ... done
Stopping mlr-wsc-file-exporter                 ... done
Stopping mlr-ddot-ingester                     ... done
Stopping mlr-legacy-transformer                ... done
Stopping mlr-legacy-db                         ... done
Stopping mlr-integration-testing_mock-s3_1     ... done
Stopping mlr-integration-testing_smtp-server_1 ... done
Stopping water-auth-server                     ... done
Removing mlr-gateway                           ... done
Removing mlr-notification                      ... done
Removing mlr-validator                         ... done
Removing mlr-legacy                            ... done
Removing mlr-wsc-file-exporter                 ... done
Removing mlr-ddot-ingester                     ... done
Removing mlr-legacy-transformer                ... done
Removing mlr-legacy-db                         ... done
Removing mlr-integration-testing_mock-s3_1     ... done
Removing mlr-integration-testing_smtp-server_1 ... done
Removing water-auth-server                     ... done
Removing network mlr-it-net
Done
```

#### Launching JMeter slave servers

In order to perform the integration tests on MLR, JMeter is launched in a master/slave configuration. First, we launch three JMeter slave containers that sit and wait for the JMeter master to come online and provide instructions for testing. Once the testing has completed, the output files are provided back to master and written onto the file system. At this point, more testing may be run or the slaves may be shut down.

In order to launch the JMeter slave containers, simply ensure the `launch_jmeter_servers.sh` script is executable and run it:

```
$ chmod +x launch_jmeter_servers.sh
$ ./launch_jmeter_servers.sh
```

If this is your first time launching these containers, Docker will build the JMeter image based on the Dockerfile located @ `jmeter-docker/base/Dockerfile`. This Dockerfile builds a JMeter Docker image using version 5.0 of JMeter downloaded from Apache.

You may see a warning about orphan containers if you're already running the MLR stack. You may disregard those warnings.

#### Destroying JMeter slave servers

Once your testing has completed or you'd like to bring down the JMeter slave servers, ensure that the `destroy_jmeter_servers.sh` script is executable and run it:

```
$ chmod +x destroy_jmeter_servers.sh
$ ./destroy_jmeter_servers.sh
$ ./destroy_jmeter_servers.sh

Bringing down JMeter server services...
Stopping mlr-integration-testing_jmeter-server-2_1 ... done
Stopping mlr-integration-testing_jmeter-server-3_1 ... done
Stopping mlr-integration-testing_jmeter-server-1_1 ... done
WARNING: Found orphan containers (mlr-gateway, mlr-legacy, mlr-ddot-ingester, mlr-legacy-transformer, mlr-validator, mlr-notification, mlr-wsc-file-exporter, water-auth-server, mlr-integration-testing_mock-s3_1, mlr-integration-testing_smtp-server_1, mlr-legacy-db) for this project. If you removed or renamed this service in your compose file, you can run this command with the --remove-orphans flag to clean it up.
Removing mlr-integration-testing_jmeter-server-2_1 ... done
Removing mlr-integration-testing_jmeter-server-3_1 ... done
Removing mlr-integration-testing_jmeter-server-1_1 ... done
Network mlr-it-net is external, skipping
Done
```

You may see a warning about orphan containers if you're already running the MLR stack. You may disregard those warnings.

#### Running JMeter tests via JMeter GUI

Once the MLR stack and the JMeter slave servers are up and running, you can run the JMeter tests via the JMeter GUI. Running via the GUI is the easiest way to visualize and edit the tests.

 
