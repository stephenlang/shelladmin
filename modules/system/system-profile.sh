#!/bin/bash
#
# Generates a basic system profile
#
# Stephen Lang
# Tue Mar  5 23:53:01 EST 2013


# Server Information

hostname=`hostname`
public_ip=`ifconfig eth0 |grep "inet addr:" | awk '{print $2}' | cut -d\: -f2`
private_ip=`ifconfig eth1 |grep "inet addr:" | awk '{print $2}' | cut -d\: -f2`

if [ -f /etc/redhat-release ]; then
	os=`cat /etc/redhat-release`
elif [ -f /etc/lsb-release ]; then
	os=`cat /etc/lsb-release |grep DESC |cut -d\= -f2 |sed -e 's/"//g'`
else
	echo "Unsupported OS, exiting"
fi

arch=`uname -m`
kernel=`uname -r`
cpu_type=`cat /proc/cpuinfo |grep "model name" |cut -d\: -f2`
cpu_speed=`cat /proc/cpuinfo |grep "cpu MHz" |cut -d\: -f2`
mem_total=`free -m | grep "Mem:" | awk '{print $2}'`
swap_total=`free -m | grep "Swap:" | awk '{print $2}'`


# Partition Layout

df=`df -h`


# Memory Usage

mem_percent_used=`/usr/bin/free -m | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d\. -f1`
swap_percent_used=`/usr/bin/free -m | grep Swap | awk '{print $3/$2 * 100.0}' | cut -d\. -f1`
apache_total_memory=`ps -ef |grep apache |grep -v ^root | awk '{print $2}' | xargs pmap -d |grep ^mapped: |awk '{sum += $4} END {print sum/1024}'`
mysql_total_memory=`ps -ef |grep mysql |grep -v ^root | awk '{print $2}' | xargs pmap -d |grep ^mapped: | awk '{sum += $4} END {print sum/1024}'`


# Networking Information 

for i in `netstat -natp |grep LISTEN | awk '{print $4}' | sed -e 's/:://g' | cut -d\: -f2`; do echo -n $i,\ ; done > listening-ports.out
listening_ports=`cat listening-ports.out`
total_conn=`netstat -nat |wc -l`


# Apache Information

if [ -f /etc/redhat-release ]; then
	apache_version=`httpd -v |grep version | cut -d\: -f2`
	total_vhosts=`httpd -S | grep namevhost | wc -l`
	apache_conn=`ps waux |grep apache | wc -l`
	apache_max=`cat /etc/httpd/conf/httpd.conf |grep MaxClient | grep -v \# |head -1 |awk '{print $2}'`
elif [ -f /etc/lsb-release ]; then
	apache_version=`apache2 -v |grep version | cut -d\: -f2`
	total_vhosts=`apache2 -S | grep namevhost | wc -l`	
	apache_conn=`ps waux |grep apache | wc -l`
	apache_max=`cat /etc/apache2/apache2.conf |grep MaxClient | grep -v \# |head -1 |awk '{print $2}'`
else
        echo "Unsupported OS, exiting"
fi


# MySQL Information

mysql_version=`mysql -V | awk '{print $5}' |sed -e 's/,//g'`
total_databases=`echo "show databases;" | mysql | grep -v Database |grep -v information_schema |grep -v performance_schema | wc -l`
mysql_conn=`echo "show processlist;" | mysql | grep -v State | wc -l`
mysql_max=`echo "show variables;" | mysql | grep max_connections | awk '{print $2}'`


# Report

cat << EOF > /tmp/system-profiler.txt

---------------------------------------------------------------
                  Server Information
---------------------------------------------------------------

Hostname:          $hostname
IP Address:        $public_ip / $private_ip
Operating System:  $os
Arch:              $arch
Kernel:            $kernel
CPU Type:         $cpu_type $cpu_speed
Memory Installed:  $mem_total MB
Swap Total:	   $swap_total MB


---------------------------------------------------------------
                  Partition Layout
---------------------------------------------------------------

$df


---------------------------------------------------------------
                  Memory Usage
---------------------------------------------------------------

Total Memory:  		$mem_total MB
Memory In Use: 		$mem_percent_used%
Total Swap:    		$swap_total MB
Swap In Use:   		$swap_percent_used%

Apache Total Memory:   	$apache_total_memory MB
MySQL Total Memory     	$mysql_total_memory MB


---------------------------------------------------------------
                  Network Information
---------------------------------------------------------------

Listening Ports:  	$listening_ports
Total Connections:  	$total_conn


---------------------------------------------------------------
                  Apache Statistics
---------------------------------------------------------------

Apache Version:        $apache_version
Virtual Hosts:  	$total_vhosts 
Connections Used:  	$apache_conn/$apache_max 


---------------------------------------------------------------
                  MySQL Statistics
---------------------------------------------------------------

MySQL Version:		$mysql_version
Total Databases:	$total_databases
Connections Used:	$mysql_conn/$mysql_max

---------------------------------------------------------------


EOF
cat /tmp/system-profiler.txt
rm /tmp/system-profiler.txt 

# Clean up
rm listening-ports.out

echo "Press any key to continue..."
read -p "$*"
