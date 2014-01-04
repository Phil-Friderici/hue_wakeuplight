## Hue WakeUpLight

This script uses my hue_bashlibrary (https://github.com/markusproske/hue_bashlibrary) and simulates a beautiful sunrise in your sleeping room. It starts with a very warm white at low brightness ("glowing white") and for the first 10 minutes, the brightness increases slowly, then for another 10 minutes the increase gains speed. The last 10 minutes the brightness remains and the color temperate changes. After 30 minutes, the sunrise ends and the lights flash 2 times. After a grace period of 5 minutes the lights flash again. Finally, 25 minutes later the lights are turned off automatically.  


## Getting started

1. Check if your system has curl and cron/crontab installed (if not, see below)
2. Download hue_bashlibrary.sh and hue_wakeup.sh
3. Edit the file hue_wakeup.sh and change the path to the hue_bashlibrary.sh (use the absolute path!), the IP of your hue bridge and the lights to be controlled
4. Link the script to your hue bridge: "./hue_wakeup.sh link"
5. Run "./hue_wakeup.sh" to test, if it does not work, enable logging in the script to find out what is going wrong (and see hints below)
6. Set an alarm using crontab: type "sudo crontab -e" in your Terminal and in the file enter the following line and then save the file: "30 7 * * * /home/pi/wakeup.sh >>/home/pi/log_wakeup.txt 2>&1"

This means: every morning at 7:30 the script /home/pi/wakeup.sh will be executed. Any output of the script will be stored in a logfile named /home/pi/log_wakeup.txt. To list your alarms, type sudo crontab -l. Need different alarm times for different days? No problem, learn more about crontab here: http://unixhelp.ed.ac.uk/CGI/man-cgi?crontab+5.


## Not working?

Download hue_demo.sh from https://github.com/markusproske/hue_bashlibrary, follow the instructions there and try to get familiar with the hue_bashlibrary. If this works, use the knowledge acquired to get the WakeUpLight running. 

**Common pitfalls:**
- check the IP of your hue bridge, you need to set this in hue_wakeup.sh (and demo.sh)
- link the script with your bridge with "./hue_wakeup.sh link" (or "./demo.sh link"), the result has to be a "success"
- use an absolute (and the correct) path to the hue_bashlibrary in hue_wakeup.sh (or demo.sh)


Missing curl or cron/crontab? Install it and use google to find out the best way to install on your specific system. On many systems "sudo apt-get install xyz" will do the job nicely.


## Settings and main section of the code

**Configuration settings**
```bash
source /home/pi/hue_bashlibrary.sh			# if started with a cronjob, the full path is needed here


# Mind the gap: do not change the names of these variables, the bash_library needs those...
ip='10.0.1.8'								# IP of hue bridge, enter your bridge IP here!
devicetype='raspberry'						# Link with bridge: type of device
username='wakeuplight'						# Link with bridge: username / app name (min 10 characters)
loglevel=2									# 0 all logging off, # 1 gossip, # 2 verbose, # 3 errors


# Variables of this scripts
lights='1 2'								# Define the lights you want to use, e.g. '3' or '3 4' or '3 4 7 9'
```

**Main sunrise code - make your own sunrise just by changing a few numbers :)**
```bash
...
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
...
```