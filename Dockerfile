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
RUN apt-get update && apt-get install -y python-pip
RUN pip install --upgrade pip
RUN pip install pycrypto

RUN locale-gen en_US.UTF-8

RUN rm -rf /var/lib/apt/lists/*
RUN apt clean
RUN apt-get update && apt-get install -y tzdata
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

#Android Build setup
RUN apt-get update && apt-get install -y curl
ENV ANDROID_EMULATOR_DEPS "file libqt5widgets5"

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs expect $ANDROID_EMULATOR_DEPS \
    && apt-get autoclean

# Install the SDK
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN cd /opt \
    && wget --output-document=android-sdk.zip --quiet $ANDROID_SDK_URL \
    && unzip android-sdk.zip -d android-sdk-linux \
    && rm -f android-sdk.zip \
    && chown -R root:root android-sdk-linux

ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${PATH}

# Install custom tools
COPY tools /opt/tools
ENV PATH /opt/tools:${PATH}

# Install Android platform and things
ENV ANDROID_PLATFORM_VERSION 28
ENV ANDROID_BUILD_TOOLS_VERSION 28.0.3
ENV ANDROID_EXTRA_PACKAGES "build-tools;28.0.0" "build-tools;28.0.1" "build-tools;28.0.2"
ENV ANDROID_REPOSITORIES "extras;android;m2repository" "extras;google;m2repository"
ENV ANDROID_CONSTRAINT_PACKAGES "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.0"
ENV ANDROID_EMULATOR_PACKAGE "system-images;android-$ANDROID_PLATFORM_VERSION;google_apis_playstore;x86_64"
RUN android-accept-licenses "sdkmanager --verbose \"platform-tools\" \"emulator\" \"platforms;android-$ANDROID_PLATFORM_VERSION\" \"build-tools;$ANDROID_BUILD_TOOLS_VERSION\" $ANDROID_EXTRA_PACKAGES $ANDROID_REPOSITORIES $ANDROID_CONSTRAINT_PACKAGES $ANDROID_EMULATOR_PACKAGE"
RUN android-avdmanager-create "avdmanager create avd --package \"$ANDROID_EMULATOR_PACKAGE\" --name test --abi \"google_apis_playstore/x86_64\""
ENV PATH ${ANDROID_HOME}/build-tools/${ANDROID_BUILD_TOOLS_VERSION}:${PATH}

# Fix for emulator detect 64bit
ENV SHELL /bin/bash

# Install upload-apk helper
RUN npm install -g xcode-build-tools

# Extra package
RUN apt-get update && apt-get install -y zip libxml2-utils

# Jenkins job builder
RUN pip install jenkins-job-builder
RUN pip install ruamel_yaml

# Squad report parsing
RUN apt-get update && apt-get install -y libcurl4-gnutls-dev librtmp-dev
RUN pip install pycurl

RUN echo "jenkins ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers

USER jenkins
