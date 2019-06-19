#!/bin/sh

# Simple hack to allow mouse scrolling when right click button is held down
xinput --set-prop pointer:"HAILUCK CO.,LTD USB KEYBOARD Mouse" "libinput Middle Emulation Enabled" 1
xinput --set-prop pointer:"HAILUCK CO.,LTD USB KEYBOARD Mouse" "libinput Button Scrolling Button" 3
xinput --set-prop pointer:"HAILUCK CO.,LTD USB KEYBOARD Mouse" "libinput Scroll Method Enabled" 0 0 1

exec i3 --shmlog-size 0
