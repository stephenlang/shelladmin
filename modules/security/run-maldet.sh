#!/bin/bash 
#
# Install and run maldet
#
# Stephen Lang
# Tue Mar  5 23:53:01 EST 2013


# Variables
script=${0##*/}


# Sanity checks

if [ ! `whoami` = root ]; then
        echo "Error: Script can only be run as root." >&2
        sleep 2
        exit 1
fi


# Functions

function help {

cat <<HELP

SYNOPSIS:  ./$script
USAGE EXAMPLE: ./$script
HELP
        exit 0
}

function install_maldet {

	wget http://www.rfxn.com/downloads/maldetect-current.tar.gz
	tar -xf maldetect-current.tar.gz
	cd maldetect-*
	./install.sh

	if [ ! -f /usr/local/sbin/maldet ]; then
		echo "Maldetect failed to install.  Please"
		echo "install manually and rerun.  URL below:"
		echo "http://www.rfxn.com/projects/linux-malware-detect/"
		sleep 5
		exit 1
	fi
}


# Run

default=/var/www
echo -n "Type the directory you would like to scan [/var/www] : "
read answer

if [ -n "$answer" ]; then
        directory="$answer"
else
        directory="$default"
fi


if [ ! -f /usr/local/sbin/maldet ]; then
	install_maldet
else
	maldet -d
fi

maldet -u
maldet --scan-all $directory
echo "Press any key to continue..."
read -p "$*"
