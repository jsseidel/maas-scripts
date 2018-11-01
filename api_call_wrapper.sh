#!/bin/bash

APICLI="/home/ubuntu/git/maas-scripts/maas_api_cli.py -a /home/ubuntu/admin_api.key -b http://10.55.32.42:5240/MAAS -r"

if [[ "$1" == "" || "$2" == "" ||  "$3" == "" ]] ; then
    echo "api_call_wrapper.sh <get|post|put|delete> </uri/?op=foo_op&arg1=foo> <key_to_use_in_example>"
    exit
fi

$APICLI -m $1 -u $2 | /home/ubuntu/git/maas-scripts/gen_example_json.py $3 | /home/ubuntu/git/maas-scripts/unformat_json.py
