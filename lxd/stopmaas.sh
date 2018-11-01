#!/bin/bash

# for when regiond or whichever maas process won't stop -- this is probably all overkill, but it works

(
cd ~/git/jsseidel-maas
ps -eaf | egrep "maas" | grep -v avahi | grep -v stopmaas | grep -v grep | awk '{print $2}' | while read PID ; do echo "kill $PID" ; sudo kill -9 $PID ; done
make stop
sleep 5
ps -eaf | egrep "maas" | grep -v avahi | grep -v stopmaas | grep -v grep | awk '{print $2}' | while read PID ; do echo "kill $PID" ; sudo kill -9 $PID ; done
make stop
sleep 5
sudo rm -f /run/lock/maas.dev.*
ps -eaf | egrep "maas" | grep -v avahi | grep -v stopmaas | grep -v grep
)
