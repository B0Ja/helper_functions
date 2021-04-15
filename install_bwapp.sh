#!/bin/bash
 
# The script to run and install the BWAPP application and set it up
 
#Check to see if the Sudo permissions are provided.
 
require_sudo () {
    #Stops the script if the user does not have root priviledges and cannot sudo
    #Additionally, sets $SUDO to "sudo" and $SUDO_E to "sudo -E" if needed.
 

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

#Set the version to be downloaded
filename='bWAPP_latest'

folder='bwapp'
  
   
#Move the files to the Webserver directory
urlvar1='/var/www/html'
 
if [ -d /var/www ]
then
	if [ -d $urlvar1 ]
	then
		sudo -A mv $path2 $urlvar1
	else
     	echo "Webserver directory not created. Check if you have Apache2."
	fi
else
	echo "WWW folder not found. Is the webserver installed?"
fi
 
 
if [ -d $urlvar1/$folder ]
then
     filename='bWAPP_latest'
	wget -P $path "http://sourceforge.net/projects/bwapp/files/latest/download" -O $filename
	unzip '${$urlvar1}/${folder}${filename}' .
	sudo chmod -R 777 $urlvar1	#Giver permissions to the entire folder
	sed -i 's/$db_username = "root"\;/$db_username = "bee"\;/g'	#Change username from default Root to “bee”
	sed -i 's/$db_password = ""\;/$db_password = "bug"\;/g'		#Change the password to “bug”
  
else
	echo "Unable to copy to Webserver directory.”
	echo “Checking and installing webserver.”
	if [ "$(which apache2)” = "" ]
        then
			$SUDO apt -q -y install $package
        else
                echo “Unable to install Apache2."
     fi

fi

 
#Start the services
sudo service mysql start
sudo service apache2 start
 
#Start MySQL server and login
mysql --user=root --password=toor	#Setting password in the command line is not a good policy
 
#Manage MySQL 
create_user="create user 'bee'@'localhost' identified by 'bug';"
grant_rights="grant all privileges on *.* to 'bee'@'localhost';"
 
#Creating user
mysql --user=root --password=toor -e "$create_user"  && echo "**User created: Username: bee; Password: bug**"
echo " "
echo " "
mysql --user=root --password=toor -e "$grant_rights" $$ echo "**Rights granted to user Bee**"
 
 
#Restart the services
sudo service mysql restart
sudo service apache2 restart
 
#start the browser for final installation
firefox localhost/bwapp/bWAPP/install.php
 
#EOS
