#
# Dockerfile to setup the container to build the Apache Ambari
#
# MAINTAINER ApacheAmbariBuilder <Nisanth Simon>
#

FROM centos:7

ENV container docker

MAINTAINER ApacheAmbariBuilder <Nisanth Simon>

# Set the Hostname and password for image.
ARG HOSTNAME=server.log.com
ARG CREDENTIALS=root:passw0rd

# Set the download path for Maven, Python 2.6, ANT, Python SSetup Tools & Ambari Code base 2.6.1
ENV MAVEN_DOWNLOAD_URL http://mirror.olnevhost.net/pub/apache/maven/binaries/apache-maven-3.2.2-bin.tar.gz
ARG PYTHON26_DOWNLOAD_URL=https://www.python.org/ftp/python/2.6.6/Python-2.6.6.tgz
ARG ANT_DOWNLOAD_URL=mirror.intergrid.com.au/apache/ant/binaries/apache-ant-1.9.11-bin.tar.gz
ARG PYTHON_SETUP_TOOL_DOWNLOAD_URL=https://pypi.python.org/packages/source/s/setuptools/setuptools-12.0.3.tar.gz
ARG AMBARI_CODEBASE=http://www.apache.org/dist/ambari/ambari-2.6.1/apache-ambari-2.6.1-src.tar.gz



# Set the environment variables.
ENV HOSTNAME=$HOSTNAME
ENV JAVA_HOME /usr/lib/jvm/java-1.7.0-openjdk
ENV PATH $JAVA_HOME/bin:$PATH
ENV M2_HOME /opt/setup/maven/apache-maven-3.2.2
ENV M2 $M2_HOME/bin
ENV PATH $M2_HOME/bin:$PATH
ENV ANT_HOME /opt/setup/ANT/apache-ant-1.9.11
ENV PATH $ANT_HOME/bin:$PATH


# yum update - Upgrade all of your CentOS system software to the latest version with one operation. 
# yum clean all - Clean the cache. The package cache is stored in /var/cache/yum
#                 /etc/yum.conf has the yum config details. This property has the cache directory, keepcache, log   
RUN yum -y update; yum clean all

# yum install openssh-server to setup the ssh server
RUN yum -y install openssh-server; yum clean all

# Set the password for root user
RUN echo ${CREDENTIALS} | chpasswd


RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;


# Setup systemd
RUN yum install -y systemd* && yum clean all


# RPM's used for building Amabri code
RUN yum install -y epel-release tar wget git python-dev* zlib zlib-devel && yum clean all
RUN yum -y install rpm-build && yum -y install gcc-c++ make  && yum clean all


# Enable SSHD Service
RUN systemctl enable sshd


# Install Java 1.7
RUN yum -y install java-1.7.0-openjdk && yum -y install java-1.7.0-openjdk-devel


# Setup Maven
RUN mkdir -p /opt/setup/maven && cd /opt/setup/maven && \
          wget ${MAVEN_DOWNLOAD_URL} && \
          tar -zxvf apache-maven-*-bin.tar.gz

# Update the Java and Maven details in bashrc
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk" >> ~/.bashrc && \
    echo "export PATH=$JAVA_HOME:$PATH" >> ~/.bashrc && \
    echo "export _JAVA_OPTIONS=\"-Xmx2048m -XX:MaxPermSize=512m -Djava.awt.headless=true\"" >> ~/.bashrc && \
    echo "export M2_HOME=/opt/setup/maven/apache-maven-3.2.2" >> ~/.bashrc && \
    echo "export M2=$M2_HOME/bin" >> ~/.bashrc && \
    echo "export PATH=$M2:$PATH" >> ~/.bashrc


# Setup Python 2.6
RUN mkdir -p /opt/setup/python && \
    cd /opt/setup/python && \
    wget $PYTHON26_DOWNLOAD_URL && \
    tar -zxvf Python-2.6.6.tgz && \
    cd Python-2.6.6 && \
    ./configure && make && make install && \
    ln -s /usr/local/bin/python /usr/bin/python2.6


# Setup ANT
RUN mkdir -p /opt/setup/Ant && cd /opt/setup/Ant && \
    wget $ANT_DOWNLOAD_URL && \
    tar -zxvf apache-ant-1.9.11-bin.tar.gz && \
    echo "export ANT_HOME=/opt/setup/ANT/apache-ant-1.9.11" >> ~/.bashrc && \
    echo "export PATH=$PATH:$ANT_HOME/bin" >> ~/.bashrc


# Install setuptools for Python
RUN mkdir -p /opt/setup/setuptools && \
    cd /opt/setup/setuptools && \
    wget ${PYTHON_SETUP_TOOL_DOWNLOAD_URL} && \
    tar -zxvf setuptools-12.0.3.tar.gz && \
    cd setuptools-12.0.3 && \
    python setup.py install
RUN yum -y install python-setuptools



# Download Ambari and set the code in path /opt/Ambari/build
RUN mkdir -p /opt/Ambari/build
WORKDIR /opt/Ambari/build
RUN wget -P /opt/Ambari/build ${AMBARI_CODEBASE} && \
    cd /opt/Ambari/build && \
    tar -xzf apache-ambari-2.6.1-src.tar.gz


# Build Fails, when we run the codebase as is. So we change the version for ambari storm sink from 1.1.0-SNAPSHOT to 1.1.0
RUN sed -i 's/1.1.0-SNAPSHOT/1.1.0/g' /opt/Ambari/build/apache-ambari-2.6.1-src/ambari-metrics/ambari-metrics-storm-sink/pom.xml 

# Copy the build scripts to container
# setupAmbari.sh - used to build Ambari code
# setupLogSearch.sh - used to build LogSearch Code
COPY bin/setupAmbari.sh /opt/Ambari/
COPY bin/setupLogSearch.sh /opt/Ambari/


RUN chmod -R 755 /opt/Ambari/

VOLUME [ "/sys/fs/cgroup" ]

ENTRYPOINT ["/usr/sbin/init"]

EXPOSE 22


