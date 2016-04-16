#!/bin/bash

LOCAL_IP_ADDRESS="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"

# install requirements
apt-get install -yq unzip
pip install consulate

# Create consul user
adduser --quiet --disabled-password -shell /bin/bash --home /home/consul --gecos "User" consul &>/dev/null

rm -rf /var/consul &>/dev/null
mkdir /var/consul
chown consul:consul /var/consul

# Create config files
rm -rf /etc/consul.d &>/dev/null
mkdir -p /etc/consul.d/{bootstrap,server}
cat > /etc/consul.d/bootstrap/config.json << EOF
{
    "bootstrap": true,
    "node_name": "Consul-Bootstrap",
    "server": true,
    "bind_addr": "$LOCAL_IP_ADDRESS",
    "client_addr": "0.0.0.0",
    "datacenter": "MesosCluster",
    "data_dir": "/var/consul",
    "ui_dir": "/opt/consul",
    "encrypt": "W0OoYJkDcHa+EwmUtbOtcA==",
    "log_level": "INFO",
    "enable_syslog": true
}
EOF

# for now the server will stay in bootstrap mode
# full implementation with equal servers will follow
ln -s /etc/consul.d/bootstrap/config.json /etc/consul.d/server/config.json

# Extract consul binary
unzip -o /tmp/consul_*_linux_amd64.zip -d /usr/bin/
rm /tmp/consul_*_linux_amd64.zip
chmod +x /usr/bin/consul

# su -s /bin/bash "consul" -c "/usr/bin/consul agent -config-dir /etc/consul.d/bootstrap"
initctl reload-configuration
stop consul-server &>/dev/null
start consul-server

# Debug with:
# consul agent -server \
#     -bootstrap-expect 1 \
#     -data-dir /var/consul \
#     -node=Server-$LOCAL_IP_ADDRESS \
#     -bind="$LOCAL_IP_ADDRESS" \
#     -client=0.0.0.0 \
#     -config-dir /etc/consul.d \
#     -ui-dir /opt/consul-ui/

# Extract consul web_ui
rm -rf /opt/consul/ &>/dev/null
unzip  -o /tmp/consul_*_web_ui.zip -d /opt/consul/
rm /tmp/consul_*_web_ui.zip
chown -R consul:consul /opt/consul

# Extract and start consul-template
# Source:
# https://releases.hashicorp.com/consul-template/
unzip -o /tmp/consul-template_*_linux_amd64.zip -d /usr/bin/
rm /tmp/consul-template_*_linux_amd64.zip
chmod a+x /usr/bin/consul-template

# consul-template \
#     -consul $LOCAL_IP_ADDRESS:8500 \
#     -template "$PATH_TO_TEMPLATE:$PATH_TO_CONFIG_FILE" \
#     -retry 30s
