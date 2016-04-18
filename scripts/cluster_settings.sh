#!/bin/bash

ACCESS_INSTANCE_TAGNAME="AS_Access"

AZ="$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)"
REGION="${AZ::-1}"

LOCAL_IP_ADDRESS="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
ACCESS_SERVER_IP="$(aws ec2 describe-instances --region $REGION --filters "Name=tag:Name,Values=$ACCESS_INSTANCE_TAGNAME" | jq '. | {ips: .Reservations[].Instances[].NetworkInterfaces[].Association.PublicIp}' | grep "\." | cut -f4 -d'"')"

# install requirements
apt-get install pwgen

# wait for mesos-master and consul to get ready
sleep 20

# Mysql Settings
export VAULT_ADDR="http://$LOCAL_IP_ADDRESS:8201"
export VAULT_TOKEN="$(cat /root/vault.keys | grep "Root Token: " | cut -d" " -f3)"
vault write secret/mysql/MYSQL_ROOT_PASS value="$(pwgen)"
vault write secret/mysql/MYSQL_SEAFILE_USER value="$seafile"
vault write secret/mysql/MYSQL_SEAFILE_PASS value="$(pwgen)"

# Seafile Settings
vault write secret/seafile/SEAFILE_ADMIN_EMAIL value="adm@adm.de"
vault write secret/seafile/SEAFILE_ADMIN_PASS value="$(pwgen)"
vault write secret/seafile/SEAFILE_SERVER_IP value="$ACCESS_SERVER_IP"

# Start Services
curl -X PUT http://localhost:8080/v2/apps -d @/tmp/basic.json -H "Content-type: application/json" &> /tmp/basic.log


# Start Prometheus
docker kill prometheus &>/dev/null
docker rm prometheus &>/dev/null
docker run --name prometheus -d -p 9090:9090 -v /tmp/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus

# Access Container:
# docker exec -it prometheus /bin/sh

# Get some stats:
# apt-get update
# apt-get --yes install hatop vim-tiny
# export TERM=vt100
# hatop -s /var/run/haproxy/socket
