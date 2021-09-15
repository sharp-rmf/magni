#!/bin/bash

# Useful aliases to help with development
ROS_DISTRO="kinetic"
PROJECT_ROOT="$HOME/dev/magni_45_rplidar"

alias ros1_kinetic="source /opt/ros/kinetic/setup.bash"
alias dp2_env_ros1="source $HOME/catkin_ws/devel/setup.bash"
alias a='ros1_kinetic && dp2_env_ros1 && roslaunch magni_45_rplidar magni_45_single_lidar.launch&'
alias b='ros1_kinetic && dp2_env_ros1 && roslaunch magni_45_rplidar magni_45_free_fleet_client.launch&'
alias c='rostopic pub /level_name std_msgs/String "B1" -1'
alias c='ros1_kinetic && dp2_env_ros1 && roslaunch magni_45_rplidar magni_45_uwb.launch&'
alias x='pkill -f magni_45_single_lidar.launch && pkill -f magni_45_free_fleet_client.launch && pkill -f magni_45_uwb.launch'

alias syscheck_1='sudo systemctl status magni-base.service'
alias syscheck_2='rostopic echo /battery_state'
alias syscheck_3='rostopic echo /joy'


