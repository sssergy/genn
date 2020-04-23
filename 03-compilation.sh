#!/bin/bash

source config.sh
source ~/.bashrc

COIN_NAME_LOWER=${COIN_NAME,,}
COIN_NAME_UPPER=${COIN_NAME^^}


build(){
#build sources for linux
./autogen.sh
if [ $DEBIAN == "TRUE" ]
then
  if [ $GUI == "TRUE" ]
  then
    ./configure --disable-tests --disable-gui-tests --disable-bench LDFLAGS="-L${BDB_PREFIX}/lib/" CPPFLAGS="-I${BDB_PREFIX}/include/"
  else
    ./configure --without-gui --disable-tests --disable-gui-tests --disable-bench LDFLAGS="-L${BDB_PREFIX}/lib/" CPPFLAGS="-I${BDB_PREFIX}/include/"
  fi
else
  if [ $GUI == "TRUE" ]
  then
    ./configure --disable-tests --disable-gui-tests --disable-bench
  else
    ./configure --disable-tests --disable-gui-tests --disable-bench --without-gui
  fi
fi
export NUMCPUS=`grep -c '^processor' /proc/cpuinfo`
make


mkdir ../unixinstall
make install DESTDIR=`pwd`/../unixinstall
}


cd ${COIN_NAME_LOWER}
build
