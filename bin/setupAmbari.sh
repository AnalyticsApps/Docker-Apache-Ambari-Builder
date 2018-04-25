#!/bin/bash

#
# NAME : setupAmbari.sh
#
# FUNCTION : This script will build the Ambari code base
#
# USAGE : ./setupAmbari.sh
#
#


cd /opt/Ambari/build/apache-ambari-2.6.1-src

# Setup the Amabri Build
# Refer - https://cwiki.apache.org/confluence/display/AMBARI/Installation+Guide+for+Ambari+2.6.1

mvn versions:set -DnewVersion=2.6.1.0.0

pushd ambari-metrics

mvn versions:set -DnewVersion=2.6.1.0.0

popd

mvn -B clean install package rpm:rpm -DnewVersion=2.6.1.0.0 -DskipTests -Dpython.ver="python >= 2.6"



