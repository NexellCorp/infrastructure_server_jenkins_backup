#!/bin/bash

cp -a /var/lib/jenkins/.ssh /var/jenkins_home/

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

sudo service jenkins start
