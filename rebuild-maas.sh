#!/bin/bash

(
    cd $MAAS
    make clean+db && make && make syncdb && make sampledata
)


