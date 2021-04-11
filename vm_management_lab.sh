#!/bin/bash

############################################################
#							   #
#   IMPORTANT: Do not Use. Needs Test. Work in Progress.   #
#							   #
############################################################
############################################################
# A script to help download Virtualbox, download and verify Kali OVA,
# and get the appliance up and running in the Cyber range lab


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


# Checking for Virtualbox and installing it
install_package() {

        binary="$1"
        packages="$2"

        if [ "$(which $1)" != "" ]
        then
                for package in $packages; do
			echo "Installing $packages"
                        $SUDO apt -q -y install $packages
                done
        else
                echo "$binary is installed"
        fi
}


###########################################################
##Run the script below:
#Check for the sudo permissions
require_sudo

#Check and Install these
#format: install_package packagename packagename
install_package virtualbox virtualbox

############################################################

#Create a Temp folder
cd $(mktemp -d)

#Check the current directory:
dir_path=$PWD
echo "Current directory is $dir_path"

############################################################
#Downloading the KALI OVA

#gpg --keyserver hkp://keys.gnupg.net --recv-key 44C6513A8E4FB3D30875F758ED444FF07D8D0BF6

OVA_NAME="kali-linux-2021.1-vbox-amd64.ova"

#Download the VBOX images
wget https://images.kali.org/virtual-images/$OVA_NAME -qq --show-progress --progress=bar:force

#Verify Checksum
hash="b907b61ed584c8eef57dcb81e45f8e8af608cc1e0f203711e6c57653b938ef69"
shasum $OVA_NAME | awk '$1=="$hash"{print"...Checksum Matched..."}'

#Verify the integrity of downloads
#wget -q https://cdimage.kali.org/current/SHA256SUMS{.gpg,}
#gpg --verify SHA256SUMS.gpg SHA256SUMS


###########################################################
##Setting up the VM

#Check the VM parameters needed:
VBoxManage import $OVA_NAME --dry-run

#Importing the appliance
VBoxManage import $OVA_NAME --vmname kali --options keepallmacs \
			    --cpus 2 --memory 2048 --vram 4 --eula accept \
			    --vsys 0 --nic1 bridged --bridgeadapter1 eth0

###########################################################
