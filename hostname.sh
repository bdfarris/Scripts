#!/bin/bash -x

#---- Variables ---------------------------------------------------------------

# bashrc location.
BASHRC1="/root/.bashrc"
BASHRC2="/home/ubuntu/.bashrc"

# Network interfaces.
# For Ubuntu.
NET=`ifconfig | grep eth | awk '{print $1}' | cut -d: -f1 | uniq`
IFACE="/etc/network/interfaces"
# For CentOS.
NETCONFFILE="/etc/sysconfig/network"
IFCFG0="/etc/sysconfig/network-scripts/ifcfg-eth0"
ROUTECFG0="/etc/sysconfig/network-scripts/route-eth0"
SUBNET0=`/sbin/ifconfig | grep eth0 |awk '{print $1}' | cut -d: -f1 | uniq`
SUBNET1=`/sbin/ifconfig | grep eth1 |awk '{print $1}' | cut -d: -f1 | uniq`
IFACE="/etc/network/interfaces"

# Current date in YYYYMMDD-HH24:MI-SS format.
DATE=`date +%Y%m%d-%R:%S`

#---- Functions ---------------------------------------------------------------

# Get OS name.
checkos()
{

	# For Ubuntu.
 	OS=`cat /etc/issue 2> /dev/null | cut -d" " -f1`

 	# Return if OS is found.
 	[ -n "$OS" ] && return 0

 	# For CentOS.
 	OS=`cat /etc/redhat-release 2> /dev/null | cut -d" " -f1`

 	# Return if OS is found.
	[ -n "$OS" ] && return 0
}

#------------------------------------------------------------------------------

hname() {

	#Current hostname
	echo "Existing hostname is $chost"

	#What is the new hostname $
	echo "Enter new hostname: "
	read nhost

	#Ask for FQDN 
        echo "Enter the FQDN: "
        read FQDN

	if [ "$OS" = "Ubuntu" ]
	then

		sudo cp /etc/hosts /etc/hosts.`date +"%Y%m%d%H%M%S"`
		sudo echo "$FQDN" > /etc/hostname
		sudo hostname $FQDN

		#Write new /etc/hosts
		sudo echo "127.0.0.1 localhost" > /etc/hosts.new
		sudo echo "127.0.1.1 $FQDN $nhost" >> /etc/hosts.new
		sudo echo "# The following lines are desirable for IPv6 capable hosts" >> /etc/hosts.new
		sudo echo "::1 ip6-localhost ip6-loopback" >> /etc/hosts.new
		sudo echo "ff02::1 ip6-allnodes" >> /etc/hosts.new
		sudo echo "ff02::2 ip6-allrouters" >> /etc/hosts.new

		sudo mv /etc/hosts.new /etc/hosts

		#Print new hostname
		echo "Hostname is $nhost"

	elif [ "$OS" = "CentOS" ]
	then

		cp /etc/sysconfig/network /etc/sysconfig/network.`date +"%Y%m%d%H%M%S"`
		echo "NETWORKING=yes" > /etc/sysconfig/network
		echo "NETWORKING_IPV6=no" >> /etc/sysconfig/network
		echo "HOSTNAME=$FQDN" >> /etc/sysconfig/network
	else
		exit 1

	fi
}
#---- Main --------------------------------------------------------------------

echo " Checking OS "
checkos
echo " OS is $OS "
echo
echo " Set hostname "
hname

if [ "$OS"="Ubuntu" ]
then
	/etc/init.d/networking restart
else 
	echo " You will need to restart networking for this server"
fi
#---- End ---------------------------------------------------------------------
