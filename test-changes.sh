#!/bin/bash

(
  cd $MAAS/src/maasserver/api/examples
  ls *.json | while read f ; do
    cat $f | jq . > $$.json
    diff $f $$.json 1>/dev/null 2>&1
    if [[ $? != "0" ]] ; then
        echo "$f is not properly formatted."
        rm -f $$.json
        exit 1
    fi
    rm -f $$.json
  done # || exit 1

  cd $MAAS
  maas-region generate_api_doc > api.rst
  [[ $(grep PROBLEM api.rst) ]] && echo "Problems in api.rst. See $MAAS/api.rst." && exit 1
  make lint && test.region src/maasserver/api/tests/test_annotations.py && test.region src/maasserver/api/tests/test_doc.py

)
