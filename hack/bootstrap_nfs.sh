#!/bin/bash
#filename=bootstrap_nfs.sh

# Update hosts file
echo "[TASK 1] Update /etc/hosts file"
cat >>/etc/hosts<<EOF
192.168.0.200 k8s-nfs-server
192.168.0.201 k8s-n1
192.168.0.202 k8s-n2
192.168.0.203 k8s-m1
EOF

echo "[TASK 2] Download and install NFS server"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update && sudo apt-get install -y nfs-kernel-server

echo "[TASK 3] Create a kubedata directory"
mkdir -p /srv/nfs/kubedata
mkdir -p /srv/nfs/kubedata/db
mkdir -p /srv/nfs/kubedata/storage
mkdir -p /srv/nfs/kubedata/logs
sudo chown -R nobody:nogroup /srv/nfs/kubedata/

echo "[TASK 4] Update the shared folder access"
chmod -R 777 /srv/nfs/kubedata

echo "[TASK 5] Make the kubedata directory available on the network"
cat >>/etc/exports<<EOF
/srv/nfs/kubedata    *(rw,sync,no_subtree_check,no_root_squash)
EOF

echo "[TASK 6] Export the updates"
sudo exportfs -rav

echo "[TASK 7] Enable NFS Server"
sudo systemctl enable nfs-kernel-server

echo "[TASK 8] Start NFS Server"
sudo systemctl restart nfs-kernel-server