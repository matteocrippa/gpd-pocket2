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


# format
format() {
    # format efi
    mkfs.vfat ${DISK}p1

    # format disk
    cryptsetup luksFormat -v -s 512 -h sha512 ${DISK}p2
    cryptsetup luksOpen ${DISK}p2 luks
    pvcreate ${DISK}p2 ${LUKS}
    vgcreate ${VG} ${LUKS}
    lvcreate -L${SWAP_SIZE} ${VG} -n ${SWAP}
    lvcreate -l 100%FREE ${VG} -n ${ROOT}
    mkfs.ext4 /dev/mapper/${VG}-${ROOT}
    mkswap /dev/mapper/${VG}-${SWAP}
}

format
