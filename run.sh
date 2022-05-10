#!/bin/bash

build_dir="out"

./gcc-build.sh $@ || { exit $?; }

# Run the script
bin="$1"
bin=${bin%.*}
"./$build_dir/$bin"
echo "Program returned $?"
