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

# Change PS1.
changeps1() {

if [ "$OS"="Ubuntu" ]
then
	#BASHRC="/etc/bash.bashrc"
	BASHRC1="/root/.bashrc"
	BASHRC2="/home/ubuntu/.bashrc"
	/usr/bin/sudo /bin/cp $BASHRC1 /tmp/bashrc1.$DATE
	/usr/bin/sudo /bin/cp $BASHRC2 /tmp/bashrc2.$DATE
	sed "s/PS1\=.*$/$(printf "%q" "PS1=\"[\u@\H \W]\\$ \"")/g" $BASHRC1 |/usr/bin/tee /tmp/bashrc1
	/bin/mv /tmp/bashrc1 $BASHRC1
	sed "s/PS1\=.*$/$(printf "%q" "PS1=\"[\u@\H \W]\\$ \"")/g" $BASHRC2 |/usr/bin/tee /tmp/bashrc2
	/bin/mv /tmp/bashrc1 $BASHRC2

elif [ "$OS"="Centos" ]
then
	BASHRC1="/root/.bashrc"
	/bin/cp $BASHRC1 /tmp/bashrc1.$DATE
	sed "s/PS1\=.*$/$(printf "%q" "PS1=\"[\u@\H \W]\\$ \"")/g" $BASHRC1 | /usr/bin/tee /tmp/bashrc1
	/bin/mv /tmp/bashrc1 $BASHRC1
else
	exit 1
fi
}

#---- Main --------------------------------------------------------------------

echo " Checking OS "
checkos
echo " OS is $OS "
echo
echo " Updating PS1 "
changeps1
#---- End ---------------------------------------------------------------------
