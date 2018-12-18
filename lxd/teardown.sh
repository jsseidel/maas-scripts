#!/bin/bash

lxc stop maas-run
lxc delete maas-run
lxc network delete maas-run-br0

virsh net-undefine maas
virsh net-destroy maas

