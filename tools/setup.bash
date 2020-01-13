#!/bin/bash

# Useful aliases to help with development
ROS_DISTRO="kinetic"
PROJECT_ROOT="$HOME/dev/magni_45"

alias ros1="source /opt/ros/$ROS_DISTRO/setup.bash && source $HOME/dev/magni_45/ros1/devel/setup.bash"
alias b1="cd $HOME/dev/magni_45/ros1 && catkin build"
alias a="ros1 && roslaunch magni_45_rplidar dual_rplidar.launch"

m3(){
    # For use on external device visualizing the data from the magni
    export ROS_IP=10.233.29.77
    gnome-terminal -- bash -c "echo 'Launching Magni'; ssh magni3; exec bash"
    export ROS_MASTER_URI=http://magni3.local:11311
    rviz &
}
