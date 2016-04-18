MASTER_INSTANCE_TAGNAME="AS_Master"

LOCAL_IP_ADDRESS="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

mkdir -p /etc/mesos-dns/
cat > /etc/mesos-dns/config.json << EOF
{
  "zk": "zk://$LOCAL_IP_ADDRESS:2181/mesos",
  "masters": ["$LOCAL_IP_ADDRESS:5050"],
  "refreshSeconds": 60,
  "ttl": 60,
  "domain": "mesos",
  "port": 53,
  "resolvers": ["169.254.169.254"],
  "timeout": 5,
  "httpon": true,
  "dnson": true,
  "httpport": 8123,
  "externalon": true,
  "listener": "$LOCAL_IP_ADDRESS",
  "SOAMname": "ns1.mesos",
  "SOARname": "root.ns1.mesos",
  "SOARefresh": 60,
  "SOARetry":   600,
  "SOAExpire":  86400,
  "SOAMinttl": 60,
  "IPSources": ["netinfo", "mesos", "host"]
}
EOF
