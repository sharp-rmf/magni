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
ROS1_PATH=/opt/ros/noetic
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

#################################################### SET UP VNC SERVER ##########################################
echo -e "Set up VNC Server on Boot."

$SCRIPT_DIR/vnc-gnome-install

echo -e "Done.\n"

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


#########################################  ONLY CONTINUE IF NOT IN DOCKER   ############################################
if [[ $IN_DOCKER ]]; then echo 'Currently in Docker, not proceding to configuration installs.'; exit 0; fi

######################################### INSTALLING CONFIGURATION FILES  ############################################
echo -e "Installing configuration files"

echo -e "Disabling NetworkManager.. ( sorry )"
sudo systemctl stop network-manager.service
sudo systemctl disable network-manager.service
sudo systemctl mask network-manager.service
sudo systemctl daemon-reload

echo -e "Deploying Netplan"
sudo rm /etc/netplan/*
sudo cp $SCRIPT_DIR/config/01-netplan-config.yaml /etc/netplan
sudo netplan generate --debug
sudo netplan apply

echo -e "Deploying bashrc"
cp $SCRIPT_DIR/config/.bashrc $HOME

SERVICE_NAME=rfkill-unblock-wifi
echo -e "Deploying $SERVICE_NAME"
sudo cp $SCRIPT_DIR/config/$SERVICE_NAME.service /etc/systemd/system
sudo systemctl unmask $SERVICE_NAME.service && sudo systemctl daemon-reload && sudo systemctl enable $SERVICE_NAME.service && sudo systemctl restart $SERVICE_NAME.service

echo -e "Deploying host files"
sudo cp $SCRIPT_DIR/config/hostname /etc
sudo cp $SCRIPT_DIR/config/hosts /etc

echo -e "Deploying Rviz config"
cp $SCRIPT_DIR/config/chart.rviz $HOME/chart.rviz

echo -e "Configurations have been successfully deployed.\n"

