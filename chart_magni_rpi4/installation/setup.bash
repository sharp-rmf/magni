#!/bin/bash
set -e
if [ $1 == '-h' ]
then
  echo "Usage: setup.bash [REPOSITORY_NAME] [ROS1_WORKSPACE_PATH]"
  exit 1
fi

if [ -z $1 ]
then
    echo "Enter the REPOSITORY Name."
    exit 1
fi

if [ -z $2 ]
then
    echo "Enter the ROS1 Workspace Path to install this product in."
    exit 1
fi

REPOSITORY_NAME=$1
ROS1_WORKSPACE_PATH=$2

export MAKEFLAGS=j1 # Limit the number of cores used when building code from source, MAKEFLAGS='-j$(nproc)' to use all cores ( might run of RAM especially on Pi4s )
ROS1_PATH=/opt/ros/kinetic
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" # Current workspace
MAINTAINER_EMAIL="contact_me@gmail.com"
export DEBIAN_FRONTEND="noninteractive"  # Prevent debconf interactive menus
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections

echo -e "\n\nBeginning Full Installation of $REPOSITORY_NAME.\n\n"

#################################################### CHECK NECESSARY FILES ##########################################
echo -e "Verifying that all necessary files are found."

if [ ! -f "$SCRIPT_DIR/required-files" ]; then
  echo "required-files is missing. Please contact $MAINTAINER_EMAIL."
  exit 1
fi

input="$SCRIPT_DIR/required-files"

while IFS= read -r line
do
  if [ ! -f "$SCRIPT_DIR/$line" ]; then
    echo "$line file is missing. Please contact $MAINTAINER_EMAIL."
    exit 1
  fi
done < "$input"

echo -e "All dependency config files are found. \n"

#################################################### MAKE EXECUTABLE ##########################################
echo -e "Making all required files executable."

input="$SCRIPT_DIR/required-files"

while IFS= read -r line
do
    sudo chmod +x $SCRIPT_DIR/$line 
done < "$input"

echo -e "Done.\n"



######################################### INSTALLING BIN SOURCES #####################################################
echo -e "Updating apt sources.."
$SCRIPT_DIR/install-rmf-sources.bash
echo -e "Sources installed. \n"

######################################### INSTALL CMAKE   ############################################
echo -e "Install compatible version of CMAKE"
$SCRIPT_DIR/install_cmake.bash

######################################### INSTALLING APT DEPENDENCIES  ##############################################
echo -e "Installing apt dependencies.."

input="$SCRIPT_DIR/apt-dependencies"
while IFS= read -r line
do
    sudo apt install $line -y
done < "$input"

echo -e "apt dependencies installed.\n"

######################################### INSTALLING PIP3 DEPENDENCIES  #############################################
echo -e "Installing pip3 dependencies"

input="$SCRIPT_DIR/pip3-dependencies"
while IFS= read -r line
do
  pip3 install $line
done < "$input"

echo -e "pip3 dependencies installed.\n"

######################################### INSTALLING ROS1 DEPENDENCIES  ############################################
echo -e "Installing ROS1 dependencies"
cd $ROS1_WORKSPACE_PATH
source $ROS1_PATH/setup.bash

echo -e "Downloading ROS1 source packages"
vcs import src < $SCRIPT_DIR/ros1-source-dependencies

echo -e "Updating Rosdep.."
sudo rm /etc/ros/rosdep/sources.list.d/*
sudo rosdep init
rosdep update
echo -e "Downloading ROS1 binaries"
rosdep install --from-paths src --ignore-src -yr || true

echo -e "ROS1 dependencies installed.\n"

######################################### PATCH RPLIDAR DRIVER  ############################################
echo -e "Patching RPlidar Drivers"
cd $ROS1_WORKSPACE_PATH/src
$SCRIPT_DIR/patch_rplidar_driver.sh

######################################### BUILD ROS1 PACKAGES  ###################################################
echo -e "Building ROS1 Packages"

cd $ROS1_WORKSPACE_PATH
source $ROS1_PATH/setup.bash
#catkin build -j 1 -p 1 --mem-limit 50% --cmake-args -DBUILD_IDLC=NO  # For low ram devices
catkin build --cmake-args -DBUILD_IDLC=NO  

echo -e "$REPOSITORY_NAME Workspace built.\n"

#########################################  ONLY CONTINUE IF NOT IN DOCKER   ############################################
if [[ $IN_DOCKER ]]; then echo 'Currently in Docker, not proceding to configuration installs.'; exit 0; fi

######################################### INSTALLING CONFIGURATION FILES  ############################################
echo -e "Installing configuration files"

echo -e "Disabling pifi"
sudo systemctl disable pifi.service
sudo systemctl stop pifi.service

echo -e "Deploying bashrc"
cp $SCRIPT_DIR/config/.bashrc $HOME

echo -e "Deploying dnsmasq configuration"
sudo cp $SCRIPT_DIR/config/dnsmasq.conf /etc
echo -e "Disabling systemd-resolved"
sudo systemctl disable systemd-resolved.service
sudo systemctl stop systemd-resolved.service
sudo systemctl mask systemd-resolved.service
sudo systemctl unmask dnsmasq.service 
sudo systemctl enable dnsmasq.service 
sudo systemctl start dnsmasq.service

echo -e "Deploying hostapd configuration"
sudo cp $SCRIPT_DIR/config/hostapd.conf /etc/hostapd
sudo cp $SCRIPT_DIR/config/hostapd /etc/default/hostapd
sudo systemctl unmask hostapd.service
sudo systemctl start hostapd.service

echo -e "Deploying udev rules"
sudo cp $SCRIPT_DIR/config/rplidar_back.rules /etc/udev/rules.d
sudo cp $SCRIPT_DIR/config/rplidar_front.rules /etc/udev/rules.d

service_name=start-ros1-node
echo -e "deploying $service_name"
sudo cp $script_dir/config/$service_name.service /etc/systemd/system
sudo systemctl unmask $service_name.service && sudo systemctl daemon-reload && sudo systemctl enable $service_name.service && sudo systemctl restart $service_name.service

service_name=start-magni-free-fleet-client
echo -e "deploying $service_name"
sudo cp $script_dir/config/$service_name.service /etc/systemd/system
sudo systemctl unmask $service_name.service && sudo systemctl daemon-reload && sudo systemctl enable $service_name.service && sudo systemctl restart $service_name.service

SERVICE_NAME=rfkill-unblock-wifi
echo -e "Deploying $SERVICE_NAME"
sudo cp $SCRIPT_DIR/config/$SERVICE_NAME.service /etc/systemd/system
sudo systemctl unmask $SERVICE_NAME.service && sudo systemctl daemon-reload && sudo systemctl enable $SERVICE_NAME.service && sudo systemctl restart $SERVICE_NAME.service

echo -e "Deploying startup script"
cp $SCRIPT_DIR/start_device.bash $HOME
cp $SCRIPT_DIR/start_free_fleet.bash $HOME

echo -e "Deploying host files"
sudo cp $SCRIPT_DIR/config/hostname /etc
sudo cp $SCRIPT_DIR/config/hosts /etc

echo -e "Deploying fix to get ssh up without timesync"
sudo cp $SCRIPT_DIR/config/networking.service /etc/systemd/system/network-online.target.wants/

echo -e "Deployment env configuration env.sh"
sudo cp $SCRIPT_DIR/config/env.sh /etc/ubiquity

echo -e "Deployment interfaces file"
sudo cp $SCRIPT_DIR/config/interfaces /etc/network

echo -e "Deployment interfaces file"
sudo cp $SCRIPT_DIR/config/cyclonedds $HOME

echo -e "Configurations have been successfully deployed.\n"

######################################### CLEAN UP  ############################################
echo -e "Doing post setup tests."
$SCRIPT_DIR/post-setup-tests.bash
echo -e "Installation Complete.\n"

