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

# chroot
chrootall() {

    # set hostname
    echo ${HOSTNAME} > /mnt/etc/hostname

    # fix font size
    echo "FONT=latarcyrheb-sun32" > /etc/vconsole.conf

    # update modules
    sed -i "s/HOOKS/\#HOOKS/g" /etc/mkinitcpio.conf
    echo $HOOKS >> /etc/mkinitcpio.conf
    mkinitcpio -P

    # install boot
    bootctl install

    # prepare boot loader
    touch ${BOOT_CFG}
    echo "title Arch Linux" > ${BOOT_CFG}
    echo "linux /vmlinuz-linux" >> ${BOOT_CFG}
    echo "initrd /intel-ucode.img" >> ${BOOT_CFG}
    echo "initrd /initramfs-linux.img" >> ${BOOT_CFG}
    export PART_ID=$(blkid -o value -s UUID ${DISK}p2)
    echo "options rd.luks.name=${PART_ID}=luks root=/dev/mapper/${VG}-${ROOT} rw fbcon=rotate:1" >> ${BOOT_CFG}

    # create boot loader
    export LOADER=/boot/loader/loader.conf
    touch ${LOADER}
    echo "default arch" > ${LOADER}
    echo "auto-firmware no" >> ${LOADER}
    echo "timeout 3" >> ${LOADER}
    echo "console-mode 2" >> ${LOADER}

    # set timezone
    ln -sf /usr/share/zoneinfo${TIMEZONE} /etc/localtime

    # set locale
    export LOC=/etc/locale.conf
    touch ${LOC}
    echo "LANG=en_US.UTF-8" > ${LOC}
    echo "LANGUAGE=en_US" >> ${LOC}
    echo "LC_ALL=C" >> ${LOC}

    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
    locale-gen

    # set root password
    passwd

    # set user
    useradd -m -g users -G wheel,storage,power -s /bin/bash ${USER}
    passwd ${USER}
    
    echo "Set Visudo"
    visudo

    # final touches
    exit
}

chrootall
