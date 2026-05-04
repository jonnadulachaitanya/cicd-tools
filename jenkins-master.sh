#!/bin/bash

yum install -y cloud-utils-growpart lvm2

sleep 10   # wait for disk

# resize disk
growpart /dev/nvme0n1 4 # resize partition 4 to use the new space

pvresize /dev/nvme0n1p4 # resize physical volume to use the new space

lvextend -L +10G /dev/RootVG/rootVol
lvextend -L +10G /dev/mapper/RootVG-varVol
lvextend -l +100%FREE /dev/mapper/RootVG-varTmpVol

xfs_growfs /
xfs_growfs /var/tmp
xfs_growfs /var

# Jenkins install
curl -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum install fontconfig java-17-openjdk jenkins -y

systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins
