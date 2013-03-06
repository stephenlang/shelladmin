#!/bin/bash 
#
# Install and run mysqltuner.pl
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

function install_mysqltuner {
	cd /root
	wget --no-check-certificate https://raw.github.com/rackerhacker/MySQLTuner-perl/master/mysqltuner.pl
	chmod 700 mysqltuner.pl
}


# Run

if [ ! -f /root/mysqltuner.pl ]; then
	install_mysqltuner
fi

/root/mysqltuner.pl
echo "Press any key to continue..."
read -p "$*"
