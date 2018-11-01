#!/bin/bash

APICLI="/home/ubuntu/git/maas-scripts/maas_api_cli.py -a /home/ubuntu/admin_api.key -b http://10.55.32.42:5240/MAAS -r"

if [[ "$1" == "" || "$2" == "" ]] ; then
    echo "api_call_wrapper.sh <get|post|put|delete> </uri/?op=foo_op&arg1=foo>"
    exit
fi

$APICLI -m $1 -u $2
