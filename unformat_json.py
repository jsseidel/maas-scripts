#!/usr/bin/env python3

import sys
import json


if __name__ == "__main__":
    json.dump(json.load(sys.stdin), sys.stdout)
    print("\n")

