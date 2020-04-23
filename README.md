Create custom coin
====================

This is an automated generator of a custom coin. Set of scripts described below downloads the Litecoin source code (currently 0.14.2) and modifies it according to parameters set in configuration file. Scrypt POW algorithm is switched for the YescryptR16 and DarkGravityWave v3 is added for the purpose of difficulty computation.

The best choice to run this script is Ubuntu 14.04 (Because of crosscompilation runs only with this version) but if you do not crosscompile, you can run also on Ubuntu 16.10 or Debian Jessie, but then you should switch the variable for DEBIAN in config.sh.

Description of files
---------------------

File                          | Description
------------------------------|------------------
config.sh                     | here you can set all desired altcoin params
00-install-dependencies.sh    | install dependencies necessary for unix build
01-mine-genesis.sh            | contains script for mining the genesis block according to the last configuration in the config.sh. !!! Please NOTE that this step overwrites and removes your coin folder if it is already generated!!!
02-generate-code.sh           | contains script for downloading and customizing the litecoin code; (deletes) and creates COIN_NAME folder according to the last configuration in the config.sh
03-compilation.sh             | compiles the coin for unix
04-unixinstall.sh             | will install coin on your build computer
05-crosscompilation.sh        | automatically grab libraries for the Windows and crosscompiles coin for 32 and 64 bit
DNSSeedsMain.txt              | DNSSeedNodes mainnet domains (one per line)
DNSSeedsTest.txt              | DNSSeedNodes testnet domains (one per line)
DomainSeedsMain.txt           | SeedNodes mainnet domains (one per line, after start of the daemon those domains are resolved to ips)
DomainSeedsTest.txt           | SeedNodes testnet domains (one per line, after start of the daemon those domains are resolved to ips)
seeds/nodes_main.txt          | SeedNodes mainnet ips:ports (one per line)
seeds/nodes_test.txt          | SeedNodes testnet ips:ports (one per line)

Graphics
---------------------

Graphics and icons are stored in the folder named "icons". Please change those files for your own.

File                                   | Description
---------------------------------------|------------------
icons/about.png                        | ...
icons/bitcoin.ico                      | This could be editted with icofx
icons/bitcoin.png                      | ...
icons/bitcoin_testnet.ico              | This could be editted with icofx
icons/bitcoin.icns                     | This could be editted with icofx

Coin generation process
---------------------

```bash
sudo apt-get install git  
git clone https://github.com/lukasniedoba/altcoingenerator
cd altcoingenerator
# Customize params in config.sh
# You can customize DNSSeedNodes domains. Place them one domain per line to the DNSSeedsMain.txt file for main net and to the DNSSeedsTest.txt for testnet.
# Also you can customize SeedNodes ips. Just place them one ip per line to the seeds/nodes_main.txt file for main net and to the seeds/nodes_test.txt for testnet
# And finally you can customize SeedNodes domains. Just place them one domain per line to the DomainSeedsMain.txt file for main net and to the DomainSeedsTest.txt for testnet
# You just place ips and domains to the above mentioned files and script automatically generate the code
# Change icons and graphics stored in icons folder for your own
# Run:
./00-install-dependencies.sh
./01-mine-genesis.sh
./02-generate-code.sh
# Now you can save your code to the Github
./03-compilation.sh
# unixinstall contains unix binaries
# Coin code is stored in the folder with your coins name.
```

Next files which serves as configuration files for your coin generation (those are generated automatically through script and then stores all the necessary values):

	genesis/*
	magicbytes/*
	seeds/nodes_main.txt
	seeds/nodes_test.txt
	seeds/chainparamsseeds.h should contain hard coded seed servers.

UNIX INSTALL
---------------------

If you would like to install coin on your build computer just run ./04-unixinstall.sh

CROSS-COMPILATION
---------------------

1. Fire up the Ubuntu 14.04
2. Grab the whole "altcoingenerator" folder with already generated custom coin or just clone, customize and run ./01-code.sh
3. Run ./05-crosscompilation.sh
4. win64install and win32install contains windows installation binaries

CONFIGURATION-FILE
---------------------

If you are running your coin on linux without GUI wallet and want to use solo mining or coin-cli you should configure at least your username and password for the rpc calls. Minimum you should provide follows

The location of the coin config files. Suppose your coin name is Rtidcoin:
+ Windows XP C:\Documents and Settings\username\Application Data\Rtidcoin\rtidcoin.conf
+ Windows Vista, 7, 10 C:\Users\username\AppData\Roaming\Rtidcoin
+ Linux /home/username/.rtidcoin/rtidcoin.conf     

```
rpcuser=myusername
rpcpassword=YourWeryStrongPasswordAFASERGASDFSAWaewfa34
rpcport=9999
```

You can add the daemon=1 which will run coind as daemon by default without -daemon parameter

CPU miner
---------------------

Run on localhost when daemon configured like above. Change to your username, password and wallet address

```
./cpuminer -a yescryptr16 -o http://127.0.0.1:9999 -u myusername -p YourWeryStrongPasswordAFASERGASDFSAWaewfa34 --coinbase-addr=EVTBc1s56yXXWLaZbUp2W3bdEbHpxhfvc4
```

USEFULL LINKS
---------------------

+ [Cli api call list](https://en.bitcoin.it/wiki/Original_Bitcoin_client/API_calls_list)
+ [Running daemon overview](https://en.bitcoin.it/wiki/Running_Bitcoin)
