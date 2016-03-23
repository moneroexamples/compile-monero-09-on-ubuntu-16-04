#!/bin/bash

# Monero 09 ubuntu compiler.
# Copyright (C) 2016  Monero Examples
# https://github.com/moneroexamples/

if [[ ! $(whoami) = "root" ]]; then
    echo "Please run the script as root."
    exit 1
fi


#######################################################

echo "Update Ubuntu's repositories ..."

sudo apt-get -y update

echo "Installing dependencies ..."
sudo apt-get -y install git build-essential cmake libboost-all-dev miniupnpc libunbound-dev graphviz doxygen



#######################################################

echo "Downloading latest Monero soruce code ..."

# download the latest bitmonero source code from github
git clone https://github.com/monero-project/bitmonero.git

# go into bitmonero folder
cd ./bitmonero/

echo "Compilation ..."

# compile
make


#######################################################

echo "Installation to  /opt/bitmonero/ ..."

# Install to /opt
sudo mkdir -p /opt/bitmonero
sudo mv -v ./build/release/bin/* /opt/bitmonero/

# Please report bugs at https://github.com/moneroexamples/
# End of the Script
