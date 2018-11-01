#!/usr/bin/env python3

import sys
import json

def gen_example_json(argv):
    maas_json = json.dumps(json.load(sys.stdin))
    ex = '{"cmdkey":"%s","example":%s}' % (argv[0], maas_json)
    print(ex)

if __name__ == "__main__":
    gen_example_json(sys.argv[1:])

