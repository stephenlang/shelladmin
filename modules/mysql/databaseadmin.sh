#!/bin/bash 
#
# Add / remove MySQL database
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

if [ ! -f /root/.my.cnf ]; then
	echo "Cannot detect MySQL Root password.  Please"
	echo "create /root/.my.cnf and re-run operation."
fi

if [ ! -d $logs ]; then
        mkdir -p $logs
fi


# Functions

function help {

cat <<HELP

SYNOPSIS:  ./$script [option]... [database]... 
USAGE EXAMPLE: ./$script -c exampledb exampleuser (creates database)
               ./$script -d exampledb (deletes database)
               ./$script -l null (list databases)
HELP
        exit 0
}

function add_database {
	dbpass=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c15`
	echo "create database $dbname;" | mysql
	echo "grant all on $dbname.* to '$dbuser'@'%' identified by '$dbpass';" | mysql 
	echo "flush privileges;" | mysql


# Generate Setup Letter

cat << EOF > /tmp/db_$dbname.txt

---------------------------------------------------------------
Database Information
---------------------------------------------------------------

Database Host: localhost
Database Name: $dbname
Database User: $dbuser
Database Pass: $dbpass

---------------------------------------------------------------

EOF

less /tmp/db_$dbname.txt
rm /tmp/db_$dbname.txt
}

function drop_database {
        echo "drop database $dbname ;" |mysql
        for i in `echo "use mysql; select User from db where Db='$dbname' ;" | mysql`; do
        echo "use mysql; delete from user where user='$i';" | mysql 
        echo "use mysql; delete from db where User='$i' and Db='$dbname';" |mysql;
        done
        echo "flush privileges;" |mysql
}

function list_database {
        echo "show databases;" |mysql |grep -v "mysql" |grep -v "information_schema" |grep -v Database 
}


# Main

case $1 in
    -c)	if [ -z "$1" -o -z "$2" -o -z "$3" ]; then
        	help
        fi
	dbname=$2
	dbuser=$3
	add_database
        ;; 
    -d) dbname=$2
	if [ -z "$2" ]; then
       		help
	fi
	drop_database
        ;; 
    -l) list_database 
        ;;
     *) help ;exit 1;;
esac
