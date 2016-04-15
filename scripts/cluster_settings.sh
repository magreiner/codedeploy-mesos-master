#!/bin/bash

ACCESS_INSTANCE_TAGNAME="AS_Access"

AZ="$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)"
REGION="${AZ::-1}"

LOCAL_IP_ADDRESS="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
ACCESS_SERVER_IP="$(aws ec2 describe-instances --region $REGION --filters "Name=tag:Name,Values=$ACCESS_INSTANCE_TAGNAME" | jq '. | {ips: .Reservations[].Instances[].NetworkInterfaces[].Association.PublicIp}' | grep "\." | cut -f4 -d'"')
"

# install requirements
apt-get install pwgen

# wait for mesos-master and consul to get ready
sleep 20

# Mysql Settings
# consulate kv ls
consulate kv mkdir mysql
consulate kv set mysql/MYSQL_ROOT_PASS "$(pwgen)"
consulate kv set mysql/MYSQL_SEAFILE_PASS "$(pwgen)"

# Seafile Settings
consulate kv mkdir seafile
consulate kv set seafile/SEAFILE_ADMIN_EMAIL "adm@adm.de"
consulate kv set seafile/SEAFILE_ADMIN_PASS "$(pwgen)"
consulate kv set seafile/SEAFILE_SERVER_IP "$ACCESS_SERVER_IP"

# Start Services
curl -X PUT http://localhost:8080/v2/groups -d @/tmp/basic.json -H "Content-type: application/json" &> /tmp/basic.log
