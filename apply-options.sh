#!/bin/bash

if [ $# -eq 0 -o \
     $# -eq 1 -a "$1" = "-h" -o \
     \( $# -ne 2 -a $# -ne 3 \) ]; then
	printf "This script applies a set of kernel options to an existing .config.\n"
	printf "Usage:\n"
	printf "  apply-options.sh [options] config_seed_path kernel_source_path\n"
	printf "Options:\n"
	printf "  --override\n"
	printf "    All the kernel seed options are concatenated to the end of the existing\n"
	printf "    .config file, overriding previously set options to the new kernel seed value\n"
	printf "    if one is set.\n"
	printf "Example:\n"
	printf "  # cd /usr/src/linux\n"
	printf "  # make mrproper defconfig\n"
	printf "  # apply-options.sh --override /usr/src/kernel-seeds/3.14.25 .\n"
	exit 1
fi

TMP=/tmp/kernel-seeds.$$
mkdir "$TMP"

OVERRIDE=false

while [ $# -gt 2 ]; do
	if [ "$1" = "--override" ]; then
		OVERRIDE=true
		shift
	fi
done

CONFIG_SEED_PATH="$1"
shift
KERNEL_SOURCE_PATH="$1"
shift

if [ ! -d "$CONFIG_SEED_PATH" ]; then
	printf "apply-options.sh: The config_seed_path at \"$CONFIG_SEED_PATH\" is not accessible\n"
	exit 1
fi
if [ ! -d "$KERNEL_SOURCE_PATH" ]; then
	printf "apply-options.sh: The kernel_source_path at \"$KERNEL_SOURCE_PATH\" is not accessible\n"
	exit 1
fi
if [ ! -f "$KERNEL_SOURCE_PATH/.config" ]; then
	echo "No .config file was found at \"$KERNEL_SOURCE_PATH\""
	echo "Generating a new .config file with \"make defconfig\""
	pushd "$KERNEL_SOURCE_PATH"
		make defconfig
	popd
fi

find "$CONFIG_SEED_PATH" -name options -print0 | xargs -0 cat >> "$TMP"/seed.config
touch "$TMP"/new.config
for OPTION in `cat "$TMP"/seed.config`; do
	# if the option is already set
	if grep "^"`echo "$OPTION" | sed -r 's/^(CONFIG.*?)=.*$/\1/'` "$KERNEL_SOURCE_PATH"/.config >/dev/null; then
		if $OVERRIDE; then
			echo "$OPTION"
			echo "$OPTION" >> "$TMP"/new.config
		fi
	else
		# the option is not set, so set it
		echo "$OPTION"
		echo "$OPTION" >> "$TMP"/new.config
	fi
done
cat "$TMP"/new.config >> "$KERNEL_SOURCE_PATH"/.config
pushd "$KERNEL_SOURCE_PATH"
	make olddefconfig
popd

rm -rf "$TMP"
