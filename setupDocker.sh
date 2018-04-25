#!/bin/bash

#
# NAME : setupDocker.sh
#
# FUNCTION : This script will setup the Docker in Linux machine.
#
# USAGE : ./setupDocker.sh
#
#

printf "\n Installing the Docker \n"

# Update the Systems
yum update -y

# Create the Repo file
repo="[dockerrepo]\nname=Docker Repository\nbaseurl=https://yum.dockerproject.org/repo/main/centos/7/\nenabled=1\ngpgcheck=1\ngpgkey=https://yum.dockerproject.org/gpg\n"
echo -e $repo > /etc/yum.repos.d/docker.repo

# Install Docker
yum install docker-engine -y

# Start Docker
service docker start

# Verify the docker is up and running
docker run hello-world

printf "\n Installing the Docker completed. \n"