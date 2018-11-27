#!/bin/bash

(
  cd $MAAS
  make lint && test.region src/maasserver/api/tests/test_annotations.py && test.region src/maasserver/api/tests/test_doc.py
)
