#!/bin/bash

# Useful aliases to help with development
ROS_DISTRO="kinetic"
PROJECT_ROOT="$HOME/dev/magni_45"

alias ros1="source /opt/ros/$ROS_DISTRO/setup.bash && source $HOME/dev/magni_45/ros1/devel/setup.bash"
alias b1="cd $HOME/dev/magni_45/ros1 && catkin build"

