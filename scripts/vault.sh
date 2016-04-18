#!/bin/bash

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


# screen -dmS mesos-agent bash -c  "/usr/bin/vault server -config=/etc/vault/config.json"
screen -dmS mesos-agent bash -c  "/usr/bin/vault server -config=/etc/vault/config.json -dev"
# export VAULT_ADDR='http://127.0.0.1:8200'
# vault init &>/root/vault.keys
#
# chmod +x unseal.expect
# vault unseal $(cat /root/vault.keys | grep "Key 1" | cut -d" " -f3)
# vault unseal $(cat /root/vault.keys | grep "Key 2" | cut -d" " -f3)
# vault unseal $(cat /root/vault.keys | grep "Key 3" | cut -d" " -f3)
#
echo "$(cat /root/vault.keys | grep "Root Token: " | cut -d" " -f3)" > .vtoken
