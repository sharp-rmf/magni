cmake_minimum_required(VERSION 2.8.3)
project(magni_45_uwb)

find_package(catkin REQUIRED)

catkin_package()

install(DIRECTORY launch nodes 
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
)
