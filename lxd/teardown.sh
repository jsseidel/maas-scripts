#!/bin/bash

virsh net-undefine maasrun
virsh net-destroy maasrun

virsh net-undefine maasdev
virsh net-destroy maasdev

lxc stop maas-run
lxc stop maas-dev

lxc delete maas-run
lxc delete maas-dev
