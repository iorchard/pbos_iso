#!/bin/bash

set -euo pipefail

repos=(baseos appstream epel powertools mariadb-main advanced-virtualization openstack-wallaby rabbitmq_erlang rabbitmq_server-noarch centos-nfv-openvswitch ceph ceph-noarch)

for r in ${repos[@]}
do
  dnf -y reposync --delete --download-path=/srv/pbos/ \
    --newest-only --arch=x86_64 --arch=noarch --repoid=$r
done
