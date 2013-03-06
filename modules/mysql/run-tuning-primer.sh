#!/bin/bash 
#
# Install and run tuning-primer.sh
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

if [ ! -f `which bc` ]; then
        echo "Required program not install 'bc'.  Would"
        echo "you like to install it now?"
	echo ""
	echo -n "Type:  y/n:  "
	read answer
	if [ $answer = y ]; then
		if [ -f /etc/redhat-release ]; then
			yum -y install bc
		elif [ -f /etc/lsb-release ]; then
			aptitude install bc
		else
			echo "No changes made"
			sleep 2
			exit 1
		fi
	fi
fi


# Functions

function help {

cat <<HELP

SYNOPSIS:  ./$script
USAGE EXAMPLE: ./$script
HELP
        exit 0
}

function install_tuning-primer {
	cd /root
	wget http://www.day32.com/MySQL/tuning-primer.sh
	chmod 700 tuning-primer.sh
}


# Run

if [ ! -f /root/tuning-primer.sh ]; then
	install_tuning-primer
fi

chmod 755 /root/tuning-primer.sh
/root/tuning-primer.sh
echo "Press any key to continue..."
read -p "$*"
