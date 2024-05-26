#!/bin/bash
#$$ PID of shell itself
#$! PID of last process run by shell
#$? return value of last command
#$- display of flags set by command 'Set'
#$* parameter list
#$@ parameter list
#$# number of parameters following filename
#$0 file name
#$1 first parameter following file name
#$2 second ...

max_brightness=`cat /sys/class/backlight/intel_backlight/max_brightness`

if [ $# -eq 0 ]
then 
    cur_brightness=`cat /sys/class/backlight/intel_backlight/brightness`
	brightness=$(awk "BEGIN{print 100*$cur_brightness/$max_brightness}");
	echo $brightness
elif [ $# -eq 1 ]
then
	if [ $1 -le 100 -a $1 -ge 1 ]
	then
		brightness=$(awk "BEGIN{print $1/100*$max_brightness}")
		#echo $brightness
		echo $brightness > /sys/class/backlight/intel_backlight/brightness
	elif [ $1 -gt 100 ]
	then
		brightness=$(awk "BEGIN{print 1*$max_brightness")
		#echo $brightness 
		echo $brightness > /sys/class/backlight/intel_backlight/brightness
	else
		brightness=$(awk "BEGIN{print 0.01*$max_brightness}")
		#echo $brightness
		echo $brightness > /sys/class/backlight/intel_backlight/brightness
	fi
fi
