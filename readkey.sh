#!/bin/bash
# 7 8 9 10 11
key=""
cntr=0
cat $1 | while read line
do
   cntr=$((cntr+1))
   if [ "$cntr" -eq "7" ] || [ "$cntr" -eq "8" ] || [ "$cntr" -eq "9" ] || [ "$cntr" -eq "10" ] || [ "$cntr" -eq "11" ]; then
	key=${key}${line}
   	#echo $line
   fi
   if [ "$cntr" -eq "12" ]; then
	echo ${key//:}
   fi 
done



