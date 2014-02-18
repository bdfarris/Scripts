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

#------------------------------------------------------------------------------

# Setup Gateway Address.
checknet() {

        if [[ $SUBNET0 = "eth0" ]]
        then
                ROUTE0=`ifconfig eth0 | grep inet | awk '{print $2}' |cut -d: -f2 | cut -d. -f3`
                NET0=`ifconfig eth0 | grep inet | awk '{print $2}' |cut -d: -f2 | cut -d. -f2`
        fi

        if [[ $SUBNET1 = "eth1" ]]
        then
                ROUTE1=`ifconfig eth1 | grep inet | awk '{print $2}' |cut -d: -f2 | cut -d. -f3`
                NET1=`ifconfig eth1 | grep inet | awk '{print $2}' |cut -d: -f2 | cut -d. -f2`
        else
                ROUTE1=$ROUTE0
                NET1=$NET0
        fi

for ETH in $NET
do
	ROUTE=`ifconfig $ETH | grep inet | awk '{print $2}' | cut -d: -f2 | cut -d. -f3`
	echo " Add route for subnet $ROUTE "

	checkos

	# Rewrite /etc/network/interfaces files
	if [ "$OS" = "Ubuntu" ]
	then
		cp $IFACE $IFACE.$DATE

	        sudo echo "# The loopback network interface" > $IFACE
	        sudo echo "auto lo" >> $IFACE
	        sudo echo "iface lo inet loopback" >> $IFACE
	        sudo echo "">> $IFACE
	        sudo echo "# The primary network interface" >> $IFACE
	        sudo echo "auto eth0" >> $IFACE
	        sudo echo "iface eth0 inet dhcp" >> $IFACE
	        sudo echo "">> $IFACE

	        if [[ $SUBNET1 = "eth1" ]]
	        then
			sudo echo "# The secondary public  network interface" >> $IFACE
	                sudo echo "auto eth1" >> $IFACE
	                sudo echo "iface eth1 inet dhcp" >> $IFACE
	                sudo echo "">> $IFACE
	        else
	                sudo echo "# The secondary public  network interface" >> $IFACE
	                sudo echo "# None " >> $IFACE
	        fi

		sudo echo "###### DNS SERVERS #####" >> $IFACE

            	if [[ $NET0 = 99 ]]
            	then
                    sudo echo "">> $IFACE
                    sudo echo "dns-nameservers 172.26.32.150 172.30.32.150" >> $IFACE
                    sudo echo "">> $IFACE
            	else
                    sudo echo "">> $IFACE
                    sudo echo "dns-nameservers 10.97.0.150 10.97.8.150" >> $IFACE                        
                    sudo echo "">> $IFACE
            	fi

            	sudo echo "###### static route ######" >> $IFACE
            	sudo echo "" >> $IFACE
            	sudo echo "# internet route" >> $IFACE               
            	sudo echo "" >> $IFACE
            	sudo echo "up route add -net 0.0.0.0/0 gw 10.$NET0.$ROUTE0.1" >> $IFACE
            	sudo echo "">> $IFACE
            	sudo echo "# private network routes" >> $IFACE
            	sudo echo "">> $IFACE
            	sudo echo "up route add -net 192.168.0.0/16 gw 10.$NET1.$ROUTE1.1" >> $IFACE
            	sudo echo "up route add -net 172.26.0.0/16 gw 10.$NET1.$ROUTE1.1" >> $IFACE
            	sudo echo "up route add -net 172.30.0.0/16 gw 10.$NET1.$ROUTE1.1" >> $IFACE                
            	sudo echo "up route add -net 10.0.0.0/8 gw 10.$NET1.$ROUTE1.1" >> $IFACE
		sudo echo "up route add -net 10.97.250.0/24 gw 10.$NET1.$ROUTE1.0" >> $IFACE
		sudo echo "up route add -net 10.97.252.0/24 gw 10.$NET1.$ROUTE1.0" >> $IFACE
		sudo echo "up route add -net 10.97.254.0/24 gw 10.$NET1.$ROUTE1.0" >> $IFACE
	
	elif [ "$OS" = "CentOS" ]
   	then
	        # Network config file
	        NETCONFFILE='/etc/sysconfig/network'
	        IFCFG0='/etc/sysconfig/network-scripts/ifcfg-eth0'
	        ROUTECFG0='/etc/sysconfig/network-scripts/route-eth0'

	        # Backup old config
	        cp $NETCONFFILE $NETCONFILE.$DATE
	        cp $IFCFG0 $IFCFG0.$DATE
	        cp $ROUTECFG0 $ROUTECFG0.$DATE

	        # Write new /etc/sysconfig/network-scripts/ifcfg-eth0 file
	        NET=`ifconfig eth0 |grep inet | grep -v inet6 |cut -d: -f2 |cut -d " " -f1 |cut -d . -f2`
	        IP=`ifconfig eth0 | grep inet | cut -d : -f 2 | cut -d " " -f 1`
	        BASE=`$IP | cut -d"." -f1-3`
	        NETWORK=`echo $BASE".0"`
	        NETMASK=`ifconfig eth0 | grep inet | cut -d : -f 4`
	        GATEWAY=`route | grep default | cut -b 17-32 | cut -d " " -f 1 | uniq`
		BROADCAST=`ifconfig eth0 |grep Bcast |cut -d : -f 3 | cut -d " " -f1`
		echo 'DEVICE=eth0' > $IFCFG0
		echo 'BOOTPROTO=static' >> $IFCFG0
		echo "IPADDR=$IP" >> $IFCFG0
		echo "NETWORK=$NETWORK" >> $IFCFG0
		echo "NETMASK=$NETMASK" >> $IFCFG0
		echo "BROADCAST=$BROADCAST" >> $IFCFG0
		echo 'STARTMODE=onboot' >> $IFCFG0
		echo 'TYPE=Ethernet' >> $IFCFG0

	fi
 done
}

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
echo " Updating PS1 "
changeps1
echo
echo " Setting up Gateway address "
checknet
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
