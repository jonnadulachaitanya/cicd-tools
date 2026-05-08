#!/bin/bash
set -euxo pipefail
exec > /var/log/user-data.log 2>&1

echo "==== START MASTER SETUP ===="

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

lvextend -L +10G /dev/mapper/RootVG-rootVol
lvextend -L +10G /dev/mapper/RootVG-varVol
lvextend -l +100%FREE /dev/mapper/RootVG-varTmpVol

xfs_growfs /
xfs_growfs /var
xfs_growfs /var/tmp

echo "==== DISK RESIZE DONE ===="

# -------------------------------
# Java (install separately)
# -------------------------------

sudo curl -L -o /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/rpm-stable/jenkins.repo

sudo rpm --import https://pkg.jenkins.io/rpm-stable/jenkins.io-2023.key

sudo dnf install -y fontconfig java-21-openjdk

sudo dnf install -y jenkins

sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "==== MASTER SETUP COMPLETED ===="
