#!/bin/bash
set -e

REPOSITORY_NAME=chart_magni_stack
REPOSITORY_BRANCH=master
ROS1_WORKSPACE_PATH=$HOME/deployment_ws
REPOSITORY_URL="git@github.com:sharp-rmf/$REPOSITORY_NAME.git"
INSTALLATION_SETUP_PATH=$ROS1_WORKSPACE_PATH/src/$REPOSITORY_NAME/chart_magni_nuc/installation

echo -e "Bootstrapper for $REPOSITORY_NAME\n\n"

#################################################### CHECK WORKSPACE #################################################
echo -e "Checking that workspace path is free.. \n"
if [ -d "$ROS1_WORKSPACE_PATH" ]
then
  echo "Directory already exists. Please remove this folder and back it up if necessary to prevent accidental loss of data."
  exit 1
fi


#################################################### TIMEZONE ########################################################
echo -e "Setting Timezone to Asia/Singapore"
timedatectl set-timezone Asia/Singapore

#################################################### INSTALL DEPENDENCIES #############################################
echo -e "Installing necessary dependencies for bootstrap.."
sudo apt install ssh-client git -y
sudo apt install python3-pip -y
echo -e "Done"

#################################################### CREATE WORKSPACE #################################################
echo -e "Creating workspace.. \n"
mkdir -p $ROS1_WORKSPACE_PATH/src

#################################################### CLONE REPOSITORY #################################################
cd $ROS1_WORKSPACE_PATH/src
git clone $REPOSITORY_URL
cd $ROS1_WORKSPACE_PATH/src/$REPOSITORY_NAME
git checkout $REPOSITORY_BRANCH

#################################################### START INSTALLATION  ############################################
cd $ROS1_WORKSPACE_PATH
chmod +x $INSTALLATION_SETUP_PATH/setup.bash
$INSTALLATION_SETUP_PATH/setup.bash $REPOSITORY_NAME $ROS1_WORKSPACE_PATH
