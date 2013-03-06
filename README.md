## Shelladmin

Collection of small scripts to automate specific system administration
tasks to help achieve consistent results.


### Purpose

The purpose of these scripts is to automate common tasks that are performed
often.  The scripts can be run independently, or by using a simple menu
driven interface that ties all the scripts together.


### Features

- Simple code base for quick customizations
- Support for Apache, MySQL, security and system administration tasks
- Menu interface for interacting with scripts


### Compatibility

| **Operating System** | **Supported** | **Notes** |
|:-------------|:----------------|:----------------|
|RedHat ES5|X|--|
|RedHat ES6|X|--|
|CentOS 5|X|--|
|CentOS 6|X|--|
|Ubuntu 10.04|X|--|
|Ubuntu 12.04|X|--|


### Scripts

| **Script** | **Category** | **Description** |
|:-------------|:----------------|:----------------|
|shelladmin.sh|--|Menu Interface|
|add\_vhost.sh|Apache|Creates Apache vhost and SFTP user|
|run-apachebuddy.sh|Apache|Downloads and runs apachebuddy|
|databaseadmin.sh|MySQL|Basic MySQL adding, listing, deleting databases and users|
|run-mysqltuner.sh|MySQL|Downloads and runs mysqltuner|
|run-tuning-primer.sh|MySQL|Downloads and runs tuning-primer|
|find-web-hacks.sh|Security|Quick and dirty script to find web hacks|
|run-chkrootkit.sh|Security|Downloads and runs chkrootkit|
|run-maldet|Security|Downloads and runs maldet|
|run-rkhunter|Security|Downloads and runs rkhunter|
|system-profile.sh|System|Displays useful system information|


### Implementation

Download and run as root:

	cd /root
	git clone https://github.com/stephenlang/shelladmin
	cd shelladmin
	./shelladmin.sh
