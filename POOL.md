Mining pool installation
====================

You can use this automatic script
```bash
wget https://raw.githubusercontent.com/lukasniedoba/altcoingenerator/master/installpool.sh
chmod u+x installpool.sh
./installpool.sh
# Just press return few times when prompted for redis port etc.
# Run pool like this or add it to your rc.local file for example: "nohup mono /root/coiniumservyescrypt/build/bin/Release/CoiniumServ.exe &"
mono /root/coiniumservyescrypt/build/bin/Release/CoiniumServ.exe
```


+ [Mono download](http://www.mono-project.com/download/stable/)
+ Ubuntu 14.04

```bash
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb http://download.mono-project.com/repo/ubuntu stable-trusty main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
sudo apt-get update
sudo apt-get install mono-devel mono-complete mono-dbg referenceassemblies-pcl mono-xsp4 ca-certificates-mono
```
+ Debian 8
```bash
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb http://download.mono-project.com/repo/debian stable-jessie main" | tee /etc/apt/sources.list.d/mono-official-stable.list
apt-get update
apt-get -y install mono-devel mono-complete mono-dbg referenceassemblies-pcl mono-xsp4 ca-certificates-mono
```
+ [Mysql installation example](https://linode.com/docs/databases/mysql/how-to-install-mysql-on-debian-8/)
+ Install mysql and set up privileges. Suppose the user is root.

```bash
apt-get -y install mysql-server
mysql -u root -p
# set following
> CREATE DATABASE coinium;
> GRANT ALL PRIVILEGES ON coinium.* TO 'root'@'localhost' WITH GRANT OPTION;
> GRANT ALL ON coinium.* TO 'root'@'localhost' WITH GRANT OPTION;
> exit
```

+ [Redis install](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-redis)
+ Install Redis memory database

```bash
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
```
+ Build Coinium

```bash
cd ~
apt-get -y install git
apt-get -y install nuget
git clone https://niedoluk@bitbucket.org/niedoluk/coiniumservyescrypt.git
cd coiniumservyescrypt/
nuget restore
xbuild CoiniumServ.sln /p:Configuration="Release"
cp src/CoiniumServ/Algorithms/Implementations/libyescrypt.so build/bin/Release
```
+ [Configure coinium help](https://github.com/bonesoul/CoiniumServ/wiki/Configuration)
+ Configure coinium files:

Config file                                                             | Description                                                          | Link
------------------------------------------------------------------------|----------------------------------------------------------------------|------------------
coiniumservyescrypt/build/bin/Release/config/config.json                | General config file                                                  | [config.json](https://raw.githubusercontent.com/lukasniedoba/altcoingenerator/master/configpoolexamples/config.json)
coiniumservyescrypt/build/bin/Release/config/pools/default.json         | Main pool config                                                     | [default.json](https://raw.githubusercontent.com/lukasniedoba/altcoingenerator/master/configpoolexamples/pools/default.json)
coiniumservyescrypt/build/bin/Release/config/pools/pool.json            | Per pool config file (there could be more pools)                     | [pool.json](https://raw.githubusercontent.com/lukasniedoba/altcoingenerator/master/configpoolexamples/pools/pool.json)
coiniumservyescrypt/build/bin/Release/config/coins/rtidcoin.json         | Coin confuguration file. You must create this file                   | [rtidcoin.json](https://raw.githubusercontent.com/lukasniedoba/altcoingenerator/master/configpoolexamples/coins/rtidcoin.json)


+ Running
```bash
cd coiniumservyescrypt/build/bin/Release
mono CoiniumServ.exe
```
