#!/bin/bash

maas admin machines read | jq '.[] | .hostname, .system_id'
