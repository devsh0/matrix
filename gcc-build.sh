#!/bin/bash

build_dir="out";
sources=();

mkdir -p $build_dir;

for var in "$@"; do
	sources+=(${var%.*})	
done

# Compile all the sources.
for source in ${sources[@]}; do
	$(nasm -felf64 "$source.asm" -Werror -Wall)

	ret=$(echo $?)
	if [[ $ret -gt 0 ]]; then
	  exit $ret
	fi

	$(mv "$source.o" $build_dir)

	# Add -no-pie if the following error shows up:
	# relocation R_X86_64_32 against `.data' can not be used when making a PIE object; recompile with -fPIE nasm
	# What's PIE you ask? https://stackoverflow.com/q/2463150/14180973
	$(gcc -no-pie -m64 -o "$build_dir/$source" "$build_dir/$source.o")
done
