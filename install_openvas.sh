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

#Edit config files

ldconfig
sudo cp /tmp/gvm-source/openvas/config/redis-openvas.conf /etc/redis/
sudo chown redis:redis /etc/redis/redis-openvas.conf
echo "db_address = /run/redis-openvas/redis.sock" > /opt/gvm/etc/openvas/openvas.conf
sudo chown gvm:gvm /opt/gvm/etc/openvas/openvas.conf
sudo user mod -aG redis gvm

#Improving Redis server performance
echo “net.core.somaxconn = 1024” >> /etc/sysctl.conf
echo ‘vm.overcommit_memory = 1’ >> /etc/sysctl.conf
sysctl - p


sudo cat > ${/etc/systemd/system}/disable_thp.service <<'_EOF'
[Unit]
Description=Disable Kernel Support for Transparent Huge Pages (THP)

[Service]
Type=simple
ExecStart=/bin/sh -c "echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled && echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag"

[Install]
WantedBy=multi-user.target
_EOF
## Service file end


systemctl daemon-reload
systemctl enable --now disable_thp
systemctl enable --now redis-server@openvas
sudo echo "gvm ALL = NOPASSWD: /opt/gvm/sbin/openvas" > /etc/sudoers.d/gvm


#Playing with fire.. editing sudoers
sudo visudo
sudo sed ’s/\”Defaults        secure_path=\”/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\””/\”Defaults        secure_path=\”/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\:/opt/gvm/sbin\””/g’


sudo bash -c 'echo "your_user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/99_sudo_include_file'

#Configuring User paths

sudo -u gvm greenbone-nvt-sync
sudo -u gvm openvas –update-vt-info
sudo -u gvm export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH
sudo -u gvm -bash -c ‘cd gvm-source/gvmd’ && make_install
sudo -u gvm -bash -c ‘cd ../../gsa’ && make_install
sudo -Hiu gvm greenbone-feed-sync --type GVMD_DATA
sudo -Hiu gvm greenbone-feed-sync --type SCAP
sudo -Hiu gvm greenbone-feed-sync --type CERT3
sudo -u gvm gvm-manage-certs -a
sudo -u gvm export PKG_CONFIG_PATH=/opt/gvm/lib/pkgconfig:$PKG_CONFIG_PATH
sudo -u gvm  -c bash ‘cd /opt/gvm/gvm-source/ospd’
sudo -u gvm  -c bash ‘ python3 setup.py install --prefix=/opt/gvm’


## Create service file
sudo cat > ${/etc/systemd/system}/openvas.service << '_EOF'
[Unit]
Description=Control the OpenVAS service
After=redis.service
After=postgresql.service

[Service]
ExecStartPre=-rm -rf /opt/gvm/var/run/ospd-openvas.pid /opt/gvm/var/run/ospd.sock /opt/gvm/var/run/gvmd.sock
Type=simple
User=gvm
Group=gvm
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/opt/gvm/bin:/opt/gvm/sbin:/opt/gvm/.local/bin
Environment=PYTHONPATH=/opt/gvm/lib/python3.8/site-packages
ExecStart=/usr/bin/python3 /opt/gvm/bin/ospd-openvas \
--pid-file /opt/gvm/var/run/ospd-openvas.pid \
--log-file /opt/gvm/var/log/gvm/ospd-openvas.log \
--lock-file-dir /opt/gvm/var/run -u /opt/gvm/var/run/ospd.sock
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
_EOF
## Service file end


systemctl daemon-reload
systemctl start openvas

echo -e “… Checking the status of OpenVAS… ”
systemctl status openvas
echo -e  “… Enabling OpenVAS”
systemctl enable openvas


## Create service file
sudo cat > ${/etc/systemd/system}/gsa.service << '_EOF'
[Unit]
Description=Control the OpenVAS GSA service
After=openvas.service

[Service]
Type=simple
User=gvm
Group=gvm
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/opt/gvm/bin:/opt/gvm/sbin:/opt/gvm/.local/bin
Environment=PYTHONPATH=/opt/gvm/lib/python3.8/site-packages
ExecStart=/usr/bin/sudo /opt/gvm/sbin/gsad
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
_EOF
## Service file end


sudo cat > ${/etc/systemd/system}/gsa.path << '_EOF'
[Unit]
Description=Start the OpenVAS GSA service when gvmd.sock is available

[Path]
PathChanged=/opt/gvm/var/run/gvmd.sock
Unit=gsa.service

[Install]
WantedBy=multi-user.target
_EOF
## Service file end


## Create service file
sudo cat > ${/etc/systemd/system}/gvm.service << '_EOF'
[Unit]
Description=Control the OpenVAS GVM service
After=openvas.service

[Service]
Type=simple
User=gvm
Group=gvm
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/opt/gvm/bin:/opt/gvm/sbin:/opt/gvm/.local/bin
Environment=PYTHONPATH=/opt/gvm/lib/python3.8/site-packages
ExecStart=/opt/gvm/sbin/gvmd --osp-vt-update=/opt/gvm/var/run/ospd.sock
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
_EOF
## Service file end


## Create service file
sudo cat > ${/etc/systemd/system}/gvm.path << '_EOF'
[Unit]
Description=Start the OpenVAS GVM service when opsd.sock is available

[Path]
PathChanged=/opt/gvm/var/run/ospd.sock
Unit=gvm.service

[Install]
WantedBy=multi-user.target
_EOF
## Service file end


#Update and initiate
sudo systemctl daemon-reload
sudo systemctl enable --now gvm.{path,service}
sudo systemctl enable --now gsa.{path,service}

#Checking status
systemctl status gvm.{path,service}
systemctl status gsa.{path,service}

sudo -Hiu gvm gvmd --create-scanner="OpenVAS Scanner" --scanner-type="OpenVAS" --scanner-host=/opt/gvm/var/run/ospd.sock

sudo -Hiu gvm gvmd --get-scanners

#Creating user accounts
echo -e “Creating new user: gmvadmin with password \“Pa$$w0rd\””
sudo -Hiu gvm gvmd --create-user gvmadmin --password=Pa$$w0rd

#Commands to reset the password
#sudo -Hiu gvm gvmd --user=<USERNAME> --new-password=<PASSWORD>

#Allow the firewall
sudo ufw allow 443/tcp


echo “Installation completed”
echo  -n “Log files at /opy/gvm/var/log/gvm :”
sudo ls /opt/gvm/var/log/gvm
echo -e “\nAccess the GSA with https:<serverIP-OR-hostname>\n”

