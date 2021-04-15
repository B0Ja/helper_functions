!/bin/bash
 
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
 fi
 
if [ -d $urlvar1/$folder ]
then	
	echo Downloading $filename ...	
	wget "http://sourceforge.net/projects/bwapp/files/latest/download" -O $filename -qq --show-progress
	$SUDO unzip -qq "/home/$USER/Downloads/$filename" -d "$urlvar1/$folder/" && echo Unzip successful
	#unzip '$urlvar1/$folder/$filename' .
	sudo chmod -R 777 $urlvar1	#Giver permissions to the entire folder
	echo "Changing the Admin settings: "
	sed -i 's/$db_username = "root"\;/$db_username = "bee"\;/g' "$urlvar1/$folder/bWAPP/admin/settings.php"	&& echo Change username from default Root to \“bee\”
	sed -i 's/$db_password = ""\;/$db_password = "bug"\;/g'	"$urlvar1/$folder/bWAPP/admin/settings.php" && echo Change the password to “bug”
  
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
create_user="CREATE USER 'bee'@'localhost' IDENTIFIED BY 'bug';"
grant_rights="GRANT ALL PRIVILEGES ON *.* TO 'bee'@'localhost';"

#Queries that helps during reinstall
#Drops the users, so it is created afresh
drop_user="DROP USER bee@localhost;"
drop_db="DROP DATABASE bWAPP;"

#Creating environment
#mysql --user=root -p -e "create database bWAPP;"
mysql --user=root -p -e "$drop_user; $drop_db; FLUSH PRIVILEGES;"
mysql --user=root -p -e "$create_user"  && echo "** User created: Username: bee; Password: bug **"
mysql --user=root -p -e "$grant_rights"  && echo "** Rights granted for: Username: bee; Password: bug **"

#Activating privileges
mysql --user=root -p -e "FLUSH PRIVILEGES;"  && echo "Activating privileges..."

#Restart the services
sudo service mysql restart
sudo service apache2 restart
 
#start the browser for final installation
firefox localhost/bwapp/bWAPP/install.php
#EOF
