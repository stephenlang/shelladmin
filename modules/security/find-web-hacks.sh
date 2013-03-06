#!/bin/bash 
#
# Dirty script for finding common web hacks within Apache sites
#
# Stephen Lang
# Tue Mar  5 23:53:01 EST 2013


# variables
patterns="passthru|shell_exec|system|phpinfo|base64_decode|popen|exec|proc_open|pcntl_exec|python_eval|fopen|fclose|readfile"

if [ -f /etc/redhat-release ]; then
	apache=httpd
elif [ -f /etc/lsb-release ]; then
	apache=apache2
else echo "Unsupported OS, aborting..."
	sleep 2
	exit 1
fi


# Warning
echo "This script will return many false positives."
echo "You should review each result to see if it looks"
echo "suspicious, or if it is part of your code set."
echo ""
echo "This could take some time to run, do you"
echo "wish to proceed?"
echo ""
echo -n "Type:  y/n:  "
read answer
if [ ! $answer = y ]; then
	echo "Aborting..."
	sleep 2
	exit 1
fi


# Generate sites documentroot's:
$apache -S |grep port | cut -d\( -f2 | sed -e 's/:1)//g' > vhost.tmp
for i in `cat vhost.tmp`; do egrep DocumentRoot $i | head -1 | awk '{print $2}'; done > docroot.tmp


# Scan 
for i in `cat docroot.tmp`; do egrep -R "($patterns)" $i; done |less
rm -f docroot.tmp
rm -f vhost.tmp
