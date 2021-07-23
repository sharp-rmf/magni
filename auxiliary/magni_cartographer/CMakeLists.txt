cmake_minimum_required(VERSION 2.8.3)

project(magni_45_mapping)

find_package(catkin REQUIRED)

catkin_package()

install(DIRECTORY cartographer_configs DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION})

install(DIRECTORY launch DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION})
