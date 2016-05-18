#!/bin/bash

MASTER_INSTANCE_TAGNAME="AS_Master"

LOCAL_IP_ADDRESS="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
AZ="$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)"
REGION="${AZ::-1}"

# Looking for other master instances for HA (Zookeeper)
MASTER_IPS="$(aws ec2 describe-instances --region $REGION --filters "Name=tag:Name,Values=$MASTER_INSTANCE_TAGNAME" | jq '. | {ips: .Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddress}' | grep "\." | cut -f4 -d'"')"
FIRST_MASTER_IP="$(echo "$MASTER_IPS" | head -n1)"

# Preload seafile docker image
# If a old docker container is already running
# it will be removed and newly build

docker kill registry > /dev/null 2>&1
docker rm registry > /dev/null 2>&1
docker run -d \
  --name registry \
  -p 5000:5000 \
  --restart=always \
  -v /mnt/docker-registry:/var/lib/registry \
  -t registry:latest

docker kill spark-master > /dev/null 2>&1
docker rm spark-master > /dev/null 2>&1
docker build -t spark /tmp/docker-spark/spark
docker tag -f "spark:latest" "$FIRST_MASTER_IP:5000/spark:latest"
docker run -d \
  --name spark-master \
  -p 4040:4040 \
  -p 6066:6066 \
  -p 7077:7077 \
  -p 8081:8080 \
  -t spark \
  master

# waiting for repository to be ready
RESULT="$(curl -s $FIRST_MASTER_IP:5000)"
while [[ "$RESULT" !=  *"docker-registry server"* ]]; do
  sleep 2
  echo "$0: Waiting for docker-registry server to be ready."
  RESULT="$(curl -s $FIRST_MASTER_IP:5000)"
done

# upload images to repository
docker push "$FIRST_MASTER_IP:5000/spark:latest"
