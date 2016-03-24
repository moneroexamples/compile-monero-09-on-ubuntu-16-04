#!/bin/bash
#
# Monero 09 ubuntu compiler.
# 
# https://github.com/moneroexamples/

if [[ ! $(whoami) = "root" ]]; then
    echo "Please run the script as root."
    exit 1
fi


#######################################################

echo "Update Ubuntu's repositories ..."

apt-get -y update

echo "Installing dependencies ..."
apt-get -y install git build-essential cmake libboost-all-dev miniupnpc libunbound-dev graphviz doxygen



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

echo "Installation to /opt/bitmonero/ ..."

# delete /opt/bitmonero

rm -rvf /opt/bitmonero

# Install to /opt
mkdir -p /opt/bitmonero
mv -v ./build/release/bin/* /opt/bitmonero/



#######################################################

echo "Installation headers and librariers to /opt/bitmonero-dev/ ..."

# delete /opt/bitmonero-dev

rm -rvf /opt/bitmonero-dev

# create the folder
mkdir -p /opt/bitmonero-dev/libs

# find the static libraries files (i.e., those with extension of *.a)
# and copy them to /opt/bitmonero-dev/libs
# assuming you are still in bitmonero/ folder which you downloaded from
# github
find ./build/ -name '*.a' -exec cp -v {} /opt/bitmonero-dev/libs  \;


# create the folder
mkdir -p /opt/bitmonero-dev/headers

# find the header files (i.e., those with extension of *.h)
# and copy them to /opt/bitmonero-dev/headers.
# but this time the structure of directories is important
# so rsync is used to find and copy the headers files
rsync -zarv --include="*/" --include="*.h" --exclude="*" --prune-empty-dirs ./ /opt/bitmonero-dev/headers

# Please report bugs at https://github.com/moneroexamples/
# End of the Script
