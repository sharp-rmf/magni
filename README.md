# magni_helpers
This package documents the steps necessary to get the magni working on DP1+++.

## Pending issues
- [ ] Slow boot time for certain topics ( like /battery_state )

## RPI4 image
- [x] Follow [this](https://forum.ubiquityrobotics.com/t/ros-image-on-raspberry-pi-4/326/30) thread. Need to update PYGPIO to above v69.
- [x] In order to get automatic connection to Wifi, need to go to network manager in GUI and toggle "all users can connect to network" (one of the checkboxes)

## Dual RPlidar
### udev
- [ ] The RPlidars need unique /dev identifiers. We should follow [this](https://askubuntu.com/questions/49910/how-to-distinguish-between-identical-usb-to-serial-adapters).

