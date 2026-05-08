#!/bin/bash
set -euxo pipefail
exec > /var/log/user-data.log 2>&1

echo "==== START AGENT SETUP ===="

# -------------------------------
# Base packages
# -------------------------------
yum install -y cloud-utils-growpart lvm2 yum-utils git zip

sleep 10

# -------------------------------
# Disk Resize
# -------------------------------
growpart /dev/nvme0n1 4
pvresize /dev/nvme0n1p4

lvextend -L +10G /dev/mapper/RootVG-homeVol
lvextend -L +10G /dev/mapper/RootVG-varVol
lvextend -l +100%FREE /dev/mapper/RootVG-varTmpVol

xfs_growfs /home
xfs_growfs /var
xfs_growfs /var/tmp

echo "==== DISK RESIZE DONE ===="

# -------------------------------
# Java
# -------------------------------
sudo dnf install -y fontconfig java-21-openjdk

# -------------------------------
# Terraform
# -------------------------------
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum install -y terraform

# -------------------------------
# NodeJS
# -------------------------------
dnf module disable nodejs -y
dnf module enable nodejs:20 -y
dnf install -y nodejs

# -------------------------------
# Docker
# -------------------------------
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

# -------------------------------
# Helm
# -------------------------------
curl -fsSL -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 /tmp/get_helm.sh
/tmp/get_helm.sh

# -------------------------------
# Maven
# -------------------------------
dnf install -y maven

# -------------------------------
# Python
# -------------------------------
dnf install -y python3.11 gcc python3-devel

echo "==== AGENT SETUP COMPLETED ===="
