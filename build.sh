#!/bin/bash

#
# NAME : build.sh
#
# FUNCTION : This script will setup the Docker in Linux machine and download the Apache Ambari code and build the source code. 
#            The Amabri code will be downloaded to /opt/Ambari/build/apache-ambari-2.6.1-src in container.
#            This script will generate Ambari RPM ( ambari-server-*.rpm, ambari-agent-*.rpm & Log Search RPMs) in generatedRPM folder.
#
# USAGE : ./build.sh
#
#

sdir="`dirname \"$0\"`"

# Build Container
docker kill buildserver
docker rm buildserver
docker build --rm --no-cache -t buildimg $sdir/
#docker build --rm -t buildimg $sdir/

# Run the container
docker run --privileged --name buildserver -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 20:22 -d -h=buildserver.com -it buildimg


# Run the Ambari Build & LogSearch
docker exec buildserver bash -c '/opt/Ambari/setupAmbari.sh'
docker exec buildserver bash -c '/opt/Ambari/setupLogSearch.sh'

# Copy the artifacts from build container to outputfolder in host machine.
# ambari-agent-2.6.1.0-0.x86_64.rpm       ambari-infra-solr-client-2.6.1.0-0.noarch.rpm    ambari-logsearch-portal-2.6.1.0-0.noarch.rpm
# ambari-infra-solr-2.6.1.0-0.noarch.rpm  ambari-logsearch-logfeeder-2.6.1.0-0.noarch.rpm  ambari-server-2.6.1.0-0.x86_64.rpm

docker cp buildserver:/opt/Ambari/build/apache-ambari-2.6.1-src/ambari-server/target/rpm/ambari-server/RPMS/x86_64/ambari-server-2.6.1.0-0.x86_64.rpm $sdir/generatedRPM
docker cp buildserver:/opt/Ambari/build/apache-ambari-2.6.1-src/ambari-agent/target/rpm/ambari-agent/RPMS/x86_64/ambari-agent-2.6.1.0-0.x86_64.rpm $sdir/generatedRPM
docker cp buildserver:/opt/Ambari/build/apache-ambari-2.6.1-src/ambari-logsearch/ambari-logsearch-assembly/target/rpm/ambari-infra-solr/RPMS/noarch/ambari-infra-solr-2.6.1.0-0.noarch.rpm $sdir/generatedRPM
docker cp buildserver:/opt/Ambari/build/apache-ambari-2.6.1-src/ambari-logsearch/ambari-logsearch-assembly/target/rpm/ambari-infra-solr-client/RPMS/noarch/ambari-infra-solr-client-2.6.1.0-0.noarch.rpm $sdir/generatedRPM
docker cp buildserver:/opt/Ambari/build/apache-ambari-2.6.1-src/ambari-logsearch/ambari-logsearch-assembly/target/rpm/ambari-logsearch-logfeeder/RPMS/noarch/ambari-logsearch-logfeeder-2.6.1.0-0.noarch.rpm $sdir/generatedRPM
docker cp buildserver:/opt/Ambari/build/apache-ambari-2.6.1-src/ambari-logsearch/ambari-logsearch-assembly/target/rpm/ambari-logsearch-portal/RPMS/noarch/ambari-logsearch-portal-2.6.1.0-0.noarch.rpm $sdir/generatedRPM


printf "\n\n\n ********************************************************"
printf "\n\n To Login to Ambari Server Linux terminal -> ssh -p 20 root@localhost"
printf "\n Password for root user -> passw0rd"
printf "\n Ambari Code is available under /opt/Ambari/build/apache-ambari-2.6.1-src"
printf "\n\n ********************************************************\n"




