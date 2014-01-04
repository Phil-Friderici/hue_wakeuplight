#!/bin/bash

# Hue WakeUpLight, version 1.0
# Written 2013 by Markus Proske, released under GNU GENERAL PUBLIC LICENSE v2, see LICENSE 
# Google+: https://plus.google.com/+MarkusProske
# Github: https://github.com/markusproske
# -----------------------------------------------------------------------------------------


# Note: the library relies on curl to be installed on your system.
# Type which curl or curl --help in your Terminal to see if it is installed
# If not, install with sudo apt-get install curl 


# CONFIGURATION
# -----------------------------------------------------------------------------------------

# import my hue bash library

# source hue_bashlibrary.sh					# works only if you call from command line in same directory
source /home/pi/hue_bashlibrary.sh			# if started with a cronjob, the full path is needed here


# Mind the gap: do not change the names of these variables, the bash_library needs those...
ip='10.0.1.8'								# IP of hue bridge, enter your bridge IP here!
devicetype='raspberry'						# Link with bridge: type of device
username='wakeuplight'						# Link with bridge: username / app name (min 10 characters)
loglevel=2									# 0 all logging off, # 1 gossip, # 2 verbose, # 3 errors


# Variables of this scripts
lights='1 2'								# Define the lights you want to use, e.g. '3' or '3 4' or '3 4 7 9'




# PROGRAM FUNCTIONS
# -----------------------------------------------------------------------------------------

function usage {
	# cmdname is defined in the library
	echo "Usage: $cmdname [link | unlink | discover | config]"
}




# MAIN
# -----------------------------------------------------------------------------------------

# store name of command for usage and log
# cmdname is defined in the library
cmdname=`basename "$0"`


# very simple argument processing
if [[ $# == 1 ]]
	then 
	# valid number of arguments
	if [[ $1 == "link" ]]
	then
		bridge_link
	elif [[ $1 == "unlink" ]]
	then
		bridge_unlink
	elif [[ $1 == "config" ]]
	then	
		bridge_config
	elif [[ $1 == "discover" ]]
	then
		bridge_discover
	else
		usage	
	fi
	
	echo		# force new line
	exit
else 
	if (( $# > 1 )) 
	then
		# more than one argument, show usage
		usage
		echo
		exit
	fi
fi 


# no arguments

log 2 "WakeUpLight started (lights: $lights)."

# we start with mired 500 (2000K) and minimum brightness
hue_on_mired_brightness 500 0 $lights

# 20min of sunrise, color temperature remains warm at mired 500, just the brightness increases
# Sunrise is not linear, therefore the first 10min have less change in brightness (0 to 80) than the second 10min (80 to 240)
# The lights are modified every 30 seconds to make smooth changes
for i in `seq 1 20`;
do
	sleep 30
	
	let brightness=$i*4
	hue_setstate_brightness $brightness $lights
done
for i in `seq 1 20`;
do
	sleep 30
	
	let brightness=80+$i*8
	hue_setstate_brightness $brightness $lights
done

# 10min of sunrise where the color temperature changes from warm to cooler, without any change in brightness
for i in `seq 1 20`;
do
	sleep 30
	
	let mired=500-$i*10	
	hue_setstate_mired $mired $lights
done


# flash for two seconds
hue_alert "on" $lights
sleep 2
hue_alert "off" $lights

# wait 5 minutes and flash again for two seconds
sleep 300
hue_alert "on" $lights
sleep 2
hue_alert "off" $lights

# finally turn off after another 25 minutes
sleep 1500
hue_onoff "off" $lights

log 2 "WakeUpLight finished, lights turned off."
