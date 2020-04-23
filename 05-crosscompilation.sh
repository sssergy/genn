#!/bin/bash

source config.sh


COIN_NAME_LOWER=${COIN_NAME,,}
COIN_NAME_UPPER=${COIN_NAME^^}



rm -rf win32install
rm -rf win64install
mkdir win32install
mkdir win64install
sudo apt-get -y install build-essential libtool autotools-dev automake pkg-config bsdmainutils curl git
sudo apt-get -y install g++-mingw-w64-x86-64
sudo apt-get -y install g++-mingw-w64-i686 mingw-w64-i686-dev
sudo chmod -R a+rw .

rm -rf ${COIN_NAME_LOWER}win32
rm -rf ${COIN_NAME_LOWER}win64

cp -r ${COIN_NAME_LOWER} ${COIN_NAME_LOWER}win32
cp -r ${COIN_NAME_LOWER} ${COIN_NAME_LOWER}win64

cd ${COIN_NAME_LOWER}win64
PATH=$(echo "$PATH" | sed -e 's/:\/mnt.*//g') # strip out problematic Windows %PATH% imported var
cd depends
make HOST=x86_64-w64-mingw32
cd ..
./autogen.sh # not required when building from tarball
CONFIG_SITE=$PWD/depends/x86_64-w64-mingw32/share/config.site ./configure --disable-tests --disable-gui-tests --disable-bench --prefix=/
make clean
make
make install DESTDIR=`pwd`/../win64install

cd ../${COIN_NAME_LOWER}win32
PATH=$(echo "$PATH" | sed -e 's/:\/mnt.*//g') # strip out problematic Windows %PATH% imported var
cd depends
make HOST=i686-w64-mingw32
cd ..
./autogen.sh # not required when building from tarball
CONFIG_SITE=$PWD/depends/i686-w64-mingw32/share/config.site ./configure  --disable-tests --disable-gui-tests --disable-bench --prefix=/
make clean
make
make install DESTDIR=`pwd`/../win32install
