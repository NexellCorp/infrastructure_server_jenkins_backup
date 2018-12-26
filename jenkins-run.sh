#!/bin/bash

cp -a /var/lib/jenkins/.ssh /var/jenkins_home/

sudo service jenkins start
