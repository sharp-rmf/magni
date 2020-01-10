# magni_helpers
This package documents the steps necessary to get the magni working on DP1+++.

## Pending issues
- [ ] Slow boot time for certain topics ( like /battery_state )
- [ ] Soft Braking 
- [ ] SSH server seems to fail every alternate boot

## Required apt
```
sudo apt install picocom -y
sudo apt install python3-vcstool -y
```

## RPI4 image
- [x] Follow [this](https://forum.ubiquityrobotics.com/t/ros-image-on-raspberry-pi-4/326/30) thread. Need to update PYGPIO to above v69.
- [x] In order to get automatic connection to Wifi, need to go to network manager in GUI and toggle "all users can connect to network" (one of the checkboxes)

## Dual RPlidar
### udev
- [ ] The RPlidars need unique /dev identifiers. We should follow [this](https://askubuntu.com/questions/49910/how-to-distinguish-between-identical-usb-to-serial-adapters).
- [ ] Exclude "blocked area" data and append the data streams from the dual RPLidar set up.
- [ ] Test localization using the `rmf_dp2_maps`. 

## Mapping
- [ ] Get measurements of Ward 45.
- [ ] Mock up a reduced version of Ward 45 in CHART.
- [ ] Get a lidar mapping of Ward 45. Consider trying out the dual-lidar set up, and see if sufficient before trying out the raised Hokuyo. Use Cartographer ROS
- [ ] Tune ros1_navigation parameters for dual RPlidar.

## Decawave Localization
- [ ] udev rule to assign device name to decawave
- [ ] Write package that uses serial data from Decawave  
- [ ] Figure out how to transform the UWB frame of reference to the local frame. ( Try to make this tool general )
- [ ] Periodically update the robot pose using UWB ( theoretically more accurate )
- [ ] Criteria for triggering [rotate_recovery](http://wiki.ros.org/rotate_recovery) behaviour.
