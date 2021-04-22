#!/bin/bash

############################################################
#							   #
#   IMPORTANT: Do not Use. Needs Test. Work in Progress.   #
#							   #
############################################################
############################################################

# A script to help download Virtualbox, download and verify virtualbox machines,
# including Kali OVA and get the appliance up and running in the Cyber range lab.


#Constants
OVA_NAME="kali-linux-2021.1-vbox-amd64.ova"
hash="b907b61ed584c8eef57dcb81e45f8e8af608cc1e0f203711e6c57653b938ef69"

#Colors
_FAILED="\e[91mFAILED\e[0m"
_SUCCESS="\e[92mSUCCESS\e[0m"

#SUDO
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


# Checking for packages and installing it
install_package() {

        binary="$1"
        packages=$2

        if [ "$(which $1)" != "" ]
        then
                for package in $packages; do
			        _installing_packages $packages
                done
        else
                echo "$binary is installed"
        fi
}

_installing_packages() {
    echo "Installing $packages"
    $SUDO apt -qq -y install $packages
}

require_sudo
install_package virtualbox "virtualbox"

#Create a Temp folder
cd $(mktemp -d)
dir_path=$PWD
echo "Current directory is $dir_path"

#Downloading the KALI OVA
#gpg --keyserver hkp://keys.gnupg.net --recv-key 44C6513A8E4FB3D30875F758ED444FF07D8D0BF6
#Verify the integrity of downloads
#wget -q https://cdimage.kali.org/current/SHA256SUMS{.gpg,}
#gpg --verify SHA256SUMS.gpg SHA256SUMS


## Setting up the VM

if [ ! vm_image=="$OVA_NAME" ]; then

    echo "Please enter the VM url: "
    read vm_url

    download_vm="wget -O $vm_url -P $dir_path -qq --show-progress"
    
    if "${download_vm}"; then
        echo Download $_SUCCESS >&2
        vm_name2=`echo $vm_url | awk -F/ '{print $NF}'`
        echo "The hash of downloaded file is: " $(sha256sum "$vm_name2" | awk '{print $1}')
    else
        echo Download $_FAILED >&2
    fi
else 
    echo "Selection image is a Kali latest image (default)."

    if "{wget https://images.kali.org/virtual-images/$OVA_NAME -qq --show-progress --progress=bar:force}"; then
        echo Download $_SUCCESS >&2      
        shasum $OVA_NAME | awk '$1=="$hash"{print"...\e[92mChecksum matched.\e[0m"}'
        shasum $OVA_NAME | awk '$1!="$hash"{print"...\e[91mChecksum did not match.\e[0m"}'
    else
        echo Download of $OVA_NAME $_FAILED.
    fi
fi

vm_dry_run() {

    VBoxManage import $OVA_NAME --dry-run
    if [ $?==0 ]; then
        echo "VM dry-run $_SUCCESS"
        echo "Importing VM ..."
        vm_import
    else
        echo "VM dry run $_FAILED"
    fi
}


vm_import() {
#Importing the appliance
VBoxManage import $OVA_NAME --vmname kali --options keepallmacs \
			    --cpus 2 --memory 2048 --vram 4 --eula accept \
			    --vsys 0 --nic1 bridged --bridgeadapter1 eth0 
}
