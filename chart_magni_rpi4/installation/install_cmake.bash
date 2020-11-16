#!/bin/bash
set -e

sudo apt remove --purge --auto-remove cmake
version=3.18
build=1
mkdir ~/temp
cd ~/temp
wget https://cmake.org/files/v$version/cmake-$version.$build.tar.gz
tar -xzvf cmake-$version.$build.tar.gz
cd cmake-$version.$build/
./bootstrap
make -j1
sudo make install
rm -rf ~/temp
