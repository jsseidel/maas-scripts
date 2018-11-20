#!/bin/bash

if [[ ! $(virsh net-list | grep maas | grep -v grep) ]] ; then
   echo "Can't find maas libvirt network. Create one with DHCP disabled and run again."
   exit 1
fi

USER=jsseidel
LAUNCHPAD_USER=$USER
CONTAINER=maas-dev
CIDR=172.16.99.12/24
lxc init ubuntu:bionic $CONTAINER -s default --no-profiles
lxc network attach virbr0 $CONTAINER eth0 eth0
lxc network attach virbr2 $CONTAINER eth1 eth1
lxc config set $CONTAINER user.user-data "#cloud-config
users:
  - name: $USER
    shell: /bin/bash
    ssh_import_id: $LAUNCHPAD_USER
    sudo: ALL=(ALL) NOPASSWD:ALL
package_upgrade: true
packages:
  - build-essential
  - jq
  - libvirt-bin
  - qemu-kvm
locale: en_US.UTF-8
timezone: $(timedatectl | grep 'Time zone:' | awk '{print $3}')
runcmd:
  - [touch, /tmp/startup-complete]
"

lxc config set $CONTAINER user.network-config "version: 2
ethernets:
  eth0:
    match:
      name: eth0
    dhcp4: true
  eth1:
    match:
      name: eth1
bridges:
  br0:
    interfaces: [eth1]
    addresses:
     - $CIDR
"
lxc config device add $CONTAINER kvm unix-char path=/dev/kvm
lxc start --verbose $CONTAINER
lxc exec --verbose $CONTAINER -- /bin/bash -c 'while ! [ -f /tmp/startup-complete ]; do sleep 10 ; echo sleeping 10 seconds ; done'
lxc exec $CONTAINER bash
kvm-ok
