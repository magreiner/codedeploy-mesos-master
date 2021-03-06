#!/bin/bash

LOCAL_IP_ADDRESS="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

#
# MESOS
#

# Add mesos repository
apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
DISTRO="$(lsb_release -is | tr '[:upper:]' '[:lower:]')"
CODENAME="$(lsb_release -cs)"
echo "deb http://repos.mesosphere.com/${DISTRO} ${CODENAME} main" > /etc/apt/sources.list.d/mesosphere.list

# Add java repository
add-apt-repository -y ppa:webupd8team/java
su -c 'echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections'

# install requirements
apt-get --yes update
apt-get --yes install oracle-java8-installer
apt-get --yes install mesos marathon curl


sudo service mesos-slave stop
echo "manual" | tee /etc/init/mesos-slave.override
echo "$LOCAL_IP_ADDRESS" | tee /etc/mesos-master/ip
echo "zk://$LOCAL_IP_ADDRESS:2181/mesos" | tee /etc/mesos/zk
echo "TestCluster" | tee /etc/mesos-master/cluster
echo "$LOCAL_IP_ADDRESS" | tee /etc/mesos-master/hostname
echo "1" | tee /etc/zookeeper/conf/myid

mkdir -p /etc/marathon/conf/
echo "http_callback" | tee /etc/marathon/conf/event_subscriber

# Force zookeeper to use ipv4 (netstat -ntplv | grep 2181)
# echo 'JAVA_OPTS="-Djava.net.preferIPv4Stack=true"' > /etc/default/zookeeper

# start services
service zookeeper restart
service mesos-master restart
service marathon restart

#screen -dmS mesos-master bash -c  "/usr/sbin/mesos-master --ip=$LOCAL_IP_ADDRESS --work_dir=/var/lib/mesos"
