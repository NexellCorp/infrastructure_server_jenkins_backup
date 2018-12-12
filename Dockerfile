FROM ubuntu:16.04

USER root

RUN apt-get update && apt-get install -y wget
RUN apt-get update && apt-get install -y gawk git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat cpio bc
RUN apt-get update && apt-get install -y autoconf automake libtool libglib2.0-dev libarchive-dev
RUN apt-get update && apt-get install -y python-git
  
RUN apt-get update && apt-get install -y lzop
RUN apt-get update && apt-get install -y lynx device-tree-compiler

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_SLAVE_AGENT_PORT 50000

RUN groupadd -g ${gid} ${group} && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}
 
RUN echo "jenkins:jenkins" | chpasswd

RUN apt-get update && apt-get install -y sudo

RUN wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | apt-key add -
RUN sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
RUN apt-get update && apt-get install -y jenkins
RUN apt-get update && apt-get install -y --no-install-recommends openjdk-8-jdk
RUN apt-get update && apt-get install -y repo

RUN echo "jenkins:jenkins" | chpasswd && adduser jenkins sudo

VOLUME /var/jenkins_home
VOLUME /var/lib/jenkins

COPY run.sh /var/jenkins_home/

RUN apt-get update && apt-get install -y python3 vim locales
RUN apt-get update && apt-get install -y android-tools-fsutils

RUN locale-gen en_US.UTF-8

USER jenkins
