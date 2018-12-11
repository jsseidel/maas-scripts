#!/bin/bash

function usage {
    echo "rename-docs-page.sh <old-file-name.md> <new-file-name.md>"
    echo "must be run in the directory where old-file-name.md exists"
}

if [[ ! -r $1 ]] ; then
    usage
    exit 1
fi

BP=$(basename $1)
if [[ "$BP" != "$1" ]] ; then
    echo "$BP != $1"
    usage
    exit 2
fi

BP=$(basename $2)
if [[ "$BP" != "$2" ]] ; then
    echo "$BP != $2"
    usage
    exit 2
fi

echo "moving $1 -> $2"
mv $1 $2

echo "finding references to $1 in files and updating with new name"
grep $1 *.md | awk -F':' '{print $1}' | sort -u | while read f ; do
    set -x
    perl -i -p -e "s/$1/$2/g" $f
    set +x
done
