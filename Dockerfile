# Setup romio
FROM ros:melodic-ros-base

RUN apt update && apt install -y git python3-catkin-tools
RUN mkdir -p magni_ws/src && cd magni_ws/src && git clone https://github.com/sharp-rmf/magni.git
RUN cd magni_ws && catkin build