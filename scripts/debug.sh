#!/bin/bash

cd /home/ubuntu

cat >> /home/ubuntu/.bash_history <<EOF
sbt assembly; stty erase ^H
sbt assembly && spark-submit target/scala-2.10/TwitterStreamProcessing-assembly-1.0.jar; stty erase ^H
EOF

cat >> /home/ubuntu/.bashrc << EOF
# Add frequently used programs to env PATH
export PATH=\$PATH:/home/ubuntu/git/scripts/aws
export PATH=\$PATH:/home/ubuntu/git/scripts/aws/Cluster
export PATH=\$PATH:/home/ubuntu/git/scripts/git
export PATH=\$PATH:/opt/spark/bin
EOF

# restore saved stuff
aws s3 cp --region "eu-central-1" s3://filestore-eu-central-1/ec2-init/home.tar.bz2 /tmp/ && \
sudo su -s /bin/bash ubuntu -c "tar -C /home/ubuntu/ -xpPf /tmp/home.tar.bz2" && \
rm /tmp/home.tar.bz2

echo "deb http://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 642AC823
apt-get update
apt-get -y --force-yes install sbt

# Add repositorys
mkdir cluster
ssh-keyscan bitbucket.org >> ~/.ssh/known_hosts
ssh-keyscan github.com >> ~/.ssh/known_hosts
git clone git@github.com:magreiner/codedeploy-mesos.git cluster/codedeploy-mesos
git clone git@github.com:magreiner/codedeploy-mesos-access.git cluster/codedeploy-mesos-access
git clone git@github.com:magreiner/codedeploy-mesos-master.git cluster/codedeploy-mesos-master
git clone git@bitbucket.org:m_greiner/docbox.git cluster/docbox

# install debug tools
sudo apt-get install -yq firefox chromium-browser flashplugin-installer

echo "Complete"
