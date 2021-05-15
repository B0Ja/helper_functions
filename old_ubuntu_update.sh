#!/bin/bash

# Older releases of Ubuntu have issues in updating it's repositories. 
# This set of commands help in updating Ubuntu with old releases.

# Caution: This will install / not install the latest security patches
# This must not be used in important systems.
# Best follow-up is to use the full-dist-upgrade soon after.

sudo sed -i -re ’s/([a-z]{2}\.)?archive.ubuntu.com|security.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list
sudo apt update -y --allow-insecure-repositories
