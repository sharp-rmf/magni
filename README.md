# magni_45
This package documents the steps necessary to get the magni working on DP1+++.

# Notes
Follow the following steps for maximum non-breaking
- Turn on the Magni
- SSH Login. If SSH fails, you need to connect a monitor. Very possibly, the PI has hardware issues: Swap with a new PI and see if this solves the problem ( unverified )
- Wait for /battery_state to appear on `rostopic`. This could take a while. Important! Otherwise, this could mess up the initial amcl map to base_link transform. (unverified )
- `roslaunch magni_45_rplidar magni_45.launch`. alias: a

# TODO:
## RPI4 image
- [x] Follow [this](https://forum.ubiquityrobotics.com/t/ros-image-on-raspberry-pi-4/326/30) thread. Need to update PYGPIO to above v69.
- [x] In order to get automatic connection to Wifi, need to go to network manager in GUI and toggle "all users can connect to network" (one of the checkboxes)
- [x] Issue with slow ssh login . Fixed by swapping to new Pi. 

## Dual RPlidar
### udev
- [x] The RPlidars need unique /dev identifiers. We should follow [this](https://askubuntu.com/questions/49910/how-to-distinguish-between-identical-usb-to-serial-adapters).
- [x] Supply power to the RPlidars using external power source. This is necessary as the rpi4 does not seem to be able to supply the necessary power on its own
- [ ] Currently power is supplied by NUC. As a low priority task we can power the rplidar from the motor controller, thus removing the NUC 
- [ ] Exclude "blocked area" data and append the data streams from the dual RPLidar set up. This might be unecessary, depends on the current performance
- [x] Test localization using the `rmf_dp2_maps`. 

## Mapping
- [ ] Get measurements of Ward 45.
- [ ] Mock up a reduced version of Ward 45 in CHART.
- [ ] Get a lidar mapping of Ward 45. Consider trying out the dual-lidar set up, and see if sufficient before trying out the raised Hokuyo. Use Cartographer ROS
- [ ] Tune ros1_navigation parameters for dual RPlidar.

## Decawave Localization
- [x] [udev rule to assign device name to decawave](https://github.com/cnboonhan94/magni_45/blob/master/ros1/udev/decawave.rules)
- [ ] Write package that uses serial data from Decawave  
- [ ] Figure out how to transform the UWB frame of reference to the local frame. ( Try to make this tool general )
- [ ] Periodically update the robot pose using UWB ( theoretically more accurate )
- [ ] Criteria for triggering [rotate_recovery](http://wiki.ros.org/rotate_recovery) behaviour.
