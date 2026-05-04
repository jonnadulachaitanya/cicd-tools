#!/bin/bash

yum install -y cloud-utils-growpart lvm2

sleep 10   # wait for disk to be ready

# resize disk
growpart /dev/nvme0n1 4 # resize partition 4 to use the new space


pvresize /dev/nvme0n1p4 # resize physical volume to use the new space

lvextend -L +10G /dev/mapper/RootVG-homeVol
lvextend -L +10G /dev/mapper/RootVG-varVol
lvextend -l +100%FREE /dev/mapper/RootVG-varTmpVol

xfs_growfs /home
xfs_growfs /var/tmp
xfs_growfs /var

yum install -y java-17-openjdk yum-utils zip

# Terraform
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum install -y terraform

# NodeJS
dnf module disable nodejs -y
dnf module enable nodejs:20 -y
dnf install -y nodejs

# Docker
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Maven
dnf install -y maven

# Python
dnf install -y python3.11 gcc python3-devel
