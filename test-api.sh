#!/bin/bash

(
    cd $MAAS
    maas-region generate_api_doc > api.rst
)

mkdir -p api_tmp
(
    cd api_tmp
    cat $MAAS/api.rst | pandoc -f rst -t markdown > api.md
    cat << EOF > metadata.yaml
navigation:

    - title: API
      children:
      - title: API
        location: api.md
EOF
    documentation-builder
    sudo cp build/api.html /var/www/html/. && echo "copied to /var/www/html/api.html"
)

rm -rf api_tmp
