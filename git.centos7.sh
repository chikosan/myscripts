#!/bin/bash
# Install git on centos7

sudo cat <<EOT >> /etc/yum.repos.d/wandisco-git.repo
[wandisco-git]
name=Wandisco GIT Repository
baseurl=http://opensource.wandisco.com/centos/7/git/$basearch/
enabled=1
gpgcheck=1
gpgkey=http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco
EOT
sudo rpm --import http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco
sudo yum install git -y
