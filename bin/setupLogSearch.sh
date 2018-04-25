#!/bin/bash

# Build the LogSearch

cd /opt/Ambari/build/apache-ambari-2.6.1-src/ambari-logsearch

mvn -Dbuild-rpm clean package