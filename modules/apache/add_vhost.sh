#!/bin/bash 
#
# Add Apache vhost 
# 
# Stephen Lang
# Tue Mar  5 23:53:01 EST 2013


# Set Apache DocumentRoot
documentroot=/var/www/vhosts/$1


# Variables
baseip=`ifconfig eth0 | grep "inet addr" | awk '{print $2}' |cut -d: -f2`
script=${0##*/}


# Sanity Checks
function help {

cat <<HELP

SYNOPSIS:  ./$script [domain]... [sftpuser]...
USAGE EXAMPLE: ./$script example.com exampleuser

HELP
        exit 0
}

if [ -z "$1" -o -z "$2" ]; then
        help
fi


if [ ! `whoami` = root ]; then  
	echo "Error: Script can only be run as root." >&2
	sleep 2
	exit 1
fi

if [ ! -f /etc/redhat-release ]; then
	if [ ! -f /etc/lsb-release ]; then
		echo "Error:  Unsupported OS."
		sleep 2
		exit 1
	fi
fi

if [ ! -z "$(echo $1 | grep -E '^www\.')" ] ; then
	echo "Please omit the www. prefix on the domain name" >&2
	sleep 2
	exit 1
fi

if [ "$(echo $1 | sed 's/ //g')" != "$1" ] ; then
	echo "Error: Domain names cannot have spaces." >&2
	sleep 2
	exit 1
fi

if [ -f /etc/redhat-release ]; then
	if [ -f /etc/httpd/vhost.d/$1.conf ]; then
		echo "Error:  Domain already configured in Apache."
		echo "No changes have been made."
		sleep 2
		exit 1
	fi
elif [ -f /etc/lsb-release ]; then
	if [ -f /etc/apache2/sites-available/$1.conf ]; then
		echo "Error:  Domain already configured in Apache."
		echo "No changes have been made."
		sleep 2
		exit 1
	fi
fi

if [ `cat /etc/passwd | cut -d\: -f1 |grep "^\$2$" |wc -l` -ge 1 ]; then	
	echo "Error:  SFTP user already exists."
	echo "No changes have been made."
	sleep 2
	exit 1
fi

if [ ! -d $logs ]; then
	mkdir -p $logs
fi		


# Create Vhosts

	if [ -f /etc/redhat-release ]; then
		cat << EOF > /etc/httpd/vhost.d/$1.conf
<VirtualHost *:80>
        ServerName $1
        ServerAlias www.$1
        DocumentRoot $documentroot
        <Directory $documentroot>
                Options -Indexes FollowSymLinks -MultiViews
                AllowOverride All
        </Directory>

        CustomLog /var/log/httpd/$1-access.log combined
        ErrorLog /var/log/httpd/$1-error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn
</VirtualHost>


#<VirtualHost _default_:443>
#        ServerName $1
#        DocumentRoot $documentroot
#        <Directory $documentroot>
#                Options -Indexes FollowSymLinks -MultiViews
#                AllowOverride All
#        </Directory>
#
#        CustomLog /var/log/httpd/$1-ssl-access.log combined
#        ErrorLog /var/log/httpd/$1-ssl-error.log
#
#        # Possible values include: debug, info, notice, warn, error, crit,
#        # alert, emerg.
#        LogLevel warn
#
#        SSLEngine on
#        SSLCertificateFile    /etc/pki/tls/certs/localhost.crt
#        SSLCertificateKeyFile /etc/pki/tls/private/localhost.key
#
#        <FilesMatch "\.(cgi|shtml|phtml|php)$">
#                SSLOptions +StdEnvVars
#        </FilesMatch>
#
#        BrowserMatch "MSIE [2-6]" \\
#                nokeepalive ssl-unclean-shutdown \\
#                downgrade-1.0 force-response-1.0
#        BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown
#</VirtualHost>
EOF
		service httpd restart > /dev/null 2>&1
	elif [[ `cat /etc/lsb-release |grep DISTRIB_ID | cut -d\= -f2` = "Ubuntu" ]]; then
		cat << EOF > /etc/apache2/sites-available/$1
<VirtualHost *:80>
        ServerName $1
        ServerAlias www.$1
        DocumentRoot $documentroot
        <Directory $documentroot>
                Options -Indexes FollowSymLinks MultiViews
                AllowOverride All
        </Directory>

        CustomLog /var/log/apache2/$1-access.log combined
        ErrorLog /var/log/apache2/$1-error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn
</VirtualHost>



#<VirtualHost _default_:443>
#        ServerName $1
#        DocumentRoot $documentroot
#        <Directory $documentroot>
#                Options -Indexes FollowSymLinks MultiViews
#                AllowOverride All
#        </Directory>
#
#        CustomLog /var/log/apache2/$1-ssl-access.log combined
#        ErrorLog /var/log/apache2/$1-ssl-error.log
#
#        # Possible values include: debug, info, notice, warn, error, crit,
#        # alert, emerg.
#        LogLevel warn
#
#        SSLEngine on
#        SSLCertificateFile    /etc/ssl/certs/ssl-cert-snakeoil.pem
#        SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
#
#        <FilesMatch "\.(cgi|shtml|phtml|php)$">
#                SSLOptions +StdEnvVars
#        </FilesMatch>
#
#        BrowserMatch "MSIE [2-6]" \\
#                nokeepalive ssl-unclean-shutdown \\
#                downgrade-1.0 force-response-1.0
#        BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown
#</VirtualHost>
EOF
		a2ensite $1 > /dev/null 2>&1
		service apache2 restart	 > /dev/null 2>&1
fi

mkdir -p $documentroot


# Create STP User and DocumentRoot

siteadminpw=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c15`

if [ -f /etc/redhat-release ]; then
	useradd -d $documentroot $2
	echo $siteadminpw | passwd $2 --stdin
	usermod -a -G apache $2

elif [[ `cat /etc/lsb-release | grep DISTRIB_ID | cut -d\= -f2` = "Ubuntu" ]]; then
	hashpw=`mkpasswd -m md5 $siteadminpw`
	useradd -d $documentroot -p $hashpw $2
	usermod -a -G www-data $2
fi

chmod -R 775 $documentroot
chown -R $2:$2 $documentroot


# Generate Setup Letter

cat << EOF > /tmp/web_$1.txt

Good afternoon,

As requested, your new domain has been created.  The information you will
need to access and use your new domain are posted below:

---------------------------------------------------------------
Website Information
---------------------------------------------------------------

Domain:            $1
DocumentRoot:      $documentroot
SFTP IP:           $baseip
SFTP Username:     $2
SFTP Password:     $siteadminpw

---------------------------------------------------------------
DNS Information
---------------------------------------------------------------

Once you are ready to go live, you will want to point the DNS as follows:
www.$1. IN A $baseip
$1. IN A $baseip

If you want to be able to test the domain before you update DNS, I'll
provide instructions below for how you can fake out your personal computers
DNS:

- On mac or linux:
1. Open a Terminal
2. Type: sudo vi /etc/hosts
# add
$baseip $1 www.$1

- Windows
If you are using a Windows based machine, I'll provide a link below that
walks you through modifying the Windows etc/hosts file better than I can
explain it here:
http://www.rackspace.com/knowledge_center/index.php/How_do_I_modify_my_hosts_file

The entry you want to put in the windows etc/hosts file is:
$baseip $1 www.$1

EOF

less /tmp/web_$1.txt
rm -f /tmp/web_$1.txt
