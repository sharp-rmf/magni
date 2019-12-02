# Magni RPLIDAR-A3 Navigation

This repo contains packages that configure the ROS 1 nav stack for Magni with a
RPLIDAR-A3.

If using anything other than the "stock" Magni Raspberry Pi 3 image, the
`udev` rules files in the `udev` directory should help things become more
consistent across reboots. Just copy them into `/etc/udev/rules.d`. You can
then run `sudo udevadm trigger` to avoid having to reboot immediately after
the copy. Future bootups will use the files by default.

The rule file in the `udev` directory is only necessary if you are running
on a NUC (or anything other than Raspberry Pi). It just tries to identify
a FTDI USB-Serial IC and symlink it to `/dev/magni`. It also looks for the
RPLIDAR usb-serial gadget and symlinks it to `/dev/rplidar`.

After loading the "stock" parameter file from Ubiquity Robotics, we then
overlay our own parameter to clobber the stock value with what is passed
in by our launch file, so that we can configure the Magni serial port in
our own site- and robot-specific launch files.
