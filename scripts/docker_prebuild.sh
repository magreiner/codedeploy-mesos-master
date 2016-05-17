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

sudo docker kill registry > /dev/null 2>&1
sudo docker rm registry > /dev/null 2>&1
docker run -d -p 5000:5000 --restart=always --name registry \
      -v /opt/docker/registry:/var/lib/registry \
      registry:2
