#!/bin/sh

# Pre-installation
#echo "Bootstrap: setting common environment in /etc/profile.d/vagrant-soci.sh"
#sudo sh -c "cat /vagrant/bin/vagrant/common.env > /etc/profile.d/vagrant-soci.sh"
#export DEBIAN_FRONTEND="noninteractive"
# Installation
# TODO: Switch to apt-fast when it is avaiable for Trusty
sudo apt-get update -y -q
sudo apt-get -o Dpkg::Options::='--force-confnew' -y -q install \
  build-essential \
  avahi-daemon \
  zip
# Post-installation
## Configure Avahi to enable .local hostnames used to connect between VMs.
echo "Bootstrap: updating /etc/nsswitch.conf to configure Avahi/MDNS for .local lookup"
sudo sed -i 's/hosts:.*/hosts:          files mdns4_minimal [NOTFOUND=return] dns myhostname/g' /etc/nsswitch.conf

# FILE=cert.crt
# if [ ! -f /etc/nginx/$FILE ]; then
#   sudo cp /home/vagrant/nginx_conf/$FILE /etc/nginx/ && sudo chown root /etc/nginx/$FILE  && sudo chmod 700 /etc/nginx/$FILE 
# fi
# FILE=cert.key
# if [ ! -f /etc/nginx/$FILE ]; then
#   sudo cp /home/vagrant/nginx_conf/$FILE /etc/nginx/ && sudo chown root /etc/nginx/$FILE  && sudo chmod 744 /etc/nginx/$FILE 
# fi


command -v puppet > /dev/null && { echo "Puppet is installed! skipping" ; exit 0; }

ID=$(cat /etc/os-release | awk -F= '/^ID=/{print $2}' | tr -d '"')
VERS=$(cat /etc/os-release | awk -F= '/^VERSION_ID=/{print $2}' | tr -d '"')

case "${ID}" in
  centos|rhel)
    wget https://yum.puppet.com/puppet/puppet-release-el-${VERS}.noarch.rpm
    rpm -Uvh puppet-release-el-${VERS}.noarch.rpm
    yum install -y puppet-agent
    ;;
  fedora)
    rpm -Uvh https://yum.puppet.com/puppet5/puppet-release-fedora-${VERS}.noarch.rpm
    yum install -y puppet-agent
    ;;
  debian|ubuntu)
    wget https://apt.puppetlabs.com/puppet-release-$(lsb_release -cs).deb
    dpkg -i puppet-release-$(lsb_release -cs).deb
    apt-get -qq update
    apt-get install -y puppet-agent
    ;;
  *)
    echo "Distro '${ID}' not supported" 2>&1
    exit 1
    ;;
esac

