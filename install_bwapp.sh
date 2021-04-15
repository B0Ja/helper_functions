#!/bin/bash
 
# The script to run and install the BWAPP application and set it up
 
#Check to see if the Sudo permissions are provided.
 
require_sudo () {
    	#Sets $SUDO to "sudo" and $SUDO_E to "sudo -E" if needed.
	if [ "$EUID" -eq 0 ]; then
	        	SUDO=""
        		SUDO_E=""
        		return 0
    	fi

	if sudo -v; then
        		SUDO="sudo"
		SUDO_E="sudo -E"
		return 0
	fi
}
require_sudo

install_tools() {

        binary="$1"
        packages=$2
        if [ "$(which $1)" != "" ]
        then
                for package in $packages; do
                        $SUDO apt -q -y install $package
			RESULT=$?
			if [ $RESULT -eq 0 ]; then
 				echo "$1 installation successful"
			else
				echo "$1 installation failed"
			fi
                done
        else
                echo "$binary is installed"
        fi
}

#Check and Install these
install_tools mysql "mysql-server"
install_tools apache2 "apache2"
install_tools php "php"
install_tools firefox "firefox"

#Setting Variables
user=$USER

#Set the version and the directory name
filename='bWAPP_latest'
folder='bwapp'
  
#Move the files to the Webserver directory
urlvar1='/var/www/html'
 
echo "Checking for the Apache install and prerequisites."
if [ -d $urlvar1 ]; then
	echo "Apache is installed."
	if [ ! -d $urlvar1/$folder ]; then
		$SUDO mkdir -p $urlvar1/$folder
	else
		echo "Bwapp folder exists."
	fi
 else
 	#Check for Apache
	if [ $(which apache2) = "" ]; then
		$SUDO apt -qq -y install apache2 && echo "Apache installed"
	else
		echo "Unable to install Apache2."
 fi
 
if [ -d $urlvar1/$folder ]
then
	wget -P $path "http://sourceforge.net/projects/bwapp/files/latest/download" -O $filename
	unzip '${$urlvar1}/${folder}${filename}' .
	sudo chmod -R 777 $urlvar1	#Giver permissions to the entire folder
	sed -i 's/$db_username = "root"\;/$db_username = "bee"\;/g'	#Change username from default Root to “bee”
	sed -i 's/$db_password = ""\;/$db_password = "bug"\;/g'		#Change the password to “bug”
  
else
	echo "Unable to copy to Webserver directory"
	echo "Checking and installing webserver"
	if [ "$(which apache2)" = "" ]
        then
		$SUDO apt -qq -y install apache2 && echo "Apache2 installed"
        else
                echo "Unable to install Apache2."
     fi

fi

 
#Start the services
sudo service mysql start
sudo service apache2 start
  
#Start and Manage MySQL 

#Queries
create_user="create user 'bee'@'localhost' identified by 'bug';"
grant_rights="grant all privileges on *.* to 'bee'@'localhost';"
 
#Creating user
mysql --user=root --password=toor -e "$create_user"  && echo "** User created: Username: bee; Password: bug **"
echo " "
echo " "
#Granting rights
mysql --user=root --password=toor -e "$grant_rights" $$ echo "**Rights granted to user Bee**"
 

#Restart the services
sudo service mysql restart
sudo service apache2 restart
 
#start the browser for final installation
firefox localhost/bwapp/bWAPP/install.php
 
#EOS
