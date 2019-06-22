# gpd-pocket2
Gpd Pocket 2 auto setup script for Archlinux

## Requirements

- Archlinux ISO on USB thumb


## How to install

- Boot GPD2 using the USB thumb
- run `wifi-menu` and setup your internet connection
- run `pacman -Sy git`
- run `git clone https://github.com/matteocrippa/gpd-pocket2 /tmp/gpd-pocket2`
- `cd /tmp/gdp-pocket2`
- edit `vars.sh` if you need/want to change any params
- `./install.sh`
- once the system enter in chroot run
- `./chroot.sh`

Once reboot, redo the first 3 step above, but this time run
- `su`
- `visudo`
- copy root line and add for your user to be a sudoer
- `exit`
- `./setup-x.sh`
- then feel free to remove the directory

## Troubleshooting

On reboot, if an error about mounting occurs, login as root, then:

- `lsbk -f` and note the UUID for the mmcblk0p1 partition
- `vi /etc/fstab` and replace the UUID with right one
- `reboot`


## Credits
Inspired by [GPD POCKET 2 ARCH GUIDE](https://github.com/joshskidmore/gpd-pocket-2-arch-guide)
