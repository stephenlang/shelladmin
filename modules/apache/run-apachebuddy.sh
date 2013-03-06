#!/bin/bash 
#
# Install and run apachebuddy.pl 
# 
# Stephen Lang
# Tue Mar  5 23:53:01 EST 2013


# Variables
script=${0##*/}


# Functions

function help { 

cat <<HELP

SYNOPSIS:  ./$script
USAGE EXAMPLE: ./$script
HELP
        exit 0
}


# Sanity checks

if [ ! `whoami` = root ]; then
        echo "Error: Script can only be run as root." >&2
        sleep 2
        exit 1
fi


# Functions

function install_apachebuddy {
	cd /root
	wget --no-check-certificate https://raw.github.com/gusmaskowitz/apachebuddy.pl/master/apachebuddy.pl
	chmod 700 apachebuddy.pl
}


# Run

if [ ! -f /root/apachebuddy.pl ]; then
	install_apachebuddy
fi

/root/apachebuddy.pl
echo "Press any key to continue..."
read -p "$*"
