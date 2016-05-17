#!/bin/bash

ACCESS_INSTANCE_TAGNAME="AS_Access"
MASTER_INSTANCE_TAGNAME="AS_Master"

AZ="$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)"
REGION="${AZ::-1}"

LOCAL_IP_ADDRESS="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
# ACCESS_SERVER_IP="$(aws ec2 describe-instances --region $REGION --filters "Name=tag:Name,Values=$ACCESS_INSTANCE_TAGNAME" | jq '. | {ips: .Reservations[].Instances[].NetworkInterfaces[].Association.PublicIp}' | grep "\." | cut -f4 -d'"')"
MASTER_IPS="$(aws ec2 describe-instances --region $REGION --filters "Name=tag:Name,Values=$MASTER_INSTANCE_TAGNAME" | jq '. | {ips: .Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddress}' | grep "\." | cut -f4 -d'"')"
FIRST_MASTER_IP="$(echo "$MASTER_IPS" | head -n1)"

# vault write secret/ACCESS_SERVER_IP value="$ACCESS_SERVER_IP"

# Start Services
sed -i "s/MASTER/$FIRST_MASTER_IP:5000/g" /tmp/basic.json
# curl -X PUT http://localhost:8080/v2/apps -d @/tmp/basic.json -H "Content-type: application/json" &> /tmp/basic.log


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
