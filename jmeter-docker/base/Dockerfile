FROM openjdk:8-jre-slim

LABEL maintainer="isuftin@usgs.gov"
LABEL description="This is a base container for JMeter Docker"

ARG JMETER_VERSION=4.0

ENV JMETER_HOME /jmeter

RUN apt-get update && \
  apt-get -qy install \
    wget \
    unzip && \
  apt-get clean

RUN wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-$JMETER_VERSION.tgz && \
  tar -xzf apache-jmeter-$JMETER_VERSION.tgz && \
  rm apache-jmeter-$JMETER_VERSION.tgz && \
  mv apache-jmeter-$JMETER_VERSION /jmeter

ENV PATH $JMETER_HOME/bin:$PATH

RUN ["chmod", "+x", "/entrypoint.sh"]

WORKDIR ${JMETER_HOME}
