Description:
  Apply a set of kernel options to a new or existing kernel configuration.

Usage:
  kernelseeds [options] config_seed_path kernel_source_path

Options:
  --override
    All the kernel seed options are concatenated to the end of the existing
    .config file, overriding previously set options to the new kernel seed value
    if one is set.
  -h
    Display this help message and exit.

Example:
  # cd /usr/src/linux
  # make mrproper defconfig
  # kernelseeds --override /usr/src/kernelseeds/4.10 .

Version:
  Kernel Seeds 1.0.0.0
  Copyright (C) 2013 Nathan Shearer
  Licensed under GNU General Public License 2.0
