#!/bin/bash

# Add repositorys
mkdir git
ssh-keyscan bitbucket.org >> ~/.ssh/known_hosts
ssh-keyscan github.com >> ~/.ssh/known_hosts
git clone git@github.com:magreiner/codedeploy-mesos.git git/codedeploy-mesos
git clone git@github.com:magreiner/codedeploy-mesos-access.git git/codedeploy-mesos-access
git clone git@github.com:magreiner/codedeploy-mesos-master.git git/codedeploy-mesos-master.git
git clone git@bitbucket.org:m_greiner/docbox.git git/docbox

ln -s git/docbox/seafile/

# install debug tools
sudo apt-get install -yq firefox chromium-browser flashplugin-installer

echo "Complete"
