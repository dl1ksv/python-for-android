#!/sytem/bin/sh
chmod 666 /dev/bus/usb/002/*
supolicy --live "allow:untrusted_app usb_device dir {open read}"
supolicy --live "allow:untrusted_app usb_device chr_file {open read}"
