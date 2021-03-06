#!/bin/bash
source /etc/os-release

repo="deb-src http://archive.ubuntu.com/ubuntu/ $UBUNTU_CODENAME-security main restricted"
apt_src="/etc/apt/sources.list"

if [[ "$ID" == "ubuntu" ]]
then
    if ! grep -q '^deb-src .*'$UBUNTU_CODENAME'-security main restricted' $apt_src;
    then
        echo "[WARNING] This script is about to add '$repo' to $apt_src"
        read -p "Do you want to continue? (Yes/No) " cont
        case $cont in
            Yes|yes|Y|y ) 
                sudo bash -c "echo '$repo' >> $apt_src"
                echo "Continuing installation..."
                ;;
            * ) echo "Aborting..."
                exit -1
                ;;
        esac
    fi
  sudo apt-get update
  sudo apt-get build-dep -y qemu

  # panda-specific deps below, taken from panda/scripts/install_ubuntu.sh
  sudo apt-get -y install python-pip git protobuf-compiler protobuf-c-compiler \
       libprotobuf-c0-dev libprotoc-dev libelf-dev libc++-dev pkg-config
  sudo apt-get -y install software-properties-common
  sudo add-apt-repository -y ppa:phulin/panda
  sudo apt-get update
  sudo apt-get -y install libcapstone-dev libdwarf-dev python-pycparser \
  libwiretap-dev libwireshark-dev
else
    echo "[Warning] Attempting to run installation on a non-ubuntu system."
    echo "You may have to install dependencies manually"
fi

cd `dirname "$BASH_SOURCE"`/src/
git submodule update --init avatar-panda

cd avatar-panda
git submodule update --init dtc

mkdir -p ../../build/panda/panda
cd ../../build/panda/panda
../../../src/avatar-panda/configure --disable-sdl --target-list=arm-softmmu
make -j4

