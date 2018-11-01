#!/bin/bash

(
cd  $MAAS
set -x
bin/maas-region apikey --username=admin > ~/admin_api.key
)
