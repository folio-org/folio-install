#!/bin/sh
# EXPERIMENTAL!!!
# Run this script to clean out the Kubernetes and Rancher 2.0 nodes.

if [ $(id -u) -ne 0 ]; then
  echo "Must be run as root!"
  exit
fi 

DLIST="/var/lib/etcd /etc/kubernetes /etc/cni /opt/cni /var/lib/cni /var/run/calico /opt/rke"
for dir in $DLIST; do
  echo "Removing $dir"
  rm -rf $dir
done
