# Setup romio
# Reference: https://answers.ros.org/question/312577/catkin_make-command-not-found-executing-by-a-dockerfile/

FROM ros:melodic

# install build tools
RUN apt-get update && apt-get install -y \
      python-catkin-tools \
    && rm -rf /var/lib/apt/lists/*

# clone ros package repo
ENV ROS_WS /opt/ros_ws
RUN mkdir -p $ROS_WS/src
WORKDIR $ROS_WS
RUN git -C src clone \
      https://github.com/sharp-rmf/magni.git

# install ros package dependencies
RUN apt-get update && \
    rosdep update && \
    rosdep install -y \
      --from-paths \
        src \
      --ignore-src && \
    rm -rf /var/lib/apt/lists/*

# build ros package source
RUN catkin config \
      --extend /opt/ros/$ROS_DISTRO && \
    catkin build

# source ros package from entrypoint
RUN sed --in-place --expression \
      '$isource "$ROS_WS/devel/setup.bash"' \
      /ros_entrypoint.sh

# run ros package launch file
# CMD ["roslaunch", "roscpp_tutorials", "talker_listener.launch"]