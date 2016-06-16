#!/bin/bash

MASTER_INSTANCE_TAGNAME="AS_Master"
AZ="$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)"
REGION="${AZ::-1}"
MASTER_IPS="$(aws ec2 describe-instances --region $REGION --filters "Name=tag:Name,Values=$MASTER_INSTANCE_TAGNAME" | jq '. | {ips: .Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddress}' | grep "\." | cut -f4 -d'"')"
FIRST_MASTER_IP="$(echo "$MASTER_IPS" | head -n1)"

# install requirements
apt-get install -yq unzip

# install vault
unzip -o /tmp/vault_*_linux_amd64.zip -d /usr/bin/
rm /tmp/vault_*_linux_amd64.zip
chmod +x /usr/bin/vault

mkdir /etc/vault
cat > /etc/vault/config.json <<EOF
backend "inmem" {
  address = "127.0.0.1:8500"
  path = "vault"
}

listener "tcp" {
 address = "0.0.0.0:8201"
 tls_disable = 1
}
EOF

# screen -X -S vault-server quit # error: prevents vaul to start again inside screen
kill $(ps -eopid,cmd | grep -ve "grep" | grep "/usr/bin/vault server" | cut -d' ' -f1) &>/dev/null
screen -dmS vault-server bash -c  "/usr/bin/vault server -config=/etc/vault/config.json"

export VAULT_ADDR="http://$FIRST_MASTER_IP:8201"
echo "export VAULT_ADDR=\"http://$FIRST_MASTER_IP:8201\"" >> /home/ubuntu/.bashrc
echo "export VAULT_ADDR=\"http://$FIRST_MASTER_IP:8201\"" >> /root/.bashrc

# initialize the vault
sleep 2
vault init &>/root/vault.keys
echo "$(cat /root/vault.keys | grep "Root Token: " | cut -d" " -f4)" > /root/.vault-token
export VAULT_TOKEN="$(cat /root/.vault-token)"
echo "export VAULT_TOKEN=\"$VAULT_TOKEN\"" >> /home/ubuntu/.bashrc
echo "export VAULT_TOKEN=\"$VAULT_TOKEN\"" >> /root/.bashrc

vault unseal $(cat /root/vault.keys | grep "Key 1" | cut -d" " -f3)
vault unseal $(cat /root/vault.keys | grep "Key 2" | cut -d" " -f3)
vault unseal $(cat /root/vault.keys | grep "Key 3" | cut -d" " -f3)

# continue, even if vault fails
true
# curl -X GET -H "X-Vault-Token:$VAULT_TOKEN" http://192.168.10.89:8201/v1/sys/auth
