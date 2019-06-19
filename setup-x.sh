#!/bin/bash

wifi() {
    wifi-menu
}

pacman() {
    echo "[multilib]" >> /etc/pacman.conf
    echo "Include = /etc/pacman.d/mirrorlists" >> /etc/pacman.conf
    echo "[archlinuxfr]" >> /etc/pacman.conf
    echo "SigLevel = Never" >> /etc/pacman.conf
    echo "Server = http://repo.archlinux.fr/$arch" >> /etc/pamac.conf
    sudo pacman -Sy
}

yay() {
    pacman -Sy yay
}

timezone() {
    sudo tzselect
}

thermald() {
    yay -Sy thermald

    # Enable + start
    sudo systemctl enable thermald.service
    sudo systemctl start thermald.service
    sudo systemctl enable thermald
}

network() {
    # Install
    yay -S networkmanager network-manager-applet nm-connection-editor

    # Enable + start
    sudo systemctl enable NetworkManager
    sudo systemctl start NetworkManager
}


sound() {
    # Install pulseaudio packages
    yay -S pulseaudio pulseaudio-alsa pulseaudio-bluetooth pulseaudio-ctl
}

bluetooth() {
    # Install
    yay -S bluez bluez-utils bluez-tools

    # Enable + start
    sudo systemctl enable bluetooth
    sudo systemctl start bluetooth

    # (optional) Install nice traybar utils
    yay -S blueman blueberry
}

tlp() {
    # Install
    yay -S tlp

    # Enable + start
    sudo systemctl enable tlp
    sudo systemctl start tlp
    sudo systemctl enable tlp-slep.service
}

xorg() {
    yay -S xorg-server xorg-xev xorg-xinit xorg-xkill xorg-xmodmap xorg-xprop xorg-xrandr xorg-xrdb xorg-xset xinit-xsession

    sudo cp xorg/20-intel.conf /etc/X11/xorg.conf.d/20-intel.conf
    sudo cp xorg/30-display.conf /etc/X11/xorg.conf.d/30-display.conf
    sudo cp xorg/99-touchscreen.conf /etc/X11/xorg.conf.d/99-touchscreen.conf

    yay -Sy xf86-video-intel
}

i3() {
    yay -Sy i3-gaps
    sudo cp .xinitrc ~/.xinitrc
}


# exec script
wifi
pacman
yay
timezone
thermald
network
sound
bluetooth
tlp
xorg
i3
