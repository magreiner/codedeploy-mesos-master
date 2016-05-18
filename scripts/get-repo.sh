#!/bin/bash

DOCKER_IMAGE_BUILD_DIR="/tmp/docker-spark"
DOCKER_IMAGE_GIT_REPO="git@bitbucket.org:m_greiner/docker-spark.git"
HOME="/root"

# Get git repository with docker containers
if [[ -d "$DOCKER_IMAGE_BUILD_DIR" ]]; then
  git -C "$DOCKER_IMAGE_BUILD_DIR" pull
else
  ssh-keyscan bitbucket.org >> $HOME/.ssh/known_hosts 2>/dev/null
  cat > $HOME/.ssh/id_rsa.spark <<EOF
-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAyG6iMs9mdQkL3gpfH6UlsM0kUzmcPUXq5Cn140bzzsbJcSoY
+3DnEvTOhy7xex2nsKilL4ppAO7ddmly3tujIM/W2HcYmGmndB/qE1uSX7l6+VuN
CNF8hzyrMqsqG2bgz8FMOm83ac8ZqZFQWsGYHAYxqumRDVZE/qyZzTpWFJftwj4/
7+9XApqziPbKfRd9SXpoHByfGKvLH1ZZMmpYhybNntr6Ws7CR9Rr+UIHjn5JWfS4
BYPVkS76eX8rlUYp8ufYcG545qL3D0Io4S5QWT7QgujMtwvlqo0Z4YBBeoa+hgDF
UOU9lu4tFis6KYwsfLj2bfODonQGtLfhGHwzSwIDAQABAoIBAHBAhdavEVK6nkrc
xCmU9GbwfUefHEG0xrjCR1PiiOllq6wVR6iKst+K+5/6SoQJN8FYsirN+cDsBlwq
8oqdt97IiCrziHLTuVTwCsiMoI2784N0IqitqnCTKc5Wzl5KX937BBY183Lu6hBt
sfMiOW54iZiO9w3hIwL+56Ro54zgDAzqYM430Msdoxp4uorwNteAN6J0XNUezGvB
u64C9i1wTj3cT/eOzejNOXjSeniQN7PCTsjtBWb/lXm7mOIPTerqCSGVGkpMmuuY
GGh7rvUFC2aL0mIpXS7Yfg4Qxwe2teB1rPs02nV+suyLNvcyahPFUuAG/n/nG/vy
OkJHVgECgYEA6enUprpPikjx8cqxoEyGqc1w8WJiM8lUzBFXgSj3ZswOgMVt5cnR
uA8izqJ98vCliyqEft33oxCylz6p1w19JerPnNeQHkHKECgejcgUDiBPd5RwpwBX
FBkGyWsq5ZaYnJirkI7HVxx4Z25PGlMFAug2e381zUq84FZVi6rjMMkCgYEA21t+
CU2OnvNdcTnycAXcebU8eAvHXoWbDw0BBiCrmwSz5Pd7tukoTQObud19auoaeIWh
wP/ZUkdQcY+G3D8w6Un9+spt5QbHrgsp08jWPsIO0HskDbwXsmBFf7ukcdDAZStM
oY7FJHQJBPaoxBb2+OGgV2hsQgMWQgXmwRYYgXMCgYAz+IkP1jtP7S8cWr2mcPpG
hee/Ke3JtcTKZlv7zX9SbqoWQEdPk8ytyWchZAb50C/nwLWZfnXD3DTh18Fij5Or
tgUUwuw5XMKpXlCTjc2u6czeM7Pn1vKB+6F/ZPkt84zK1jzgLGjr2N6DlIWswp9N
awyX2ca5aw6WBXiSRJCfyQKBgBHnTMkrmFlm2ZiVNzFneRBB95aAt5wCYZ5/3DaI
0hjL8HbesC1EqHJoufwYlNT2GIT/uy0KdM1fXrR2F3bAfZh83orqnL+VpxSQerB7
cukaY6Umd9HbKT/41ZNQWGKlvB5Fw3JoObT494d9Llca3LuBhtm7fyKAJ//phWT7
DbL7AoGAEV28HlfIfhzkmGeAvshXZwUL30C467SnqyzI2lAm7Dcdlkp6/jWIRjox
S+MeeAbRnKpr5u4femyaKZTomdzgwVI9Eqrz8G5KujSw1ZRVqEIICby9RCfOvnXH
i8/pGuIl8Xl/upa8meq1qQzUm79Alv+6AKCZmwyttVPgcxte9S4=
-----END RSA PRIVATE KEY-----
EOF
  cat > $HOME/.ssh/id_rsa.spark.pub <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIbqIyz2Z1CQveCl8fpSWwzSRTOZw9RerkKfXjRvPOxslxKhj7cOcS9M6HLvF7HaewqKUvimkA7t12aXLe26Mgz9bYdxiYaad0H+oTW5JfuXr5W40I0XyHPKsyqyobZuDPwUw6bzdpzxmpkVBawZgcBjGq6ZENVkT+rJnNOlYUl+3CPj/v71cCmrOI9sp9F31JemgcHJ8Yq8sfVlkyaliHJs2e2vpazsJH1Gv5QgeOfklZ9LgFg9WRLvp5fyuVRiny59hwbnjmovcPQijhLlBZPtCC6My3C+WqjRnhgEF6hr6GAMVQ5T2W7i0WKzopjCx8uPZt84OidAa0t+EYfDNL user@sparkcluster
EOF
  cat > $HOME/.ssh/config <<EOF
  Host bitbucket.org
    HostName bitbucket.org
    IdentityFile ~/.ssh/id_rsa.spark
    User m_greiner
EOF
  chmod 600 $HOME/.ssh/id_rsa.spark $HOME/.ssh/id_rsa.spark.pub
  git clone --depth=1 $DOCKER_IMAGE_GIT_REPO $DOCKER_IMAGE_BUILD_DIR
fi
