FROM ubuntu:14.04
MAINTAINER IntentMedia TechOps <techops@intentmedia.com>
RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
RUN echo "deb http://repos.mesosphere.io/ubuntu trusty main" | \
  sudo tee /etc/apt/sources.list.d/mesosphere.list
RUN apt-get -y update
RUN apt-get install -y chronos mesos curl
ADD start-chronos.sh /
CMD /usr/bin/chronos run_jar