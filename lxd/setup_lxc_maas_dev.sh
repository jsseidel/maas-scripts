#!/bin/bash

CONTAINER=maas-dev
LAUNCHPAD_USER=$USER

lxc init ubuntu:bionic $CONTAINER -s default --no-profiles
lxc network attach virbr0 $CONTAINER eth0 eth0

#####
## Uncomment to access home directory within container
#
# An idmap is required in order to allow for a read/write container $HOME,
# and to run X11 apps that will display on the host.
#lxc config set $CONTAINER raw.idmap "both $UID 1000"

# Remap home directory.
#lxc config device add $CONTAINER home disk source=$HOME path=/home/$USER
#
##
#####

# Allow use of DISPLAY=:1 (gdb typically runs on :0; adjust as needed)
lxc config device add $CONTAINER X1 disk path=/tmp/.X11-unix/X0 source=/tmp/.X11-unix/X0

# Allow GPU passthrough for X applications
lxc config device add $CONTAINER gpu gpu
lxc config device set $CONTAINER gpu uid 1000
lxc config device set $CONTAINER gpu gid 1000

lxc config set $CONTAINER user.user-data "#cloud-config
users:
  - name: $USER
    shell: /bin/bash
    ssh_import_id: $LAUNCHPAD_USER
    sudo: ALL=(ALL) NOPASSWD:ALL
package_upgrade: true
packages:
  - jq
  - build-essential
  - x11-apps
  - default-jre
  - fonts-dejavu-core
  - fonts-freefont-ttf
  - ttf-ubuntu-font-family
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
"
lxc config device add $CONTAINER kvm unix-char path=/dev/kvm
lxc start $CONTAINER
lxc exec $CONTAINER -- /bin/bash -c 'while ! [ -f /tmp/startup-complete ]; do sleep 0.5; done'

