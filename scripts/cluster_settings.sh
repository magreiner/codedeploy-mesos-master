#!/bin/bash

ACCESS_INSTANCE_TAGNAME="AS_Access"
MASTER_INSTANCE_TAGNAME="AS_Master"

AZ="$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)"
REGION="${AZ::-1}"

LOCAL_IP_ADDRESS="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
# ACCESS_SERVER_IP="$(aws ec2 describe-instances --region $REGION --filters "Name=tag:Name,Values=$ACCESS_INSTANCE_TAGNAME" --query 'Reservations[*].Instances[*].NetworkInterfaces[*].PrivateIpAddress' --output text)"
MASTER_IPS="$(aws ec2 describe-instances --region $REGION --filters "Name=tag:Name,Values=$MASTER_INSTANCE_TAGNAME" --query 'Reservations[*].Instances[*].NetworkInterfaces[*].PrivateIpAddress' --output text)"
FIRST_MASTER_IP="$(echo "$MASTER_IPS" | head -n1)"

# vault write secret/ACCESS_SERVER_IP value="$ACCESS_SERVER_IP"

# Start Services

# Start Prometheus
docker kill spark-master > /dev/null 2>&1
docker rm spark-master > /dev/null 2>&1
docker run -d \
  --name spark-master \
  -p 4040:4040 \
  -p 6066:6066 \
  -p 7077:7077 \
  -p 8081:8080 \
  -t spark \
  master

sed -i "s/MASTER/$FIRST_MASTER_IP:5000/g" /tmp/spark-slave.json
curl -X PUT http://localhost:8080/v2/apps -d @/tmp/spark-slave.json -H "Content-type: application/json"; echo ""


# # Start Prometheus
# docker kill prometheus &>/dev/null
# docker rm prometheus &>/dev/null
# docker run --name prometheus -d -p 9090:9090 -v /tmp/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus

# Access Container:
# docker exec -it prometheus /bin/sh

# Get some stats:
# apt-get update
# apt-get --yes install hatop vim-tiny
# export TERM=vt100
# hatop -s /var/run/haproxy/socket
