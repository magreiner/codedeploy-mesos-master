#!/bin/bash

# Add repositorys
mkdir git
cd git
ssh-keyscan bitbucket.org >> ~/.ssh/known_hosts
ssh-keyscan github.com >> ~/.ssh/known_hosts
git clone git@github.com:magreiner/codedeploy-mesos.git
git clone git@github.com:magreiner/codedeploy-mesos-master.git
git clone git@bitbucket.org:m_greiner/docbox.git

# install debug tools
apt-get install -yq firefox chromium-browser flashplugin-installer


echo "Complete"
