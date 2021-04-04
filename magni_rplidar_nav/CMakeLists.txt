cmake_minimum_required(VERSION 2.8.3)
project(magni_rplidar_nav)

find_package(catkin REQUIRED)

catkin_package()

install(PROGRAMS
  scripts/cancel_navigation_action
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

## Mark other files for installation (e.g. launch and bag files, etc.)
# install(FILES
#   # myfile1
#   # myfile2
#   DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
# )
