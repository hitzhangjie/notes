#!/bin/bash
# rsstail script based on app 'rsstail'

SRC=/home/zhangjie/.rss
NUM=`cat ${SRC} | /usr/bin/wc -l`

COUNT=0

echo "**********************  RSS  ************************"
for line in `cat ${SRC}`
do
	COUNT=$[$[COUNT]+1]
	remainder=$[$[COUNT]%2]
	if [ $remainder -eq 1 ]
	then
		echo "$[$[$[COUNT]+1]/2] : ${line}"
		
	fi
done
echo "**********************  RSS  ************************"

CYCLE=true
while [ $CYCLE ]
do
	if [ ! $COUNT -eq 0 ]
	then
		echo "____________________________"
		echo -n " please choose (number) : "
		read CHOICE
		echo "____________________________"

		if [ $CHOICE -gt $[$[COUNT]/2] -o $CHOICE -le 0 ]
		then
			echo "invalid choice ! try again : "
		else	
			# CHOICE,calculate matched url
			URL=$[$[CHOICE]*2]
			url=`cat ${SRC} | head -n ${CHOICE} | tail -n 1 | cut -f 2`			
		        # echo "url is : $url"
			echo "____________________________"
			echo -n "titled or detailed ? : "
			read OPTION
			echo "____________________________"
	
			if [ "$OPTION" != "d" ]
			then
				/usr/bin/rsstail -u $url &
				sleep 5s
				#echo "$OPTION != d"
				OPTION=
			else
				/usr/bin/rsstail -c -d -H -Z xxxxx -u $url &
				sleep 5s
				#echo "$OPTION == d"
				OPTION=
			fi
		fi
	else
		echo "there's no candidated rss sources !"
		CYCLE=false
	fi
done

echo "press any key to quit !"
read

exit


