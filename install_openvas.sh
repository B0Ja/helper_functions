#!/bin/bash
# The script to run and install the OpenVAS application and set it up
# Reference: https://hedgehogsecurity.co.uk/blog/2020/10/07/installing-openvas/
# Reference: https://kifarunix.com/install-and-setup-gvm-20-08-on-ubuntu/
 
#Constants
_MARK=“[-]”
_FAILED=“\e[91mFAILED\e[0m”
_SUCCESS=“\e[92mSUCCESS\e[0m”
_INSTALLED=“\e[92mINSTALLED\e[0m”

#List of packages
packages=(“gcc" "g++" "make" "bison" "flex" "libksba-dev" "curl" "redis" "libpcap-dev" "cmake" "git" "pkg-config" "libglib2.0-dev" "libgpgme-dev" "nmap" "libgnutls28-dev" "uuid-dev" "libssh-gcrypt-dev" "libldap2-dev" "gnutls-bin" "libmicrohttpd-dev" "libhiredis-dev" "zlib1g-dev" "libxml2-dev" "libradcli-dev" "clang-format" "libldap2-dev" "doxygen" "gcc-mingw-w64" "xml-twig-tools" "libical-dev" "perl-base" "heimdal-dev" "libpopt-dev" "libsnmp-dev" "python3-setuptools" "python3-paramiko" "python3-lxml" "python3-defusedxml" "python3-dev" "gettext" "python3-polib" "xmltoman" "python3-pip" "texlive-fonts-recommended" "texlive-latex-extra" "--no-install-recommends" "xsltproc”)


#Check to see if the Sudo permissions are provided. 

require_sudo () {
    
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


#Package installer
install_packages() {
for package in $[packages[*]]; do
    
    if [ '$(which $package)' != "" ]; then
    	echo “  $_MARK Installing $package...”
	sudo apt install -y -qq $package 
			        	
		if (( $? )); then
  			echo “\t$package $_FAILED.” >&2 
		else
			echo “\t$package $_INSTALLED.”
		fi
    else
	echo “\t$package already $_INSTALLED.”
    fi
done
}

#Update system and repositories
sudo apt update -y -q && sudo apt upgrade -y -qq
install_packages
 

#Create the User
sudo useradd -r -d /opt/gvm -c "GVM User" -s /bin/bash gvm
sudo mkdir /opt/gvm
sudo chown -R gvm:gvm /opt/gvm
  
#Installing Yarn
sudo curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
sudo echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
apt install yarn -y -qq
 
#Installing Postgres
apt install -qq -y postgresql postgresql-contrib postgresql-server-dev-all


#Work with Postgres
sudo -Hiu postgres
sudo psql -U postgres -c "CREATE USER gvm;"
sudo psql -U postgres -c "CREATEDB -O gvm gvmd"

sudo psql -U postgres -c "psql gvmd"  
sudo psql -U postgres -c "create role dba with superuser noinherit;"
sudo psql -U postgres -c "grant dba to gvm;"
sudo psql -U postgres -c "create extension \"uuid-ossp\";"


#sudo -u postgres bash -c "psql -c \"CREATE USER gvm WITH PASSWORD 'gvm';\""


#Ensure the configs stick. Flush + restart
systemctl restart postgresql
systemctl enable postgresql

path_to_add="/opt/gvm/bin:/opt/gvm/sbin:/opt/gvm/.local/bin"
export PATH="$PATH:$path_to_add"

#sudo -u other_user your_command

sudo -u gvm 

sudo -u gvm mkdir /tmp/gvm-source
sudo -u gvm cd /tmp/gvm-source
sudo -u gvm git clone -b gvm-libs-11.0 https://github.com/greenbone/gvm-libs.git
sudo -u gvm git clone https://github.com/greenbone/openvas-smb.git
sudo -u gvm git clone -b openvas-7.0 https://github.com/greenbone/openvas.git
sudo -u gvm git clone -b ospd-2.0 https://github.com/greenbone/ospd.git
sudo -u gvm git clone -b ospd-openvas-1.0 https://github.com/greenbone/ospd-openvas.git
sudo -u gvm git clone -b gvmd-9.0 https://github.com/greenbone/gvmd.git
sudo -u gvm git clone -b gsa-9.0 https://github.com/greenbone/gsa.git


export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH

make_install() {
mkdir build && cd build 
cmake .. -DCMAKE_INSTALL_PREFIX=/opt/gvm 
make && make install
}

cd "gvm-libs" && make_install
cd "../../openvas-smb/" && make_install
cd "../../openvas" && make_install


#Configuring VAS
ldconfig
sudo cp /tmp/gvm-source/openvas/config/redis-openvas.conf /etc/redis/
sudo chown redis:redis /etc/redis/redis-openvas.conf

echo "db_address = /run/redis-openvas/redis.sock" &gt; /opt/gvm/etc/openvas/openvas.conf



