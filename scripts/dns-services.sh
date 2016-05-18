
LOCAL_IP_ADDRESS="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

# Make mesos-dns binary useable
mv /usr/bin/mesos-dns-v* /usr/bin/mesos-dns
chmod +x /usr/bin/mesos-dns

# Create configuration
mkdir -p /etc/mesos-dns/
cat > /etc/mesos-dns/config.json << EOF
{
  "zk": "zk://$LOCAL_IP_ADDRESS:2181/mesos",
  "masters": ["$LOCAL_IP_ADDRESS:5050"],
  "refreshSeconds": 60,
  "ttl": 60,
  "domain": "mesos",
  "port": 8600,
  "resolvers": ["$(cat /etc/resolv.conf | grep nameserver | cut -d' ' -f2)"],
  "timeout": 5,
  "httpon": true,
  "dnson": true,
  "httpport": 8123,
  "externalon": true,
  "listener": "0.0.0.0",
  "SOAMname": "ns1.mesos",
  "SOARname": "root.ns1.mesos",
  "SOARefresh": 60,
  "SOARetry":   600,
  "SOAExpire":  86400,
  "SOAMinttl": 60,
  "IPSources": ["netinfo", "docker", "mesos", "host"]
}
EOF

cat > /etc/init/mesos-dns.conf << EOF2
description "mesos dns service"

start on runlevel [2345]
stop on runlevel [!2345]

respawn

# pre-start script
  # ensure nameservers are correct
  # service resolvconf restart
  # sleep 1
# end script

script
  ulimit -n 65536
  /usr/bin/mesos-dns -v 1 -config /etc/mesos-dns/config.json
end script

# post-start script
#   service resolvconf stop
#
#   SEARCH_ORIG="\$(cat /etc/resolv.conf | grep search | cut -d' ' -f2)"
#   while [ -z "\$SEARCH_ORIG" ]; do
#     sleep 1
#     echo "Waiting for original domain names. (DEBUG: SEARCH_ORIG=\$SEARCH_ORIG)"
#     SEARCH_ORIG="\$(cat /etc/resolv.conf | grep search | cut -d' ' -f2)"
#   done
#   cat > /etc/resolv.conf << EOF
# nameserver 127.0.0.1
# search \$SEARCH_ORIG
# EOF
# end script

EOF2

stop mesos-dns
start mesos-dns

# test with
# dig leader.mesos @localhost -p8600

# Error if run as main dns service:
# ERROR: 2016/05/18 09:43:15 exchanger.go:45: dial udp 127.0.0.1:53: socket: too many open files: exchanging &dns.Msg{MsgHdr:dns.MsgHdr{Id:0x195, Response:false, Opcode:0, Authoritative:false, Truncated:false, RecursionDesired:true, RecursionAvailable:false, Zero:false, AuthenticatedData:false, CheckingDisabled:false, Rcode:0}, Compress:false, Question:[]dns.Question{dns.Question{Name:"www.google.de.eu-central-1.compute.internal.", Qtype:0x1, Qclass:0x1}}, Answer:[]dns.RR{}, Ns:[]dns.RR{}, Extra:[]dns.RR{}} with "127.0.0.1:53"
