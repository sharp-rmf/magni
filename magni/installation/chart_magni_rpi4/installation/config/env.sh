#!/bin/sh
export ROS_HOSTNAME=$(hostname).local
export ROS_MASTER_URI=http://$ROS_HOSTNAME:11311

# Deleting this file will prevent magni from saving its pose
# This is to allow our restore_last_pose script to load the correct
# pose at reboot
# once the pose is restored, this file will be restored
rm $HOME/.unlock_magni_save_pose 
source $HOME/deployment_ws/devel/setup.bash
