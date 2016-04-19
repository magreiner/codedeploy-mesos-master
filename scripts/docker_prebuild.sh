#!/bin/bash

MIN_MASTER_INSTANCES=1
MASTER_INSTANCE_TAGNAME="AS_Master"
WORKER_INSTANCE_TAGNAME="AS_Worker"

LOCAL_IP_ADDRESS="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
AZ="$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)"
REGION="${AZ::-1}"

# Looking for other master instances for HA (Zookeeper)
MASTER_IPS="$(aws ec2 describe-instances --region $REGION --filters "Name=tag:Name,Values=$MASTER_INSTANCE_TAGNAME" | jq '. | {ips: .Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddress}' | grep "\." | cut -f4 -d'"')"
FIRST_MASTER_IP="$(echo "$MASTER_IPS" | head -n1)"

# Preload seafile docker image
# If a old docker container is already running
# it will be removed and newly build

ssh-keyscan bitbucket.org >> ~/.ssh/known_hosts
rm -rf /tmp/docbox 2>/dev/null

docker run -d -p 5000:5000 --restart=always --name registry \
      -v /opt/docker/registry:/var/lib/registry \
      registry:2

git clone https://bitbucket.org/m_greiner/docbox.git /tmp/docbox 2>/dev/null

mkdir /tmp/docbox/seafile/secrets/
mkdir /tmp/docbox/mysql/secrets/
cp /root/.vault-token /tmp/docbox/seafile/secrets/
cp /root/.vault-token /tmp/docbox/mysql/secrets/

SEAFILE_CONTAINER_NAME="$(docker ps | grep "seafile" | cut -d' ' -f1)"
docker kill $SEAFILE_CONTAINER_NAME &>/dev/null
docker rm $SEAFILE_CONTAINER_NAME &>/dev/null
docker rmi seafile &>/dev/null
docker build -t "seafile" "/tmp/docbox/seafile/"
docker tag "seafile" $FIRST_MASTER_IP:5000/seafile
docker push $FIRST_MASTER_IP:5000/seafile

MYSQL_CONTAINER_NAME="$(docker ps | grep "mysql" | cut -d' ' -f1)"
docker kill $MYSQL_CONTAINER_NAME &>/dev/null
docker rm $MYSQL_CONTAINER_NAME &>/dev/null
docker rmi mysql &>/dev/null
docker build -t "mysql" "/tmp/docbox/mysql/"
docker tag "mysql" $FIRST_MASTER_IP:5000/mysql
docker push $FIRST_MASTER_IP:5000/mysql
