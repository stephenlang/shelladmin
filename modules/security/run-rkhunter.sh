#!/bin/bash 
#
# Install and run rkhunter
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

function install_rkhunter {
	if [ -f /etc/redhat-release ]; then
		yum -y install rkhunter
	elif [ -f /etc/lsb-release ]; then
		aptitude update
		aptitude -y install rkhunter	
	fi

	if [ ! -f /usr/bin/rkhunter ]; then
		echo "RKHunter failed to install.  Please"
		echo "install manually and rerun."
		exit 1
	fi
}


# Run

if [ ! -f /usr/bin/rkhunter ]; then
	install_rkhunter
fi

rkhunter --update; rkhunter --propupd; rkhunter -sk -c
if [ -f /etc/redhat-release ]; then
	echo "--"
	echo ""
	echo "cat /var/log/rkhunter/rkhunter.log |grep -i warning"
	cat /var/log/rkhunter/rkhunter.log |grep -i warning
elif [ -f /etc/lsb-release ]; then
	echo "--"
	echo ""
	echo "cat /var/log/rkhunter.log |grep -i warning"
	cat /var/log/rkhunter.log |grep -i warning
fi

echo "Press any key to continue..."
read -p "$*"
