#!/bin/bash

DBUSER="dbuser"
DBPASS="dbpass123"
DBNAME="blockexplorerdatabase"

COIN_NAME="Rtidcoin"
COIN_SYMBOL="RTID"
PAGE_TITLE="Rtidcoin"

RPCUSER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1);
RPCPASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1);
RPCPORT="9999"

rtidcoin-cli stop
echo "" > /root/.rtidcoin/rtidcoin.conf
echo -e rpcuser=$RPCUSER"\n"rpcpassword=$RPCPASS"\n"rpcport=$RPCPORT > /root/.rtidcoin/rtidcoin.conf
rtidcoind -daemon
sleep 10


GENESIS_BLOCK=`rtidcoin-cli getblockhash 0`
GENESIS_TX=`rtidcoin-cli getblock \`rtidcoin-cli getblockhash 0\` | grep merkleroot | cut -d'"' -f4`

apt-get -y install libkrb5-dev
apt-get -y install build-essential

apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list
apt-get update
apt-get -y install mongodb-org=2.6.3 mongodb-org-server=2.6.3 mongodb-org-shell=2.6.3 mongodb-org-mongos=2.6.3 mongodb-org-tools=2.6.3
# Lock this version, do not update
echo "mongodb-org hold" | dpkg --set-selections
echo "mongodb-org-server hold" | dpkg --set-selections
echo "mongodb-org-shell hold" | dpkg --set-selections
echo "mongodb-org-mongos hold" | dpkg --set-selections
echo "mongodb-org-tools hold" | dpkg --set-selections
# Start mongodb service
service mongod start

wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
echo "export NVM_DIR='$HOME'/.nvm" >> ~/.bashrc
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
nvm install 4.0
nvm use 4.0

git clone https://github.com/iquidus/explorer
cd explorer && npm install --production
cp ./settings.json.template ./settings.json

sed -i "s|127.0.0.1:3001|127.0.0.1:80|g" settings.json
sed -i "s|3001|80|g" settings.json
sed -i "s|Darkcoin|$COIN_NAME|g" settings.json
sed -i "s|DRK|$COIN_SYMBOL|g" settings.json
sed -i "s|IQUIDUS|$PAGE_TITLE|g" settings.json
sed -i "s|1337|0|g" settings.json
sed -i "s|1733320247b15ca2262be646397d1ffd6be953fa638ebb8f5dcbb4c2b91b34f1|$GENESIS_BLOCK|g" settings.json
sed -i "s|f270cd3813254c9922a2e222a56ba745842d9112223a1394062e460b33d27b7e|$GENESIS_TX|g" settings.json
sed -i "s|b2926a56ca64e0cd2430347e383f63ad7092f406088b9b86d6d68c2a34baef51|$GENESIS_BLOCK|g" settings.json
sed -i "s|65f705d2f385dc85763a317b3ec000063003d6b039546af5d8195a5ec27ae410|$GENESIS_TX|g" settings.json
sed -i "s|RBiXWscC63Jdn1GfDtRj8hgv4Q6Zppvpwb|$ADDRESS|g" settings.json

sed -i "s|iquidus|$DBUSER|g" settings.json
sed -i "s|3xp!0reR|$DBPASS|g" settings.json
sed -i "s|explorerdb|$DBNAME|g" settings.json

sed -i "s|darkcoinrpc|$RPCUSER|g" settings.json
sed -i "s|123gfjk3R3pCCVjHtbRde2s5kzdf233sa|$RPCPASS|g" settings.json
sed -i "s|9332|$RPCPORT|g" settings.json

cat >> database.js <<EOF
use $DBNAME
db.createUser( { user: "$DBUSER", pwd: "$DBPASS", roles: [ "readWrite" ] } )
EOF

mongo < database.js

cat >> runexplorer.sh <<EOF
#!/bin/bash
source /root/.bashrc
cd /root/explorer
nohup /root/.nvm/versions/node/v4.0.0/bin/npm start /root/explorer/package.json &
EOF

chmod a+x runexplorer.sh

echo "***************************************************************************"
echo "You can run block explorer with: (or you can add this line into your rc.local)"
echo ">sudo /root/explorer/runexplorer.sh
