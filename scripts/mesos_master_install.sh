#!/bin/bash

LOCAL_IP_ADDRESS=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Add mesos repository
apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)
echo "deb http://repos.mesosphere.com/${DISTRO} ${CODENAME} main" > /etc/apt/sources.list.d/mesosphere.list

# install requirements
apt-get --yes update
apt-get --yes install mesos marathon curl


sudo service mesos-slave stop
echo manual | tee /etc/init/mesos-slave.override
echo $LOCAL_IP_ADDRESS | tee /etc/mesos-master/ip
echo zk://$LOCAL_IP_ADDRESS:2181/mesos | tee /etc/mesos/zk
echo TestCluster | tee /etc/mesos-master/cluster
echo $LOCAL_IP_ADDRESS | sudo tee /etc/mesos-master/hostname
echo 1 | tee /etc/zookeeper/conf/myid

# start services
service zookeeper restart
service mesos-master restart
service marathon restart

# cd /tmp
# curl -X PUT http://localhost:8080/v2/groups -d @basic.json -H "Content-type: application/json"


#screen -dmS mesos-master bash -c  "/usr/sbin/mesos-master --ip=$LOCAL_IP_ADDRESS --work_dir=/var/lib/mesos"
