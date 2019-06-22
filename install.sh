#!/bin/bash

# env variables
. vars.sh

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
    dirmngr </dev/null
    pacman-key --populate archlinux
    pacman-key --refresh-keys
    pacstrap /mnt base base-devel dialog openssl-1.0 bash-completion git intel-ucode wpa_supplicant
    genfstab -pU /mnt >> /mnt/etc/fstab
}

# chroot
chrootall() {
    cp chroot.sh /mnt

    # chroot arch
    arch-chroot /mnt /bin/bash
    umount -R /mnt
    reboot
}

format
mountall
prepare
chrootall
