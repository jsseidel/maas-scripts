#!/bin/bash

virsh net-define maas_network_libvirt.xml
virsh net-start maas
virsh net-autostart maas

