#!/bin/bash
SEND_TO="EUd9re5NqzszxwtEQVGaxrcK2sWQdS3A64"
SEND_AMOUNT="0.001"
REPEAT_TIMES=1000
START=1
echo "Countdown"

for (( c=$START; c<=$REPEAT_TIMES; c++ ))
do
	rtidcoin-cli sendtoaddress ${SEND_TO} ${SEND_AMOUNT}
done
exit 0
