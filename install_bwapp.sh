# The script to run and install the BWAPP application and set it up

fail() {
	#Something failed, exit.
	
	echo "$@, exiting." >&2
	exit 1
}


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
    fail 'Missing administrator priviledges. Please run with sudo priviliges.'
}


#check if requirements are installed
if [ “$(which mysql)” != "" ]
then
{
sudo apt install mysql-server
}
fi

if [ “$(which apache2)” != "" ]
then
{
sudo apt install apache2
}
fi

if [ “$(which php)” != "" ]
then
{
sudo apt install php
}
fi

if [ “$(which firefox)” != "" ]
then
{
sudo apt install firefox
}
fi


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
		mv $path2 $urlvar1
	elif [ -d $urlvar2 ]
	then
     		mv $path2 $urlvar2
	else
     	echo "Webserver directory not created. Check if you have Apache2."
	fi
else
	echo "WWW folder not found. Is the webserver installed?"
fi


if [ -d $urlvar1/$folder ]
then
        mv $path2 $urlvar1		#Move the file
	sudo chmod -R 777 $urlvar1	#Giver permissions to the entire folder
	sed -i 's/$db_username = "root"\;/$db_username = "bee"\;'	#Change username from default Root to Bee
	sed -i 's/$db_password = ""\;/$db_password = "bug"\;'

elif [ -d $urlvar2/$folder ]
then
	mv $path2 $urlvar2
	sudo chmod -R 777 $urlvar2
	sed -i 's/$db_username = "root"\;/$db_username = "bee"\;'
	sed -i 's/$db_password = ""\;/$db_password = "bug"\;'

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

