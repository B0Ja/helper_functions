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
        packages="$2"

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

 
 
#Create a temporary directory in the Downloads folder
user=$USER
folder='bwapp'
 
path='/home/'$user'/Downloads/temp_bwapp'
path2=$path/$folder
#path2='/home/'$user'/Downloads/temp_bwapp/bwapp'
 
 
#Check if the directory exists, else create the directory
if [ ! -d $path ]
then
    mkdir -p $path
fi
 
if [ ! -d $path2 ]
then
    mkdir -p $path2
fi
 
#Set the version to be downloaded
filename='bWAPP_latest'
 
#Download the file to the temo_bwapp directory
wget -P $path "http://sourceforge.net/projects/bwapp/files/latest/download" -O $filename
mv $filename $path
 
#Unzip 
unzip -qq $path/$filename -d $path2
#unzip '${path}${filename}' .
 
 
 
#Move the files to the Webserver directory
 
#There are two possible URLs for Apache
urlvar1='/var/www/html'
urlvar2='/var/www/HTML'
 
if [ -d /var/www ]
then
	if [ -d $urlvar1 ]
	then
		sudo -A mv $path2 $urlvar1
	elif [ -d $urlvar2 ]
	then
     		sudo -A mv $path2 $urlvar2
	else
     	echo "Webserver directory not created. Check if you have Apache2."
	fi
else
	echo "WWW folder not found. Is the webserver installed?"
fi
 
 
if [ -d $urlvar1/$folder ]
then
        sudo -A mv $path2 $urlvar1		#Move the file
	sudo chmod -R 777 $urlvar1	#Giver permissions to the entire folder
	#sed -i 's/$db_username = "root"\;/$db_username = "bee"\;/g'	#Change username from default Root to Bee
	#sed -i 's/$db_password = ""\;/$db_password = "bug"\;/g'
 
elif [ -d $urlvar2/$folder ]
then
	sudo -A mv $path2 $urlvar2
	sudo chmod -R 777 $urlvar2
	#sed -i 's/$db_username = "root"\;/$db_username = "bee"\;/g'
	#sed -i 's/$db_password = ""\;/$db_password = "bug"\;/g'
 
else
	echo "Unable to copy to Webserver directory"
fi
 
 
 
#Start the services
 
sudo service mysql start
sudo service apache2 start
 
 
#Start MySQL server and login
#mysql -u root -p
 
 
create_user="create user 'bee'@'localhost' identified by 'bug';"
grant_rights="grant all privileges on *.* to 'bee'@'localhost';"
 
 
#Creating user
mysql -u root -p -e "$create_user"  && echo "**User created: Username: bee; Password: bug**"
echo " "
echo " "
mysql -u root -p -e "$grant_rights" $$ echo "**Rights granted to user Bee**"
 
 
#Restart the services
sudo service mysql restart
sudo service apache2 restart
 
 
#start the browser for installation
 
firefox localhost/bwapp/bWAPP/install.php
 
#EOS
