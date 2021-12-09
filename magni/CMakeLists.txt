cmake_minimum_required(VERSION 2.8.3)
project(magni)

find_package(catkin REQUIRED)

catkin_package()

install(DIRECTORY launch maps test
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
)