FROM ubuntu:14.04
MAINTAINER IntentMedia TechOps <techops@intentmedia.com>
RUN apt-get update
RUN apt-get install -y curl default-jre
RUN curl -sSfL http://downloads.mesosphere.io/chronos/chronos-2.1.0_mesos-0.14.0-rc4.tgz --output chronos.tgz
RUN tar xzf chronos.tgz
WORKDIR chronos
CMD start-chronos.bash