#!/bin/sh 
#
# shelladmin menu system
#
# Stephen Lang
# Tue Mar  5 23:51:02 EST 2013


main() {

bold=`tput smso`
offbold=`tput rmso`
clear
######################################
######################################
cat <<EOI

${bold}\
  shelladmin Management Console  \
${offbold}

  1)  Web Administration 
  2)  MySQL Administration
  3)  System Administration
  4)  Security Administration

  5)  Quit and Disconnect

EOI

echo "Please select an option:  "
read _select

case "$_select" in

#########################################
#########################################

[1]*)
clear
cat <<EOI

${bold}\
  shelladmin Management Console   \
${offbold}

  1)  Create Domain
  2)  List Domains
  3)  Performance Recommendations - apachebuddy.pl

  4)  Back to main menu

EOI

echo -n "Please select an option:  "
read answer

case "$answer" in 

[1]*) echo -n "Enter new domain:  "
      read domain
      echo -n "Enter desired sftp username:  "
      read sftp
modules/apache/add_vhost.sh $domain $sftp 
main
;;

[2]*) if [ -f /etc/redhat-release ]; then
      	httpd -S | less && main
      elif [ -f /etc/lsb-release ]; then
	apache2 -S | less && main
      fi
;;

[3]*) modules/apache/run-apachebuddy.sh
main
;;

*) main
;;
esac
;;
#########################################
#########################################
[2]*) 
clear
cat <<EOI

${bold}  shelladmin Management Console   ${offbold}

  1)  Create Database
  2)  List Databases
  3)  Delete Database
  4)  Performance Recommendations - tuning-primer.sh
  5)  Performance Recommendations - mysqlprimer.pl 
  6)  Back to main menu

EOI

echo -n "Please select an option:  "
read answer

case "$answer" in
[1]*)  echo -n "Enter new database name:  "
       read dbname
       echo -n "Enter new database user name:  "
       read dbuser
       modules/mysql/databaseadmin.sh -c $dbname $dbuser
       main
;;

[2]*)  modules/mysql/databaseadmin.sh -l | less
       main
;;

[3]*)  modules/mysql/databaseadmin.sh -l
       echo "--"
       echo -n "Enter the database you wish to delete:  "
       read dbname
       modules/mysql/databaseadmin.sh -d $dbname
       main
;;


[4]*)  modules/mysql/run-tuning-primer.sh
       main
;;

[5]*)  modules/mysql/run-mysqltuner.sh
       main
;;

*) main
;;
esac
;;
#########################################
#########################################

[3]*)
clear
cat <<EOI

${bold}  shelladmin Management Console   ${offbold}

  1)  System Profile
  
  2)  Back to main menu

EOI

echo -n "Please select an option:  "
read answer

case "$answer" in
[1]*)  modules/system/system-profile.sh
       main
;;

*) main
;;
esac
;;

#########################################
#########################################

[4]*)
clear
cat <<EOI

${bold}  shelladmin Management Console   ${offbold}

  1)  Install/Run Chkrootkit
  2)  Install/Run RKhunter

  3)  Install/Run Maldet
  4)  Manual Check For Malware On Sites

  5)  Back to main menu

EOI

echo -n "Please select an option:  "
read answer

case "$answer" in
[1]*)  modules/security/run-chkrootkit.sh
       main
;;

[2]*)  modules/security/run-rkhunter.sh
       main
;;

[3]*)  modules/security/run-maldet.sh
       main
;;

[4]*)  modules/security/find-web-hacks.sh
       main
;;


*) main
;;
esac
;;

#########################################
#########################################

*) exit
;;
esac
}
main

