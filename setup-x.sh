#!/bin/bash

cleanup() {
    rm /chroot.sh
}

update_pacman() {
    echo "[multilib]" | sudo tee -a /etc/pacman.conf
    echo "Include = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
    echo "" | sudo tee -a /etc/pacman.conf
    echo "[archlinuxfr]" | sudo tee -a /etc/pacman.conf
    echo "SigLevel = Never" | sudo tee -a /etc/pacman.conf
    echo "Server = http://repo.archlinux.fr/\$arch" | sudo tee -a /etc/pacman.conf
    pacman -Suy
}

set_yay() {
    # Build yay package and install
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si

    # After install, remove the yay build folder
    cd ..; rm -rf yay

    # Sync yay
    yay -Sy
}

set_timezone() {
    sudo tzselect
}

set_thermald() {
    yay -Sy thermald

    # Enable + start
    sudo systemctl enable thermald.service
    sudo systemctl start thermald.service
    sudo systemctl enable thermald
}

set_network() {
    # Install
    yay -S networkmanager network-manager-applet nm-connection-editor

    # Enable + start
    sudo systemctl enable NetworkManager
    sudo systemctl start NetworkManager
}


set_sound() {
    # Install pulseaudio packages
    yay -S pulseaudio pulseaudio-alsa pulseaudio-bluetooth pulseaudio-ctl
}

set_bluetooth() {
    # Install
    yay -S bluez bluez-utils bluez-tools

    # Enable + start
    sudo systemctl enable bluetooth
    sudo systemctl start bluetooth

    # (optional) Install nice traybar utils
    yay -S blueman blueberry
}

set_tlp() {
    # Install
    yay -S tlp

    # Enable + start
    sudo systemctl enable tlp
    sudo systemctl start tlp
    sudo systemctl enable tlp-sleep.service
}

set_xorg() {
    yay -S xorg-server xorg-xev xorg-xinit xorg-xkill xorg-xmodmap xorg-xprop xorg-xrandr xorg-xrdb xorg-xset xinit-xsession

    sudo cp xorg/20-intel.conf /etc/X11/xorg.conf.d/20-intel.conf
    sudo cp xorg/30-display.conf /etc/X11/xorg.conf.d/30-display.conf
    sudo cp xorg/99-touchscreen.conf /etc/X11/xorg.conf.d/99-touchscreen.conf

    yay -Sy xf86-video-intel
}

set_i3() {
    yay -Sy i3-gaps-next-git i3lock
    sudo cp .xinitrc ~/.xinitrc
}

set_terminal() {
    yay -Sy alacritty
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
set_terminal
