#!/sytem/bin/sh
chmod 666 /dev/snd/pcm*
supolicy --live "allow untrusted_app audio_device chr_file {open read write ioctl}"
supolicy --live "allow untrusted_app audio_device dir {search open read}"
