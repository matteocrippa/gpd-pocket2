#!/bin/bash

# env variables
# feel free to edit according your needs

export DISK=/dev/mmcblk0
export LUKS=/dev/mapper/luks
export SWAP_SIZE=6G
export SWAP=swap
export ROOT=root
export VG=rootvg
export HOSTNAME=moon
export TIMEZONE=/Europe/Rome
export USER=matteo
export BOOT_CFG=/boot/loader/entries/arch.conf
export HOOKS="HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt sd-lvm2 fsck filesystems)"
