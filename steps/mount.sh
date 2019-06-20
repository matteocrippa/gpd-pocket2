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


# mount
mountall() {
    mount /dev/mapper/${VG}-${ROOT} /mnt
    mkdir /mnt/boot
    mount ${DISK}p1 /mnt/boot
    pacstrap /mnt base base-devel dialog openssl-1.0 bash-completion git intel-ucode wpa_supplicant
    genfstab -pU /mnt >> /mnt/etc/fstab
}

mountall
