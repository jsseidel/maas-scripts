#!/bin/bash

function usage {
  echo "rundev.sh dev|run"
  echo "    Runs either the dev maas container (the one with code)"
  echo "    or the run with snaps"
}

CONT=
if [[ "$1" == "dev" ]] ; then
  set -x
  lxc stop maas-run
  set +x
  CONT=maas-dev
elif [[ "$1" == "run" ]] ; then
  set -x
  lxc stop maas-dev
  set +x
  CONT=maas-run
elif [[ "$1" == "stop" ]] ; then
  set -x
  lxc stop maas-dev
  lxc stop maas-run
  set +x
  exit 0
else
  usage
  exit 1
fi

sleep 5
set -x
lxc start $CONT
sleep 5
lxc exec $CONT bash
set +x
