#!/bin/bash

cd seeds
python3 generate-seeds.py ./ > chainparamsseeds.h
cd ..

if [ "$1" = "-genesis" ]; then
  source config.sh
  IF_GENESIS="TRUE"
  IF_KEYS="TRUE"
else
  IF_GENESIS="FALSE"
  IF_KEYS="FALSE"
  source config.sh
fi
# Message start strings (magic bytes)
# The message start string is designed to be unlikely to occur in normal data.
# The characters are rarely used upper ASCII, not valid as UTF-8, and produce
# a large 32-bit integer with any alignment.
#MAINNET
MAIN_MESSAGE_S_0=`cat magicbytes/MAIN_MESSAGE_S_0.txt`
MAIN_MESSAGE_S_1=`cat magicbytes/MAIN_MESSAGE_S_1.txt`
MAIN_MESSAGE_S_2=`cat magicbytes/MAIN_MESSAGE_S_2.txt`
MAIN_MESSAGE_S_3=`cat magicbytes/MAIN_MESSAGE_S_3.txt`
#TESTNET
TEST_MESSAGE_S_0=`cat magicbytes/TEST_MESSAGE_S_0.txt`
TEST_MESSAGE_S_1=`cat magicbytes/TEST_MESSAGE_S_1.txt`
TEST_MESSAGE_S_2=`cat magicbytes/TEST_MESSAGE_S_2.txt`
TEST_MESSAGE_S_3=`cat magicbytes/TEST_MESSAGE_S_3.txt`
#REGTEST
REGTEST_MESSAGE_S_0=`cat magicbytes/REGTEST_MESSAGE_S_0.txt`
REGTEST_MESSAGE_S_1=`cat magicbytes/REGTEST_MESSAGE_S_1.txt`
REGTEST_MESSAGE_S_2=`cat magicbytes/REGTEST_MESSAGE_S_2.txt`
REGTEST_MESSAGE_S_3=`cat magicbytes/REGTEST_MESSAGE_S_3.txt`


# Key string prefixes mainnet extended address
MAIN_PREFIX_PUBLIC=`./ext_address_generator.py ${PUBLIC_PREFIX_MAIN} 74`
MAIN_PREFIX_SECRET=`./ext_address_generator.py ${PRIVATE_PREFIX_MAIN} 74`

# Key string prefixes testnet extended address
TEST_PREFIX_PUBLIC=`./ext_address_generator.py ${PUBLIC_PREFIX_TEST} 74`
TEST_PREFIX_SECRET=`./ext_address_generator.py ${PRIVATE_PREFIX_TEST} 74`





COIN_NAME_LOWER=${COIN_NAME,,}
COIN_NAME_UPPER=${COIN_NAME^^}




if [ $IF_KEYS == "TRUE" ]
then
  # openssl ecparam -genkey -name secp256k1 -out alertkey.pem
  # openssl ec -in alertkey.pem -text > alertkey.hex
  # openssl ecparam -genkey -name secp256k1 -out testnetalert.pem
  # openssl ec -in testnetalert.pem -text > testnetalert.hex
  openssl ecparam -genkey -name secp256k1 -out genesis/genesiscoinbase.pem
  openssl ec -in genesis/genesiscoinbase.pem -text > genesis/genesiscoinbase.hex
fi
# MAINALERTKEY=`./readkey.sh alertkey.hex`
# TESTALERTKEY=`./readkey.sh testnetalert.hex`
GENESISCOINBASEKEY=`./readkey.sh genesis/genesiscoinbase.hex`

whole_stuff() {
#read mined genesis, merkle, nonce from file
MAIN_NONCE=`cat genesis/mainnonce.txt`
TEST_NONCE=`cat genesis/testnonce.txt`
REGTEST_NONCE=`cat genesis/regtestnonce.txt`
MAIN_GENESIS_HASH=`cat genesis/maingenesis.txt`
MAIN_MERKLE_HASH=`cat genesis/mainmerkle.txt`
TEST_GENESIS_HASH=`cat genesis/testgenesis.txt`
TEST_MERKLE_HASH=`cat genesis/testmerkle.txt`
REGTEST_GENESIS_HASH=`cat genesis/regtestgenesis.txt`
REGTEST_MERKLE_HASH=`cat genesis/regtestmerkle.txt`

# download and unpack litecoin sources into new coin folder
rm -rf $COIN_NAME_LOWER
wget ${RELEASE_URL} -O ${COIN_NAME_LOWER}.tar.gz
mkdir ${COIN_NAME_LOWER}
tar -xf ${COIN_NAME_LOWER}.tar.gz -C ./${COIN_NAME_LOWER} --strip-components 1
rm ${COIN_NAME_LOWER}.tar.gz

# copy yescryptR16 files into new coin source folder
cp -r hash ${COIN_NAME_LOWER}/src/

#copy icons
cp icons/about.png ${COIN_NAME_LOWER}/src/qt/res/icons/
cp icons/bitcoin.ico ${COIN_NAME_LOWER}/src/qt/res/icons/
cp icons/bitcoin.png ${COIN_NAME_LOWER}/src/qt/res/icons/
cp icons/bitcoin_testnet.ico ${COIN_NAME_LOWER}/src/qt/res/icons/
cp icons/bitcoin.icns ${COIN_NAME_LOWER}/src/qt/res/icons/


# pushd $COIN_NAME
cd ${COIN_NAME_LOWER}


if [ -d $COIN_NAME_LOWER ]; then
    echo "Warning: $COIN_NAME_LOWER already existing"
    return 0
fi


# first rename all directories
for i in $(find . -type d | grep -v "^./.git" | grep litecoin); do
    mv $i $(echo $i| sed "s/litecoin/$COIN_NAME_LOWER/")
done

# then rename all files
for i in $(find . -type f | grep -v "^./.git" | grep litecoin); do
    mv $i $(echo $i| sed "s/litecoin/$COIN_NAME_LOWER/")
done

# now replace all litecoin references to the new coin name
for i in $(find . -type f | grep -v "^./.git"); do
    sed -i "s/Litecoin/$COIN_NAME/g" $i
    sed -i "s/litecoin/$COIN_NAME_LOWER/g" $i
    sed -i "s/LITECOIN/$COIN_NAME_UPPER/g" $i
    sed -i "s/LTC/$COIN_UNIT/g" $i
done

sed -i "/std::string[[:space:]]URL_SOURCE_CODE/c\    const std::string URL_SOURCE_CODE = \"<$COIN_GITHUB>\";" src/init.cpp
sed -i "/std::string[[:space:]]URL_WEBSITE/c\    const std::string URL_WEBSITE = \"<$URL_WEBSITE>\";" src/init.cpp

sed -i "s/2011/$FROM_YEAR/" src/init.cpp
sed -i "s/2011/$FROM_YEAR/" src/util.cpp
sed -i "s/2011/$FROM_YEAR/" src/qt/splashscreen.cpp

sed -i "/define[[:space:]]QAPP_ORG_DOMAIN/c\#define QAPP_ORG_DOMAIN \"$COIN_DOMAIN\"" src/qt/guiconstants.h

sed -i "/define[[:space:]]COPYRIGHT_YEAR/c\#define COPYRIGHT_YEAR $TO_YEAR" src/clientversion.h

sed -i "/define(_COPYRIGHT_YEAR,[[:space:]]2017)/c\define(_COPYRIGHT_YEAR, $TO_YEAR)" configure.ac

sed -i "s/84000000/$MAX_MONEY/" src/amount.h

# add yescryptR16 sources to autogen makefile
sed -i -e 's#consensus/validation.h[[:space:]]\\#consensus/validation.h \\\n  hash/yescrypt/yescrypt.h \\\n  hash/yescrypt/yescrypt.c \\\n  hash/yescrypt/sha256.h \\\n  hash/yescrypt/sha256_c.h \\\n  hash/yescrypt/yescrypt-best_c.h \\\n  hash/yescrypt/sysendian.h \\\n  hash/yescrypt/yescrypt-platform_c.h \\\n  hash/yescrypt/yescrypt-opt_c.h \\\n  hash/yescrypt/yescrypt-simd_c.h \\#g' src/Makefile.am
echo '' >> src/Makefile.am
echo 'if TARGET_DARWIN' >> src/Makefile.am
echo 'CFLAGS += -O3 -msse4.1 -funroll-loops -fomit-frame-pointer' >> src/Makefile.am
echo 'else' >> src/Makefile.am
echo 'CFLAGS += -msse4.1 -fPIC' >> src/Makefile.am
echo 'endif' >> src/Makefile.am

# deactivate chain control
sed -i -e 's#// Once this function has returned false, it must remain false.#return false;\n    // Once this function has returned false, it must remain false.#g' src/validation.cpp
sed -i -e 's#if[[:space:]](nHeight[[:space:]]>=[[:space:]]consensusParams.BIP34Height)#if (nHeight >= consensusParams.BIP34Height \&\& nHeight >= 1500)#g' src/validation.cpp
# sed -i -e 's#if[[:space:]](nHeight[[:space:]]>=[[:space:]]consensusParams.BIP34Height)#//if (nHeight >= consensusParams.BIP34Height)\n    if(false)#g' src/validation.cpp

#copy seeds file
cp ../seeds/chainparamsseeds.h src/

#change hash to yescrypt
sed -i -e 's+#include[[:space:]]"crypto/scrypt.h"+#include "crypto/scrypt.h"\n\nextern "C" void yescrypt_hash(const char *input, char *output);+g' src/primitives/block.cpp
sed -i -e 's+scrypt_1024_1_1_256+yescrypt_hash+g' src/primitives/block.cpp

#change block size
MAX_BLOCK_BASE_SIZE="$(( $MAX_BLOCK_BASE_SIZE_MB * 1000000 ))"
MAX_BLOCK_WEIGHT="$(( $MAX_BLOCK_BASE_SIZE * 4 ))"
MAX_BLOCK_SIGOPS_COST="$(( $MAX_BLOCK_BASE_SIZE_MB * 80000 ))"
DEFAULT_BLOCK_MAX_SIZE="$(( $MAX_BLOCK_BASE_SIZE_MB * 750000 ))"
DEFAULT_BLOCK_MAX_WEIGHT="$(( $MAX_BLOCK_BASE_SIZE_MB * 3000000 ))"
sed -i "s|4000000;|$MAX_BLOCK_WEIGHT ;|g" src/consensus/consensus.h
sed -i "s|1000000;|$MAX_BLOCK_BASE_SIZE ;|g" src/consensus/consensus.h
sed -i "s|80000;|$MAX_BLOCK_SIGOPS_COST ;|g" src/consensus/consensus.h
sed -i "s|750000;|$DEFAULT_BLOCK_MAX_SIZE ;|g" src/policy/policy.h
sed -i "s|3000000;|$DEFAULT_BLOCK_MAX_WEIGHT ;|g" src/policy/policy.h


# change Fees
sed -i "s|100000;|$MIN_FEE ;|g" src/policy/policy.h
sed -i "s|1000;|$MIN_FEE ;|g" src/policy/policy.h
sed -i "s|=[[:space:]]100000;|= $MIN_FEE ;|g" src/validation.h
sed -i "s|100000;|$MIN_FEE ;|g" src/wallet/wallet.h
sed -i "s|2000000;|$DEFAULT_FALLBACK_FEE ;|g" src/wallet/wallet.h

sed -i "s|=[[:space:]]0.1[[:space:]]\*[[:space:]]COIN;|= $DEFAULT_TRANSACTION_MAXFEE ;|g" src/validation.h
sed -i "s|=[[:space:]]0.01[[:space:]]\*[[:space:]]COIN;|= $HIGH_TX_FEE_PER_KB ;|g" src/validation.h
sed -i "s|=[[:space:]]100[[:space:]]\*[[:space:]]HIGH_TX_FEE_PER_KB;|= $HIGH_MAX_TX_FEE ;|g" src/validation.h


# change deploument dates
# sed -i "s|1517356801|$DEPLOYMENT_CSV_SEGWIT|g" src/chainparams.cpp

#change coinbase maturity
sed -i "s|100;|$COINBASE_MATURITY ;|g" src/consensus/consensus.h


#change genesis coinbase key
sed -i "s;040184710fa689ad5023690c80f3a49c8f13f8d45b8c857fbcbc8bc4a8e4d3eb4b10f4d4604fa08dce601aaf0f470216fe1b51850b4acf21b179c45070ac7b03a9;$GENESISCOINBASEKEY;" src/chainparams.cpp
#change mainnet alertkey
# sed -i "s;040184710fa689ad5023690c80f3a49c8f13f8d45b8c857fbcbc8bc4a8e4d3eb4b10f4d4604fa08dce601aaf0f470216fe1b51850b4acf21b179c45070ac7b03a9;$MAINALERTKEY;" src/chainparams.cpp
#change testnet alertkey
# sed -i "s;040184710fa689ad5023690c80f3a49c8f13f8d45b8c857fbcbc8bc4a8e4d3eb4b10f4d4604fa08dce601aaf0f470216fe1b51850b4acf21b179c45070ac7b03a9;$TESTALERTKEY;" src/chainparams.cpp

sed -i -e 's+#include[[:space:]]"chainparamsseeds.h"+#include "chainparamsseeds.h"\n#include "netbase.h"\n\n\nSeedSpec6 lookupDomain(const char *name,int port);\n+g' src/chainparams.cpp
#add mining code
if [ $IF_GENESIS == "TRUE" ]
then
  #MAINNET
  MAIN_MESSAGE_S_0="0x"`for i in $(seq 1 2); do echo -n $(echo "obase=16; $(($RANDOM % 16))" | bc); done; echo`
  MAIN_MESSAGE_S_0=${MAIN_MESSAGE_S_0,,}
  echo $MAIN_MESSAGE_S_0 > ../magicbytes/MAIN_MESSAGE_S_0.txt
  MAIN_MESSAGE_S_1="0x"`for i in $(seq 1 2); do echo -n $(echo "obase=16; $(($RANDOM % 16))" | bc); done; echo`
  MAIN_MESSAGE_S_1=${MAIN_MESSAGE_S_1,,}
  echo $MAIN_MESSAGE_S_1 > ../magicbytes/MAIN_MESSAGE_S_1.txt
  MAIN_MESSAGE_S_2="0x"`for i in $(seq 1 2); do echo -n $(echo "obase=16; $(($RANDOM % 16))" | bc); done; echo`
  MAIN_MESSAGE_S_2=${MAIN_MESSAGE_S_2,,}
  echo $MAIN_MESSAGE_S_2 > ../magicbytes/MAIN_MESSAGE_S_2.txt
  MAIN_MESSAGE_S_3="0x"`for i in $(seq 1 2); do echo -n $(echo "obase=16; $(($RANDOM % 16))" | bc); done; echo`
  MAIN_MESSAGE_S_3=${MAIN_MESSAGE_S_3,,}
  echo $MAIN_MESSAGE_S_3 > ../magicbytes/MAIN_MESSAGE_S_3.txt
  #TESTNET
  TEST_MESSAGE_S_0="0x"`for i in $(seq 1 2); do echo -n $(echo "obase=16; $(($RANDOM % 16))" | bc); done; echo`
  TEST_MESSAGE_S_0=${TEST_MESSAGE_S_0,,}
  echo $TEST_MESSAGE_S_0 > ../magicbytes/TEST_MESSAGE_S_0.txt
  TEST_MESSAGE_S_1="0x"`for i in $(seq 1 2); do echo -n $(echo "obase=16; $(($RANDOM % 16))" | bc); done; echo`
  TEST_MESSAGE_S_1=${TEST_MESSAGE_S_1,,}
  echo $TEST_MESSAGE_S_1 > ../magicbytes/TEST_MESSAGE_S_1.txt
  TEST_MESSAGE_S_2="0x"`for i in $(seq 1 2); do echo -n $(echo "obase=16; $(($RANDOM % 16))" | bc); done; echo`
  TEST_MESSAGE_S_2=${TEST_MESSAGE_S_2,,}
  echo $TEST_MESSAGE_S_2 > ../magicbytes/TEST_MESSAGE_S_2.txt
  TEST_MESSAGE_S_3="0x"`for i in $(seq 1 2); do echo -n $(echo "obase=16; $(($RANDOM % 16))" | bc); done; echo`
  TEST_MESSAGE_S_3=${TEST_MESSAGE_S_3,,}
  echo $TEST_MESSAGE_S_3 > ../magicbytes/TEST_MESSAGE_S_3.txt
  #REGTEST
  REGTEST_MESSAGE_S_0="0x"`for i in $(seq 1 2); do echo -n $(echo "obase=16; $(($RANDOM % 16))" | bc); done; echo`
  REGTEST_MESSAGE_S_0=${REGTEST_MESSAGE_S_0,,}
  echo $REGTEST_MESSAGE_S_0 > ../magicbytes/REGTEST_MESSAGE_S_0.txt
  REGTEST_MESSAGE_S_1="0x"`for i in $(seq 1 2); do echo -n $(echo "obase=16; $(($RANDOM % 16))" | bc); done; echo`
  REGTEST_MESSAGE_S_1=${REGTEST_MESSAGE_S_1,,}
  echo $REGTEST_MESSAGE_S_1 > ../magicbytes/REGTEST_MESSAGE_S_1.txt
  REGTEST_MESSAGE_S_2="0x"`for i in $(seq 1 2); do echo -n $(echo "obase=16; $(($RANDOM % 16))" | bc); done; echo`
  REGTEST_MESSAGE_S_2=${REGTEST_MESSAGE_S_2,,}
  echo $REGTEST_MESSAGE_S_2 > ../magicbytes/REGTEST_MESSAGE_S_2.txt
  REGTEST_MESSAGE_S_3="0x"`for i in $(seq 1 2); do echo -n $(echo "obase=16; $(($RANDOM % 16))" | bc); done; echo`
  REGTEST_MESSAGE_S_3=${REGTEST_MESSAGE_S_3,,}
  echo $REGTEST_MESSAGE_S_3 > ../magicbytes/REGTEST_MESSAGE_S_3.txt




  sed -i -e 's+#include[[:space:]]"chainparamsseeds.h"+#include "chainparamsseeds.h"\n#include "arith_uint256.h"\n#include <iostream>\n#include <fstream>\n\nbool CheckProofOfWorkCustom(uint256 hash, unsigned int nBits, const Consensus::Params\& params);\n\nbool mineMainnet = true;\nbool mineTestNet = true;\nbool mineRegtest = true;\n\nvoid mineGenesis(Consensus::Params\& consensus,CBlock\& genesis,std::string net="main");+g' src/chainparams.cpp
  sed -i -e 's+genesis[[:space:]]=[[:space:]]CreateGenesisBlock(1317972665,[[:space:]]2084524493,[[:space:]]0x1e0ffff0,[[:space:]]1,[[:space:]]50[[:space:]]\*[[:space:]]COIN);+genesis = CreateGenesisBlock(1317972665, 0, 0x1e0ffff0, 1, 50 * COIN);\n        mineGenesis(consensus,genesis);+g' src/chainparams.cpp
  sed -i -e 's+genesis[[:space:]]=[[:space:]]CreateGenesisBlock(1486949366,[[:space:]]293345,[[:space:]]0x1e0ffff0,[[:space:]]1,[[:space:]]50[[:space:]]\*[[:space:]]COIN);+genesis = CreateGenesisBlock(1486949366, 0, 0x1e0ffff0, 1, 50 * COIN);\n        mineGenesis(consensus,genesis,"test");+g' src/chainparams.cpp
  sed -i -e 's+genesis[[:space:]]=[[:space:]]CreateGenesisBlock(1296688602,[[:space:]]0,[[:space:]]0x207fffff,[[:space:]]1,[[:space:]]50[[:space:]]\*[[:space:]]COIN);+genesis = CreateGenesisBlock(1296688602, 0, 0x207fffff, 1, 50 * COIN);\n        mineGenesis(consensus,genesis,"regtest");\n        exit(0);+g' src/chainparams.cpp
  sed -i -e 's+assert(+//assert(+g' src/chainparams.cpp

  echo 'bool CheckProofOfWorkCustom(uint256 hash, unsigned int nBits, const Consensus::Params& params)' >> src/chainparams.cpp
  echo '{' >> src/chainparams.cpp
  echo '    bool fNegative;' >> src/chainparams.cpp
  echo '    bool fOverflow;' >> src/chainparams.cpp
  echo '    arith_uint256 bnTarget;' >> src/chainparams.cpp
  echo '' >> src/chainparams.cpp
  echo '    bnTarget.SetCompact(nBits, &fNegative, &fOverflow);' >> src/chainparams.cpp
  echo '' >> src/chainparams.cpp
  echo '    // Check range' >> src/chainparams.cpp
  echo '    if (fNegative || bnTarget == 0 || fOverflow || bnTarget > UintToArith256(params.powLimit))' >> src/chainparams.cpp
  echo '        return false;' >> src/chainparams.cpp
  echo '' >> src/chainparams.cpp
  echo '    // Check proof of work matches claimed amoun' >> src/chainparams.cpp
  echo '    if (UintToArith256(hash) > bnTarget)' >> src/chainparams.cpp
  echo '        return false;' >> src/chainparams.cpp
  echo '' >> src/chainparams.cpp
  echo '    return true;' >> src/chainparams.cpp
  echo '}' >> src/chainparams.cpp
  echo '' >> src/chainparams.cpp
  echo '' >> src/chainparams.cpp

  echo 'void mineGenesis(Consensus::Params& consensus,CBlock& genesis,std::string net)' >> src/chainparams.cpp
  echo '{' >> src/chainparams.cpp
  echo '    consensus.hashGenesisBlock = uint256S("0x01");' >> src/chainparams.cpp
  echo '    int counter = 0;' >> src/chainparams.cpp
  echo '    while(!CheckProofOfWorkCustom(genesis.GetPoWHash(), genesis.nBits, consensus)){' >> src/chainparams.cpp
  echo '        if(genesis.nNonce % 1000000 == 0){' >> src/chainparams.cpp
  echo '          std::cout << ++counter <<  "Mh " << std::flush ;' >> src/chainparams.cpp
  echo '        }' >> src/chainparams.cpp
  echo '        ++genesis.nNonce;' >> src/chainparams.cpp
  echo '    }' >> src/chainparams.cpp
  echo '    std::ofstream ofile;' >> src/chainparams.cpp
  echo '    ofile.open("../genesis/"+net+"genesis.txt");' >> src/chainparams.cpp
  echo '    ofile << "0x" << genesis.GetHash().ToString();' >> src/chainparams.cpp
  echo '    ofile.close();' >> src/chainparams.cpp
  echo '    ofile.open("../genesis/"+net+"merkle.txt");' >> src/chainparams.cpp
  echo '    ofile << "0x" << genesis.hashMerkleRoot.ToString();' >> src/chainparams.cpp
  echo '    ofile.close();' >> src/chainparams.cpp
  echo '    ofile.open("../genesis/"+net+"nonce.txt");' >> src/chainparams.cpp
  echo '    ofile << genesis.nNonce;' >> src/chainparams.cpp
  echo '    ofile.close();' >> src/chainparams.cpp
  echo '}' >> src/chainparams.cpp
  echo '' >> src/chainparams.cpp
  echo '' >> src/chainparams.cpp

else
  echo " "
fi

# add seed domain resolve method
echo '' >> src/chainparams.cpp
echo '' >> src/chainparams.cpp
echo 'SeedSpec6 lookupDomain(const char *name,int port){' >> src/chainparams.cpp
echo '  SeedSpec6 addrseed;' >> src/chainparams.cpp
echo '  CNetAddr addrss;' >> src/chainparams.cpp
echo '  LookupHost(name,addrss, true);' >> src/chainparams.cpp
echo '  for(int i = 0; i < 16;i++){' >> src/chainparams.cpp
echo '    addrseed.addr[15-i] = addrss.GetByte(i);' >> src/chainparams.cpp
echo '  }' >> src/chainparams.cpp
echo '  addrseed.port = port;' >> src/chainparams.cpp
echo '  return addrseed;' >> src/chainparams.cpp
echo '}' >> src/chainparams.cpp
echo '' >> src/chainparams.cpp

# add DarkGravityWave v3 support
sed -i -e 's+#include[[:space:]]"util.h"+#include "util.h"\n\nunsigned int static DarkGravityWave(const CBlockIndex* pindexLast, const Consensus::Params\& params);+g' src/pow.cpp
sed -i -e 's+unsigned[[:space:]]int[[:space:]]nProofOfWorkLimit[[:space:]]=[[:space:]]UintToArith256(params.powLimit).GetCompact();+return DarkGravityWave(pindexLast,params);\n    unsigned int nProofOfWorkLimit = UintToArith256(params.powLimit).GetCompact();+g' src/pow.cpp

echo 'unsigned int static DarkGravityWave(const CBlockIndex* pindexLast, const Consensus::Params& params) {' >> src/pow.cpp
echo '    /* current difficulty formula, dash - DarkGravity v3, written by Evan Duffield - evan@dash.org */' >> src/pow.cpp
echo '    const arith_uint256 bnPowLimit = UintToArith256(params.powLimit);' >> src/pow.cpp
echo '    int64_t nPastBlocks = 24;' >> src/pow.cpp
echo '    // make sure we have at least (nPastBlocks + 1) blocks, otherwise just return powLimit' >> src/pow.cpp
echo '    if (!pindexLast || pindexLast->nHeight < nPastBlocks) {' >> src/pow.cpp
echo '        return bnPowLimit.GetCompact();' >> src/pow.cpp
echo '    }' >> src/pow.cpp
echo '    const CBlockIndex *pindex = pindexLast;' >> src/pow.cpp
echo '    arith_uint256 bnPastTargetAvg;' >> src/pow.cpp
echo '    for (unsigned int nCountBlocks = 1; nCountBlocks <= nPastBlocks; nCountBlocks++) {' >> src/pow.cpp
echo '        arith_uint256 bnTarget = arith_uint256().SetCompact(pindex->nBits);' >> src/pow.cpp
echo '        if (nCountBlocks == 1) {' >> src/pow.cpp
echo '            bnPastTargetAvg = bnTarget;' >> src/pow.cpp
echo '        } else {' >> src/pow.cpp
echo '            // NOTE: thats not an average really...' >> src/pow.cpp
echo '            bnPastTargetAvg = (bnPastTargetAvg * nCountBlocks + bnTarget) / (nCountBlocks + 1);' >> src/pow.cpp
echo '        }' >> src/pow.cpp
echo '' >> src/pow.cpp
echo '        if(nCountBlocks != nPastBlocks) {' >> src/pow.cpp
echo '            assert(pindex->pprev); // should never fail' >> src/pow.cpp
echo '            pindex = pindex->pprev;' >> src/pow.cpp
echo '        }' >> src/pow.cpp
echo '    }' >> src/pow.cpp
echo '' >> src/pow.cpp
echo '    arith_uint256 bnNew(bnPastTargetAvg);' >> src/pow.cpp
echo '    int64_t nActualTimespan = pindexLast->GetBlockTime() - pindex->GetBlockTime();' >> src/pow.cpp
echo '    // NOTE: is this accurate? nActualTimespan counts it for (nPastBlocks - 1) blocks only...' >> src/pow.cpp
echo '' >> src/pow.cpp
echo '    int64_t nTargetTimespan = nPastBlocks * params.nPowTargetSpacing;' >> src/pow.cpp
echo '' >> src/pow.cpp
echo '    if (nActualTimespan < nTargetTimespan/3)' >> src/pow.cpp
echo '        nActualTimespan = nTargetTimespan/3;' >> src/pow.cpp
echo '    if (nActualTimespan > nTargetTimespan*3)' >> src/pow.cpp
echo '        nActualTimespan = nTargetTimespan*3;' >> src/pow.cpp
echo '' >> src/pow.cpp
echo '    // Retarget' >> src/pow.cpp
echo '    bnNew *= nActualTimespan;' >> src/pow.cpp
echo '    bnNew /= nTargetTimespan;' >> src/pow.cpp
echo '    if (bnNew > bnPowLimit) {' >> src/pow.cpp
echo '        bnNew = bnPowLimit;' >> src/pow.cpp
echo '' >> src/pow.cpp
echo '    }' >> src/pow.cpp
echo '    return bnNew.GetCompact();' >> src/pow.cpp
echo '}' >> src/pow.cpp
echo '' >> src/pow.cpp
echo '' >> src/pow.cpp


sed -i "s;NY Times 05/Oct/2011 Steve Jobs, Apple’s Visionary, Dies at 56;$PHRASE;" src/chainparams.cpp
# sed -i -e 's+NY[[:space:]]Times[[:space:]]05/Oct/2011[[:space:]]Steve Jobs,[[:space:]]Apple’s[[:space:]]Visionary,[[:space:]]Dies[[:space:]]at[[:space:]]56+Bloomberg 24/Jan/2018 UBSChairmanSaysaMassiveBitcoinCorrectionIsPossible+g' src/chainparams.cpp
sed -i -e 's+consensus.BIP34Height[[:space:]]=[[:space:]]710000;+consensus.BIP34Height = 0;+g' src/chainparams.cpp
sed -i -e 's:fa09d204a83a768ed5a7c8d441fa62f2043abf420cff1226c7b4329aeb9d51cf:0x00:g' src/chainparams.cpp
sed -i -e 's+consensus.BIP65Height[[:space:]]=[[:space:]]918684;+consensus.BIP65Height = 0;+g' src/chainparams.cpp
sed -i -e 's+consensus.BIP66Height[[:space:]]=[[:space:]]811879;+consensus.BIP66Height = 0;+g' src/chainparams.cpp
sed -i -e 's+vSeeds.emplace_back+//vSeeds.emplace_back+g' src/chainparams.cpp
sed -i -e 's+vSeeds.push_back+//vSeeds.push_back+g' src/chainparams.cpp



#mainnet prefixes
sed -i "s|(1,48);|(1,$base58Prefixes_PUBKEY_ADDRESS_MAIN);|g" src/chainparams.cpp
sed -i "s|(1,5);|(1,$base58Prefixes_SCRIPT_ADDRESS_MAIN);|g" src/chainparams.cpp
sed -i "s|(1,50);|(1,$base58Prefixes_SCRIPT_ADDRESS2_MAIN);|g" src/chainparams.cpp
sed -i "s|(1,176);|(1,$base58Prefixes_SECRET_KEY_MAIN);|g" src/chainparams.cpp

#testnet prefixes
sed -i "s|(1,111);|(1,$base58Prefixes_PUBKEY_ADDRESS_TEST);|g" src/chainparams.cpp
sed -i "s|(1,196);|(1,$base58Prefixes_SCRIPT_ADDRESS_TEST);|g" src/chainparams.cpp
sed -i "s|(1,58);|(1,$base58Prefixes_SCRIPT_ADDRESS2_TEST);|g" src/chainparams.cpp
sed -i "s|(1,239);|(1,$base58Prefixes_SECRET_KEY_TEST);|g" src/chainparams.cpp



# add custom DNS seeds to mainnet
cat ../DNSSeedsMain.txt | while IFS= read -r line;
do
  if [ "${line}""X" = "X" ]
  then
    break
  fi
  sed -i "s|\\\"dnsseed.koin-project.com\\\"));|\\\"dnsseed.koin-project.com\\\"));\n        vSeeds.push_back(CDNSSeedData(\\\"${line}\\\", \\\"${line}\\\"));|" src/chainparams.cpp
done

# add custom DNS seeds to testnet
cat ../DNSSeedsTest.txt | while IFS= read -r line;
do
  if [ "${line}""X" = "X" ]
  then
    break
  fi
  sed -i "s|\\\"dnsseed-testnet.thrasher.io\\\",[[:space:]]true));|\\\"dnsseed-testnet.thrasher.io\\\", true));\n        vSeeds.push_back(CDNSSeedData(\\\"${line}\\\", \\\"${line}\\\"));|" src/chainparams.cpp
done


# add custom seed nodes to mainnet
cat ../DomainSeedsMain.txt | while IFS= read -r line;
do
  if [ "${line}""X" = "X" ]
  then
    break
  fi
  sed -i "s|SetRPCWarmupFinished();|connman.AddNode(\\\"${line}\\\");\n    SetRPCWarmupFinished();|" src/init.cpp
  # sed -i "s|ARRAYLEN(pnSeed6_main));|ARRAYLEN(pnSeed6_main));\n        vFixedSeeds.push_back(lookupDomain(\\\"${line}\\\",nDefaultPort));|" src/chainparams.cpp
done

# add custom seed nodes to testnet
cat ../DomainSeedsTest.txt | while IFS= read -r line;
do
  if [ "${line}""X" = "X" ]
  then
    break
  fi
  sed -i "s|ARRAYLEN(pnSeed6_test));|ARRAYLEN(pnSeed6_test));\n        vFixedSeeds.push_back(lookupDomain(\\\"${line}\\\",nDefaultPort));|" src/chainparams.cpp
done



sed -i "s/= 9333;/= $MAINNET_PORT;/" src/chainparams.cpp
sed -i "s/= 19335;/= $TESTNET_PORT;/" src/chainparams.cpp

sed -i "0,/2084524493/s//$MAIN_NONCE/" src/chainparams.cpp
sed -i "0,/293345/s//$TEST_NONCE/" src/chainparams.cpp
sed -i "0,/1296688602, 0/s//1296688602, $REGTEST_NONCE/" src/chainparams.cpp

sed -i "s/1317972665/$MAINNET_GENESIS_TIMESTAMP/" src/chainparams.cpp
sed -i "s/1486949366/$TEST_GENESIS_TIMESTAMP/" src/chainparams.cpp
sed -i "s/1296688602/$REGTEST_GENESIS_TIMESTAMP/" src/chainparams.cpp


sed -i -e "s/0x1e0ffff0/$NBITS/g" src/chainparams.cpp
sed -i -e "s/50 \* COIN/$GENESIS_REWARD/g" src/chainparams.cpp
sed -i -e "s/50 \* COIN/$GENESIS_REWARD/g" src/validation.cpp
sed -i -e "s/2.5 \* 60/$POW_TARGET_SPACING/g" src/chainparams.cpp
sed -i -e "s/840000/$HALVING_INTERVAL/g" src/chainparams.cpp


# change minimum chain work (whole chain)
#mainnet
sed -i "s/0x000000000000000000000000000000000000000000000006805c7318ce2736c0/0x00/" src/chainparams.cpp
#testnet
sed -i "s/0x000000000000000000000000000000000000000000000000000000054cb9e7a0/0x00/" src/chainparams.cpp

#Genesis hash mainnet
# default assume valid
sed -i "s/0x1673fa904a93848eca83d5ca82c7af974511a7e640e22edc2976420744f2e56a/$MAIN_GENESIS_HASH/" src/chainparams.cpp
#asserts
sed -i "s/0x12a765e31ffd4059bada1e25190f6e98c99d9714d334efa41a195a7e7e04bfe2/$MAIN_GENESIS_HASH/" src/chainparams.cpp
sed -i "s/0x97ddfbbae6be97fd6cdf3e7ca13232a3afff2353e29badfab7f73011edd4ced9/$MAIN_MERKLE_HASH/" src/chainparams.cpp


#Genesis hash testnet
# default assume valid
sed -i "s/0x43a16a626ef2ffdbe928f2bc26dcd5475c6a1a04f9542dfc6a0a88e5fcf9bd4c/$TEST_GENESIS_HASH/" src/chainparams.cpp
#asserts
sed -i "s/0x4966625a4b2851d9fdee139e56211a0d88575f59ed816ff5e6a63deb4e3e29a0/$TEST_GENESIS_HASH/" src/chainparams.cpp
sed -i "s/0x97ddfbbae6be97fd6cdf3e7ca13232a3afff2353e29badfab7f73011edd4ced9/$TEST_MERKLE_HASH/" src/chainparams.cpp


#Genesis hash regtest
#asserts
sed -i "s/0x530827f38f93b43ed12af0b3ad25a288dc02ed74d6d7857862df51fc56c416f9/$REGTEST_GENESIS_HASH/" src/chainparams.cpp
sed -i "s/0x97ddfbbae6be97fd6cdf3e7ca13232a3afff2353e29badfab7f73011edd4ced9/$REGTEST_MERKLE_HASH/" src/chainparams.cpp

#ChainTxData
#testnet
#Total number of transaction between genesis and last known timestamp
sed -i "s/8731/0/" src/chainparams.cpp
sed -i "s/1487715270/$TEST_GENESIS_TIMESTAMP/" src/chainparams.cpp
sed -i "s/0\.01/$TEST_ESTIMATED_TRANSACTIONS/" src/chainparams.cpp
#mainnet
#Total number of transaction between genesis and last known timestamp
sed -i "s/9243806/0/" src/chainparams.cpp
sed -i "s/1487715936/$MAINNET_GENESIS_TIMESTAMP/" src/chainparams.cpp
sed -i "s/0\.06/$MAINNET_ESTIMATED_TRANSACTIONS/" src/chainparams.cpp

#comment checkpoints
#mainnet
sed -i "s|(  1500, uint256S|(  0, uint256S|g" src/chainparams.cpp
sed -i "s|0x841a2965955dd288cfa707a755d05a54e45f8bd476835ec9af4402a2b59a2967|$MAIN_GENESIS_HASH|g" src/chainparams.cpp
sed -i "s|(  4032, uint256S|//(  4032, uint256S|g" src/chainparams.cpp
sed -i "s|(  8064, uint256S|//(  8064, uint256S|g" src/chainparams.cpp
sed -i "s|( 16128, uint256S|//( 16128, uint256S|g" src/chainparams.cpp
sed -i "s|( 23420, uint256S|//( 23420, uint256S|g" src/chainparams.cpp
sed -i "s|( 50000, uint256S|//( 50000, uint256S|g" src/chainparams.cpp
sed -i "s|( 80000, uint256S|//( 80000, uint256S|g" src/chainparams.cpp
sed -i "s|(120000, uint256S|//(120000, uint256S|g" src/chainparams.cpp
sed -i "s|(161500, uint256S|//(161500, uint256S|g" src/chainparams.cpp
sed -i "s|(179620, uint256S|//(179620, uint256S|g" src/chainparams.cpp
sed -i "s|(240000, uint256S|//(240000, uint256S|g" src/chainparams.cpp
sed -i "s|(383640, uint256S|//(383640, uint256S|g" src/chainparams.cpp
sed -i "s|(409004, uint256S|//(409004, uint256S|g" src/chainparams.cpp
sed -i "s|(456000, uint256S|//(456000, uint256S|g" src/chainparams.cpp
sed -i "s|(638902, uint256S|//(638902, uint256S|g" src/chainparams.cpp
sed -i "s|(721000, uint256S|//(721000, uint256S|g" src/chainparams.cpp
#testnet
sed -i "s|( 2056, uint256S|(0, uint256S|g" src/chainparams.cpp
sed -i "s|\\\"17748a31ba97afdc9a4f86837a39d287e3e7c7290a08a1d816c5969c78a83289|$TEST_GENESIS_HASH|g" src/chainparams.cpp
sed -i "s|0x17748a31ba97afdc9a4f86837a39d287e3e7c7290a08a1d816c5969c78a83289|$TEST_GENESIS_HASH|g" src/chainparams.cpp
#regtest
sed -i "s|530827f38f93b43ed12af0b3ad25a288dc02ed74d6d7857862df51fc56c416f9|$REGTEST_GENESIS_HASH|g" src/chainparams.cpp
# sed -i "s||//|g" src/chainparams.cpp





#mainnet
sed -i "s|pchMessageStart\[0\] = 0xfb|pchMessageStart[0]  = $MAIN_MESSAGE_S_0|g" src/chainparams.cpp
sed -i "s|pchMessageStart\[1\] = 0xc0|pchMessageStart[1]  = $MAIN_MESSAGE_S_1|g" src/chainparams.cpp
sed -i "s|pchMessageStart\[2\] = 0xb6|pchMessageStart[2]  = $MAIN_MESSAGE_S_2|g" src/chainparams.cpp
sed -i "s|pchMessageStart\[3\] = 0xdb|pchMessageStart[3]  = $MAIN_MESSAGE_S_3|g" src/chainparams.cpp
sed -i "s|(0x04)(0x88)(0xB2)(0x1E)|$MAIN_PREFIX_PUBLIC|g" src/chainparams.cpp
sed -i "s|(0x04)(0x88)(0xAD)(0xE4)|$MAIN_PREFIX_SECRET|g" src/chainparams.cpp

#Testnet
sed -i "s|pchMessageStart\[0\] = 0xfd|pchMessageStart[0]  = $TEST_MESSAGE_S_0|g" src/chainparams.cpp
sed -i "s|pchMessageStart\[1\] = 0xd2|pchMessageStart[1]  = $TEST_MESSAGE_S_1|g" src/chainparams.cpp
sed -i "s|pchMessageStart\[2\] = 0xc8|pchMessageStart[2]  = $TEST_MESSAGE_S_2|g" src/chainparams.cpp
sed -i "s|pchMessageStart\[3\] = 0xf1|pchMessageStart[3]  = $TEST_MESSAGE_S_3|g" src/chainparams.cpp
#testnet and regtest are the same
sed -i "s|(0x04)(0x35)(0x87)(0xCF)|$TEST_PREFIX_PUBLIC|g" src/chainparams.cpp
sed -i "s|(0x04)(0x35)(0x83)(0x94)|$TEST_PREFIX_SECRET|g" src/chainparams.cpp

#Regtest
sed -i "s|pchMessageStart\[0\] = 0xfa|pchMessageStart[0]  = $REGTEST_MESSAGE_S_0|g" src/chainparams.cpp
sed -i "s|pchMessageStart\[1\] = 0xbf|pchMessageStart[1]  = $REGTEST_MESSAGE_S_1|g" src/chainparams.cpp
sed -i "s|pchMessageStart\[2\] = 0xb5|pchMessageStart[2]  = $REGTEST_MESSAGE_S_2|g" src/chainparams.cpp
sed -i "s|pchMessageStart\[3\] = 0xda|pchMessageStart[3]  = $REGTEST_MESSAGE_S_3|g" src/chainparams.cpp


# set minimum difference
sed -i "s|00000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffff|$MIN_DIFF|g" src/chainparams.cpp

# ovverrides difficulty compute algorithm and always return lowest limit
if [ $ALWAYS_MINIMUM_DIFF == "TRUE" ]
then
  sed -i "s|unsigned int nProofOfWorkLimit = UintToArith256(params.powLimit).GetCompact();|unsigned int nProofOfWorkLimit = UintToArith256(params.powLimit).GetCompact();\n    return nProofOfWorkLimit;|g" src/pow.cpp
else
  echo " "
fi


}

whole_stuff
