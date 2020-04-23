#!/bin/bash

#******************************************** SCRIPT SETTINGS ***************************************
# This variable affects 02-generate-code.sh step
# Ovverrides difficulty compute algorithm and always return lowest limit (Just for test purposes. Please do not set this parameter to TRUE if you do not know what are you doing.)
export ALWAYS_MINIMUM_DIFF="FALSE"
# This variable affects 00-install-dependencies.sh and 03-compilation.sh steps
# Whether building on debian->TRUE or on ubuntu->FALSE
export DEBIAN="FALSE"
# This variable affects 00-install-dependencies.sh and 03-compilation.sh steps ... crosscompilation for windows always compile with gui
# Whether build with gui
export GUI="TRUE"
#*****************************************************************************************************

#******************************* COIN SETTINGS *******************************************************
# Change stuff from about
export COIN_GITHUB="https://github.com/RtidCoin/rtidcoin"
export URL_WEBSITE="https://rtid-platform.web.id"
export FROM_YEAR="2019"
export TO_YEAR="2020"
export COIN_DOMAIN="rtid-platform.web.id"

export COIN_NAME="Rtidcoin"
export COIN_UNIT="RTID"
# Link to the version used in the script
export RELEASE_URL="https://github.com/litecoin-project/litecoin/archive/v0.14.2.tar.gz"
# It’s traditional to pick a newspaper headline for the day of launch, but you don’t have to.
# Whatever you use, keep it short. If it’s OVER 90 CHARACTERS or so the block will FAIL a length
# check that’s supposed to prevent denial-of-service attacks from people attaching big data to transactions.
export PHRASE="22/April/2020 HelpPeopleInTheWorldFromCoronaVirus"
export MAINNET_PORT="2020"
export TESTNET_PORT="20205"
# https://www.epochconverter.com/
# Should be gradual (first mainnet, then testnet, then regtest)
export MAINNET_GENESIS_TIMESTAMP="1587496773"
export TEST_GENESIS_TIMESTAMP="1587496774"
export REGTEST_GENESIS_TIMESTAMP="1587496775"

# Deployment time deadline of BIP68, BIP112, and BIP113 and SegWit (BIP141, BIP143, and BIP147)
# Is set ot MAINNET_GENESIS_TIMESTAMP + 34 days
# export DEPLOYMENT_CSV_SEGWIT="$(( $MAINNET_GENESIS_TIMESTAMP + 3000000 ))"

# Minimum fee .... Amount which you can send can`t be smaller than that [Satoshis]
export MIN_FEE="0"
# Fallback fee [Satoshis]
# If fee estimation does not have enough data to provide estimates, use this fee instead.
# Has no effect if not using fee estimation
# Override with -fallbackfee=<amount>
export DEFAULT_FALLBACK_FEE="0"
# -maxtxfee default [satoshis]
# You can use coin contant for coin > satoshis transfer
export DEFAULT_TRANSACTION_MAXFEE="100 * COIN"
# Discourage users to set fees higher than this amount [satoshis] per kB
export HIGH_TX_FEE_PER_KB="10 * COIN"
# maxtxfee will warn if called with a higher fee than this amount [in satoshis]
export HIGH_MAX_TX_FEE="10 * HIGH_TX_FEE_PER_KB"

# Genesis block difficulty
# Note NBITS is in short difficulty encoding
# https://bitcoin.stackexchange.com/questions/30467/what-are-the-equations-to-convert-between-bits-and-difficulty
# first two numbers * 2 = number of positions                (maximum 0x20 = 64 positions)
# last six numbers = difficulty prefix
# please do not set NBITS greater than MIN_DIFF
#
# example:
# 0x1d00ffff -> 0x00ffff0000000000000000000000000000000000000000000000000000
# 0x20000fff -> 0x000fff0000000000000000000000000000000000000000000000000000000000          (0x20 = 64 positions    and   000fff = prefix )
# 0x20000fff is blocktime under the minute on single i7 core with yescryptR16
export NBITS="0x20000fff"

# Minimum difficulty (but maximal threshold)
export MIN_DIFF="000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
# Block time
# "minutes * 60"
export POW_TARGET_SPACING="1 * 60"
# Genesis reward
# must be exactly this format "x * COIN"
export GENESIS_REWARD="25 * COIN"

# https://en.bitcoin.it/wiki/Controlled_supply
export HALVING_INTERVAL="1000000"

# Maximal amount. Coin core use it just for check
# MAX_MONEY
# No amount larger than this (in satoshi) is valid.
# Note that this constant is *not* the total money supply, which in Bitcoin
# currently happens to be less than 21,000,000 BTC for various reasons, but
# rather a sanity check. As this sanity check is used by consensus-critical
# validation code, the exact value of the MAX_MONEY constant is consensus
# critical; in unusual circumstances like a(nother) overflow bug that allowed
# for the creation of coins out of thin air modification could lead to a fork.
#
# Recommended to set as half of the whole coin supply
export MAX_MONEY="50000000"

# How much blocks before coinbase (mined) transaction could be spent
export COINBASE_MATURITY="100"

# Block size in MB (without SegWit...). With SegWit approximately 4*MAX_BLOCK_BASE_SIZE
# https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki
export MAX_BLOCK_BASE_SIZE_MB="1"

# Mainnet estimated transactions per second
export MAINNET_ESTIMATED_TRANSACTIONS="0.01"
# Testnet estimated transactions per second
export TEST_ESTIMATED_TRANSACTIONS="0.001"


# http://dillingers.com/blog/2015/04/18/how-to-make-an-altcoin/  search for  'The Key Prefixes'
# https://en.bitcoin.it/wiki/List_of_address_prefixes  Table of values
# base58Prefixes[PUBKEY_ADDRESS], base58Prefixes[SCRIPT_ADDRESS], base58Prefixes[SCRIPT_ADDRESS2], base58Prefixes[SECRET_KEY]
export base58Prefixes_PUBKEY_ADDRESS_MAIN="60"
export base58Prefixes_SCRIPT_ADDRESS_MAIN="102"
export base58Prefixes_SCRIPT_ADDRESS2_MAIN="92"
export base58Prefixes_SECRET_KEY_MAIN="205"

export base58Prefixes_PUBKEY_ADDRESS_TEST="122"
export base58Prefixes_SCRIPT_ADDRESS_TEST="105"
export base58Prefixes_SCRIPT_ADDRESS2_TEST="127"
export base58Prefixes_SECRET_KEY_TEST="206"



# BIP32 extended key prefixes
# there are certain rules first two positions must be the same within the net (mainnet/testnet), the last last two positions must differ within the net
# PUBLIC_PREFIX represents base58Prefixes[EXT_PUBLIC_KEY], PRIVATE_PREFIX represents base58Prefixes[EXT_SECRET_KEY]
# http://dillingers.com/blog/2015/04/18/how-to-make-an-altcoin/  also search for  'The Key Prefixes'
# https://bitcoin.stackexchange.com/questions/28380/i-want-to-generate-a-bip32-version-number-for-namecoin-and-other-altcoins
# Valid values are: 123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz
# !!!  0 (zero), O (Capital o), l (lower case L), I (capital i) are ommited!!!!

# EXT_SECRET_KEY, EXT_PUBLIC_KEY # Network                 : Prefixes
# ----------------------------------------------------------------------
# 0x0488ADE4,     0x0488B21E     # BTC  Bitcoin    mainnet : xprv / xpub
# 0x04358394,     0x043587CF     # BTC  Bitcoin    testnet : tprv / tpub
# 0x019D9CFE,     0x019DA462     # LTC  Litecoin   mainnet : Ltpv / Ltub
# 0x0436EF7D,     0x0436F6E1     # LTC  Litecoin   testnet : ttpv / ttub
# 0x02FE52F8,     0x02FE52CC     # DRK  Darkcoin   mainnet : drkv / drkp
# 0x3A8061A0,     0x3A805837     # DRK  Darkcoin   testnet : DRKV / DRKP
# 0x0488ADE4,     0x0488B21E     # VIA  Viacoin    mainnet : xprv / xpub
# 0x04358394,     0x043587CF     # VIA  Viacoin    testnet : tprv / tpub
# 0x02FD3955,     0x02FD3929     # DOGE Dogecoin   mainnet : dogv / dogp
# 0x0488ADE4,     0x0488B21E     # VTC  Vertcoin   mainnet : vtcv / vtcp
# 0x02CFBF60,     0x02CFBEDE     # BC   Blackcoin  mainnet : bcpv / bcpb
# 0x03A04DB7,     0x03A04D8B     # MEC  Megacoin   mainnet : mecv / mecp
# 0x0488ADE4,     0x0488B21E     # MYR  Myriadcoin mainnet : myrv / myrp
# 0x0488ADE4,     0x0488B21E     # UNO  Unobtanium mainnet : unov / unop
# 0x037A6460,     0x037A689A     # JBS  Jumbucks   mainnet : jprv / jpub
# 0x0488ADE4,     0x0488B21E     # MZC  Mazacoin   mainnet : xprv / xpub

export PUBLIC_PREFIX_MAIN="rcpb"
export PRIVATE_PREFIX_MAIN="rcpv"
export PUBLIC_PREFIX_TEST="rtpb"
export PRIVATE_PREFIX_TEST="rtpv"
# **************************************************************************************************
