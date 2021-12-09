Description:
  Apply a set of kernel options to a new or existing kernel configuration.

Usage:
  kernelseeds [options]

Options:
  -a, --architecture x86
    Change ARCH when configuring the kernel.
    Possible architectures are defined at kernel-source/arch/*:
  --apply-seed-path path/to/options
    Apply the options at the provided path.
  --apply-system-raspberry-pi-2
    Apply changes to support the Raspberry Pi 2.
  --enable-all-menuconfig
    Enable all menu options which unhide additional options.
  --enable-all-modules
    Enable all non-overriding modules.
  -h, --help
    Display this help message and exit.
  --tmpfs
    Use tmpfs to improve performance of /tmp.

Example:
  # cd /usr/src/linux
  # make clean mrproper
  # gzip -c -d /proc/config.gz > .config
  # kernelseeds --enable-all-menuconfig --enable-all-modules
  # make && make modules_install

Example:
  # cd /usr/src/linux-arm
  # make clean mrproper
  # kernelseeds -a arm --enable-all-menuconfig --enable-all-modules
  # make && make modules_install

Version:
  Kernel Seeds 3.2.1.0
  Copyright (C) 2013 Nathan Shearer
  Licensed under GNU General Public License 2.0
