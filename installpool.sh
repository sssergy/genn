#!/bin/bash

# change this to your coin reward address (where percentual mined reward goes)
REWARDADDRESS="RMfxMEmzkkVCtREA1HyWzBMJSaM2iHi8uH"

# you can edit following db password
DBPASS="dbpass"
DBNAME="coiniumdb"

RPCUSER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1);
RPCPASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1);
RPCPORT="9332"

rtidcoin-cli stop
echo "" > /root/.rtidcoin/rtidcoin.conf
echo -e rpcuser=$RPCUSER"\n"rpcpassword=$RPCPASS"\n"rpcport=$RPCPORT > /root/.rtidcoin/rtidcoin.conf
rtidcoind -daemon
sleep 10


# find out what the magic bytes are
sleep 5
MAINMAGIC=`head -c 4 ~/.rtidcoin/blocks/blk00000.dat |hexdump -e '16/1 "%02x" "\n"'`
rtidcoin-cli stop
rtidcoind -daemon -testnet
sleep 10
TESTMAGIC=`head -c 4 ~/.rtidcoin/testnet4/blocks/blk00000.dat |hexdump -e '16/1 "%02x" "\n"'`
rtidcoin-cli stop
rtidcoind -daemon
sleep 5

POOLADDRESS=`rtidcoin-cli getnewaddress`


# install mono framework (needed to build and run C#)
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb http://download.mono-project.com/repo/debian stable-jessie main" | tee /etc/apt/sources.list.d/mono-official-stable.list
apt-get update
apt-get -y install mono-devel mono-complete mono-dbg referenceassemblies-pcl mono-xsp4 ca-certificates-mono

# install database with pre-set password
export DEBIAN_FRONTEND="noninteractive"
debconf-set-selections <<< "mariadb-server mysql-server/root_password password $DBPASS"
debconf-set-selections <<< "mariadb-server mysql-server/root_password_again password $DBPASS"
apt-get -y install mariadb-server

# create database initializotion script
cat >> createdatabase <<EOF
CREATE DATABASE $DBNAME;
GRANT ALL PRIVILEGES ON $DBNAME.* TO 'root'@'localhost' WITH GRANT OPTION;
GRANT ALL ON $DBNAME.* TO 'root'@'localhost' WITH GRANT OPTION;
EOF

# initialize database with script
mysql -u root --password=$DBPASS < createdatabase

# install redis
cd ~
apt-get -y install build-essential
apt-get -y install tcl8.5
wget http://download.redis.io/releases/redis-stable.tar.gz
tar xzf redis-stable.tar.gz
cd redis-stable
make
make install
cd utils
./install_server.sh
service redis_6379 start
update-rc.d redis_6379 defaults

# build coinium
cd ~
apt-get -y install git
apt-get -y install nuget
git clone https://niedoluk@bitbucket.org/niedoluk/coiniumservyescrypt.git
cd coiniumservyescrypt/
nuget restore
xbuild CoiniumServ.sln /p:Configuration="Release"
cp src/CoiniumServ/Algorithms/Implementations/libyescrypt.so build/bin/Release







DBUSER="root"
sed -i "s|fbc0b6db|$MAINMAGIC|g" build/bin/Release/config/coins/rtidcoin.json
sed -i "s|fcc1b7dc|$TESTMAGIC|g" build/bin/Release/config/coins/rtidcoin.json

sed -i "s|dbusername|$DBUSER|g" build/bin/Release/config/pools/default.json
sed -i "s|dbpassword|$DBPASS|g" build/bin/Release/config/pools/default.json

sed -i "s|9333|$RPCPORT|g" build/bin/Release/config/pools/pool.json
sed -i "s|rpcuser|$RPCUSER|g" build/bin/Release/config/pools/pool.json
sed -i "s|rpcpass|$RPCPASS|g" build/bin/Release/config/pools/pool.json
sed -i "s|false|true|g" build/bin/Release/config/pools/pool.json
sed -i "s|n3Mvrshbf4fMoHzWZkDVbhhx4BLZCcU9oY|$POOLADDRESS|g" build/bin/Release/config/pools/pool.json
sed -i "s|myxWybbhUkGzGF7yaf2QVNx3hh3HWTya5t|$REWARDADDRESS|g" build/bin/Release/config/pools/pool.json
sed -i "s|dbname|$DBNAME|g" build/bin/Release/config/pools/pool.json
sed -i "s|dbusername|$DBUSER|g" build/bin/Release/config/pools/pool.json
sed -i "s|dbname|$DBNAME|g" build/bin/Release/config/pools/pool.json
sed -i "s|dbpassword|$DBPASS|g" build/bin/Release/config/pools/pool.json
