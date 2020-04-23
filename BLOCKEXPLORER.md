Block explorer installation
====================

+ You can use this [script](installexplorer.sh)
```bash
wget https://raw.githubusercontent.com/lukasniedoba/altcoingenerator/master/installexplorer.sh
chmod u+x installexplorer.sh
./installexplorer.sh
# Then run like this or add this line to your rc.local file
sudo /root/explorer/runexplorer.sh
```

# Install dependencies

```bash
apt-get install -y libkrb5-dev
apt-get install -y build-essential
```

## Install mongodb

Must be version 2.6.3

```bash
apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list
apt-get update
apt-get install mongodb-org=2.6.3 mongodb-org-server=2.6.3 mongodb-org-shell=2.6.3 mongodb-org-mongos=2.6.3 mongodb-org-tools=2.6.3
# Lock this version, do not update
echo "mongodb-org hold" | dpkg --set-selections
echo "mongodb-org-server hold" | dpkg --set-selections
echo "mongodb-org-shell hold" | dpkg --set-selections
echo "mongodb-org-mongos hold" | dpkg --set-selections
echo "mongodb-org-tools hold" | dpkg --set-selections
# Start mongodb service
service mongod start
```

```bash
mongo
> use explorerdb
> db.createUser( { user: "explorer", pwd: "pass123", roles: [ "readWrite" ] } )
> exit
```

# Install nodejs

```bash
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
echo "export NVM_DIR='$HOME'/.nvm" >> ~/.bashrc
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
nvm install 4.0
nvm use 4.0
```
# You should edit your daemon configure files

Daemon configure files (~/.rtidcoin/rtidcoin.conf) should contain at least following parameters to blockexplorer work correctly

```
rpcuser=rtidcoinrpc
rpcpassword=f3dark434fdjgsasfgtrdhsseasdfSAEDaasdfaf
rpcport=9999
```

# Download and install iquidus block explorer

```bash
git clone https://github.com/iquidus/explorer
cd explorer && npm install --production
cp ./settings.json.template ./settings.json
# customize your settings
```

Edit settings.json


```bash
# Go to the explorer folder and run like this
npm start
```

Or use screen. Suppose you placed explorer folder into /root/explorer

```bash
screen -dm bash -c "cd /root/explorer/ && npm start"
```
