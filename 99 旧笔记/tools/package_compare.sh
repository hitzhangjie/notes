#!/bin/bash 

path_f1='/home/zhangjie/Desktop/former'
path_f2='/home/zhangjie/Desktop/now'

lines=`cat $path_f2 | wc -l`

for line in `cat $path_f1 | awk '{print $1}'`
do
	count='1'
	exist='0'
	
	while [ $count -le $lines -a $exist -eq 0 ]
	do
		if [ $line == `head -n $count $path_f2 | tail -n 1 | awk '{print $1}'` ]
		then
			exist='1'
		else
			count=$[$[count]+1]
		fi
	done

	if [ $exist -eq 0 ]
	then		
		echo $line >> non-exist
		echo "$line deinstall"
	fi
	
done


