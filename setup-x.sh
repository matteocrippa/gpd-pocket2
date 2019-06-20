#!/bin/bash

cleanup() {
    rm /chroot.sh
}

update_pacman() {
    echo "[multilib]" >> /etc/pacman.conf
    echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
    echo "" >> /etc/pacman.conf
    echo "[archlinuxfr]" >> /etc/pacman.conf
    echo "SigLevel = Never" >> /etc/pacman.conf
    echo "Server = http://repo.archlinux.fr/$arch" >> /etc/pacman.conf
    pacman -Sy
}

set_yay() {
    pacman -Sy yay
}

set_timezone() {
    tzselect
}

set_thermald() {
    yay -Sy thermald

    # Enable + start
    systemctl enable thermald.service
    systemctl start thermald.service
    systemctl enable thermald
}

set_network() {
    # Install
    yay -S networkmanager network-manager-applet nm-connection-editor

    # Enable + start
    systemctl enable NetworkManager
    systemctl start NetworkManager
}


set_sound() {
    # Install pulseaudio packages
    yay -S pulseaudio pulseaudio-alsa pulseaudio-bluetooth pulseaudio-ctl
}

set_bluetooth() {
    # Install
    yay -S bluez bluez-utils bluez-tools

    # Enable + start
    systemctl enable bluetooth
    systemctl start bluetooth

    # (optional) Install nice traybar utils
    yay -S blueman blueberry
}

set_tlp() {
    # Install
    yay -S tlp

    # Enable + start
    systemctl enable tlp
    systemctl start tlp
    systemctl enable tlp-slep.service
}

set_xorg() {
    yay -S xorg-server xorg-xev xorg-xinit xorg-xkill xorg-xmodmap xorg-xprop xorg-xrandr xorg-xrdb xorg-xset xinit-xsession

    cp xorg/20-intel.conf /etc/X11/xorg.conf.d/20-intel.conf
    cp xorg/30-display.conf /etc/X11/xorg.conf.d/30-display.conf
    cp xorg/99-touchscreen.conf /etc/X11/xorg.conf.d/99-touchscreen.conf

    yay -Sy xf86-video-intel
}

set_i3() {
    yay -Sy i3-gaps-next-git
    cp .xinitrc ~/.xinitrc
}


# exec script
update_pacman
set_yay
set_timezone
set_thermald
set_network
set_sound
set_bluetooth
set_tlp
set_xorg
set_i3
