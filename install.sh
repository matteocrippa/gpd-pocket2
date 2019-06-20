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


# wipe
wipe() {
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | gdisk $DISK
  x # expert mode
  z # wipe disk
  y # confirm
  y # confirm
EOF
}


while true; do
    read -p 'do you want to wipe the disk "y" or "n": ' yn

    case $yn in

        [Yy]* ) wipe; break;;

        [Nn]* ) break;;

        * ) echo 'Please answer yes or no: ';;

    esac
done

# partition
partition() {
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | gdisk $DISK
  o # clear the in memory partition table
  y # confirm cleanup
  n # new partition
  1 # partition number 1
    # default - start at beginning of disk
  +256MB # 256 MB boot parttion
  EF00
  n # new partition
  2 # partion number 2
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
  8E00 # make a partition bootable
  w # write the partition table
  y # confirm
EOF
}


while true; do
    read -p 'do you want to partition the disk "y" or "n":  ' cc

    case $cc in

        [Yy]* ) partition; break;;

        [Nn]* ) break;;

        * ) echo 'Please answer yes or no: ';;

    esac
done

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

# wifi setup
wifi() {
    wifi-menu
}

# mount
mountall() {
    mount /dev/mapper/${VG}-${ROOT} /mnt
    mkdir /mnt/boot
    mount ${DISK}p1 /mnt/boot
}

# pacstrap
prepare() {
    timedatectl set-ntp true
    pacstrap /mnt base base-devel dialog openssl-1.0 bash-completion git intel-ucode wpa_supplicant
    genfstab -pU /mnt >> /mnt/etc/fstab
}

# chroot
chroot() {
    # chroot arch
    arch-chroot /mnt /bin/bash

    # set hostname
    echo ${HOSTNAME} > /mnt/etc/hostname

    # fix font size
    echo "FONT=latarcyrheb-sun32" > /etc/vconsole.conf

    # update modules
    sed -i "/HOOKS/c $HOOKS" /etc/mkinitcpio.conf
    mkinitcpio -P

    # install boot
    bootctl install

    # prepare boot loader
    touch ${BOOT_CFG}
    echo "title Arch Linux" > ${BOOT_CFG}
    echo "linux /vmlinuz-linux" >> ${BOOT_CFG}
    echo "initrd /intel-ucode.img" >> ${BOOT_CFG}
    echo "initrd /initramfs.img" >> ${BOOT_CFG}
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

    # final touches
    exit
    umount -R /mnt
    reboot
}

format
mountall
prepare
#chroot
