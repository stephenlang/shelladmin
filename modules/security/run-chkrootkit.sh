#!/bin/bash 
#
# Install and run chrootkit
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

function install_chkrootkit {

	if [ -f /etc/redhat-release ]; then
		yum -y install chkrootkit
	elif [ -f /etc/lsb-release ]; then
		aptitude update
		aptitude -y install chkrootkit
	else
		echo "Unsupported OS, aborting..."
		exit 1
	fi

	if [ ! -f /usr/sbin/chkrootkit ]; then
		echo "chkrootkit failed to install.  Please"
		echo "install manually and rerun.  If this"
		echo "is running a Red Hat Clone distro, "
		echo "you can get this from the EPEL Repos."
		echo "http://fedoraproject.org/wiki/EPEL"
		exit 1
	fi
}


# Run

if [ ! -f /usr/sbin/chkrootkit ]; then
	install_chkrootkit
fi

chkrootkit
echo "Press any key to continue..."
read -p "$*"
