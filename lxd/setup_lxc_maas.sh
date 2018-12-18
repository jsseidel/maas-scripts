CONTAINER=maas-run
CIDR=172.16.99.2/24
lxc init ubuntu:bionic $CONTAINER -s default --no-profiles
lxc network attach virbr0 $CONTAINER eth0 eth0
lxc network attach virbr1 $CONTAINER eth1 eth1
lxc config set $CONTAINER user.user-data "#cloud-config
package_upgrade: true
apt:
  sources:
    maas:
      source: ppa:maas/next
packages:
  - jq
  - maas
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
lxc start $CONTAINER
lxc exec $CONTAINER -- /bin/bash -c 'while ! [ -f /tmp/startup-complete ]; do clear ; cat /var/log/cloud-init-output.log ; sleep 2; done'
echo
echo
echo "Setup complete."
