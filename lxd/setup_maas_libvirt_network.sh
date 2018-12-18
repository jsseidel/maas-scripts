#!/bin/bash

cat << EOF > maas.xml
<network>
  <name>maas</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <dns enable='no'/>
  <bridge name='virbr1' stp='off' delay='0'/>
  <domain name='testnet'/>
  <ip address='172.16.99.1' netmask='255.255.255.0'>
  </ip>
</network>
EOF
virsh net-define maas.xml
rm maas.xml
virsh net-start maas
virsh net-autostart maas
