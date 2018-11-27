#!/bin/bash

USER=admin
if [[ "$1" != "" ]] ; then
  USER=$1
fi

(
cd  $MAAS
set -x
bin/maas-region apikey --username=$USER > ~/${USER}_api.key
)
