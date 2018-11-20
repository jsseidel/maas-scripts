#!/bin/bash

virsh net-define maas_network_libvirt_run.xml
virsh net-start maasrun
virsh net-autostart maasrun

virsh net-define maas_network_libvirt_dev.xml
virsh net-start maasdev
virsh net-autostart maasdev

