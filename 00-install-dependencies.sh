#!/bin/bash
source config.sh


installdb_debian() {
  wget https://raw.githubusercontent.com/bitcoin/bitcoin/master/contrib/install_db4.sh
  chmod u+x install_db4.sh
  ./install_db4.sh `pwd`
  export BDB_PREFIX=`pwd`'/db4'
  echo "export BDB_PREFIX='${BDB_PREFIX}'" >> ~/.bashrc
  ldconfig
  # ./configure LDFLAGS="-L${BDB_PREFIX}/lib/" CPPFLAGS="-I${BDB_PREFIX}/include/"
}

installdb_ubuntu() {
  sudo apt-get -y install software-properties-common
  sudo add-apt-repository -y ppa:bitcoin/bitcoin
  sudo apt-get -y update
  sudo apt-get -y install libdb4.8-dev libdb4.8++-dev
  sudo ldconfig
}


install_dependencies() {
  apt-get -y install sudo
  sudo apt-get -y install automake pkg-config libevent-dev bsdmainutils
  sudo apt-get -y install git
  sudo apt-get -y install build-essential
  sudo apt-get -y install libtool autotools-dev autoconf
  sudo apt-get -y install libssl-dev
  sudo apt-get -y install libboost-all-dev
  sudo apt-get -y install pkg-config
  sudo apt-get -y install python3
  #download_code
  if [ $GUI == "TRUE" ]
  then
    sudo apt-get -y install libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler
    sudo apt-get -y install libqrencode-dev
  else
    echo " "
  fi
  if [ $DEBIAN == "TRUE" ]
  then
    mkdir ~/database
    cd ~/database/
    installdb_debian
  else
    installdb_ubuntu
  fi

}


install_dependencies
