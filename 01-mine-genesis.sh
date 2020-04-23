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
    ./configure --disable-tests --disable-gui-tests --disable-bench LDFLAGS="-L${BDB_PREFIX}/lib/" CPPFLAGS="-I${BDB_PREFIX}/include/"
else
    ./configure --disable-tests --disable-gui-tests --disable-bench --without-gui
fi
export NUMCPUS=`grep -c '^processor' /proc/cpuinfo`
make


echo " "
echo "Mining genesis blocks now... this may take a while or not, depends on your NBITS config..."
src/${COIN_NAME_LOWER}d
echo "Genesis blocks mined"
}

./02-generate-code.sh -genesis
cd ${COIN_NAME_LOWER}
build
cd ..
rm -rf ${COIN_NAME_LOWER}
