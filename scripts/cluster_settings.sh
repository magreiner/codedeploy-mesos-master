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
# docker run -d \
#   --name spark-master \
#   -p 4040:4040 \
#   -p 6066:6066 \
#   -p 7077:7077 \
#   -p 8081:8080 \
#   -t spark \
#   master


# wait for the first master to be ready (=marathon running)
RESULT="$(curl -s $FIRST_MASTER_IP:8080/ping)"
while [[ "$RESULT" !=  "pong" ]]; do
  sleep 2
  echo "Waiting for marathon to be ready for initial deployment."
  RESULT="$(curl -s $FIRST_MASTER_IP:8080/ping)"
done

# Start Spark-Master
/bin/bash /opt/spark/sbin/stop-master.sh
/bin/bash /opt/spark.sh master quiet &> /tmp/spark-master-start.log &

curl -s -X DELETE "http://localhost:8080/v2/apps/spark-slave?force=true"; echo ""
sed -i "s/MASTER/$FIRST_MASTER_IP:5000/g" /tmp/spark-slave.json
curl -X PUT http://localhost:8080/v2/apps?force=true -d @/tmp/spark-slave.json -H "Content-type: application/json"; echo ""

# revert old homedir
bash /home/ubuntu/debug.sh

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
