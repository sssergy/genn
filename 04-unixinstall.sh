#!/bin/bash

source config.sh

COIN_NAME_LOWER=${COIN_NAME,,}

cd ${COIN_NAME_LOWER}
rm -rf ~/.${COIN_NAME_LOWER}
sudo make install
