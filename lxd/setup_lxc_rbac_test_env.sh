#!/bin/bash -e

# This script is loosely based on the documentation here:
#     https://git.launchpad.net/crbs/tree/README.md

# Name of the container to install RBAC into. Must not yet exist.
CONTAINER=${CONTAINER:-"rbac"}
CONTAINER_IMAGE="${CONTAINER_IMAGE:-ubuntu:bionic}"

# Network configuration for new container.
CIDR="${CIDR:-172.16.99.3/24}"
GATEWAY="${GATEWAY:-172.16.99.1}"
NAMESERVER="${NAMESERVER:-172.16.42.1}"
ATTACH_BRIDGE="${ATTACH_BRIDGE:-virbr1}"

UBUNTU_MIRROR="${UBUNTU_MIRROR:-archive.ubuntu.com}"

CRBS_REPO="${CRBS_REPO:-$HOME/Downloads}"
CRBS_SNAP_FILE="${CRBS_SNAP_FILE:-crbs_0+git.6e6de41_amd64.snap}"
CRBS_DB_PASSWORD="${CRBS_DB_PASSWORD:-Password1}"
CRBS_MD5_PASSWORD="$(printf $CRBS_DB_PASSWORD | md5sum | awk '{ print $1 }')"

function fail() {
    echo "$@" 1>&2
    exit 1
}

lxc init $CONTAINER_IMAGE $CONTAINER -s default --no-profiles
lxc network attach $ATTACH_BRIDGE $CONTAINER eth1 eth1
lxc file push $CRBS_REPO/$CRBS_SNAP_FILE $CONTAINER/root/$CRBS_SNAP_FILE > /dev/null 2>&1 || fail "Transfer failed."

lxc config set $CONTAINER user.user-data "#cloud-config
package_upgrade: true
ssh_pwauth: true
users:
  - default
apt:
  primary:
    - arches: [default]
      uri: http://$UBUNTU_MIRROR/ubuntu/
packages:
  - postgresql
snap:
  commands:
    00: ['install', 'core']
    01: ['install', 'core18']
    # We could have done this here, but we'll do it later in 'runcmd' because
    # we want the database to be configured first.
    # 02: ['install', '--dangerous', '/root/$CRBS_SNAP_FILE']
    02: ['install', '--edge', 'candid']
locale: en_US.UTF-8
timezone: $(timedatectl | grep 'Time zone:' | awk '{print $3}')
runcmd:
  - ['sudo', '-u', 'postgres', 'createuser', 'crbs']
  # - ['sudo', '-u', 'postgres', 'psql', '-U', 'postgres', '-d', 'postgres', '-c', 'ALTER USER crbs WITH ENCRYPTED PASSWORD ''$CRBS_MD5_PASSWORD'';']
  - ['sudo', '-u', 'postgres', 'psql', '-U', 'postgres', '-d', 'postgres', '-c', 'ALTER USER crbs WITH PASSWORD ''$CRBS_DB_PASSWORD'';']
  - ['sudo', '-u', 'postgres', 'createdb', '-O', 'crbs', 'crbs']
  # This command will fail because it can't connect to the database.
  - ['bash', '-c', 'snap install --dangerous /root/$CRBS_SNAP_FILE > /dev/null 2>&1 || true']
  - snap set crbs db.url=postgresql://crbs:$CRBS_DB_PASSWORD@127.0.0.1/crbs
  - cp /var/snap/candid/common/admin.keys /root
  - /snap/bin/crbs.admin create-candid-agent /root/admin.keys --service-agent-file /root/crbs.agent
  - /snap/bin/crbs.admin config /root/crbs.agent
  # This doesn't work since it requires someone to open a URL in their browser.
  # - /snap/bin/crbs.admin create-admin
"
lxc config set $CONTAINER user.network-config "version: 2
ethernets:
  eth1:
    match:
      name: eth1
bridges:
  br0:
    interfaces: [eth1]
    addresses:
     - $CIDR
    gateway4: $GATEWAY
    nameservers:
      addresses: [$NAMESERVER]
"
lxc start $CONTAINER

echo "Waiting for container to finish starting up..."
while ! lxc exec $CONTAINER -- test -f /var/lib/cloud/data/result.json ; do
    sleep 0.5
done
lxc exec $CONTAINER cat /var/lib/cloud/data/result.json
