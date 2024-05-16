### SCRIPT INSTALL BASE PACKAGES ###

# Maj
apt-get update
apt-get -y dist-upgrade

# Install packages
apt-get -y install vim htop net-tools gpg sudo wget curl

# Configure vim color syntax
echo "syntax on" > /root/vimrc

# Configure sudo
/sbin/usermod -aG sudo flhuillery
