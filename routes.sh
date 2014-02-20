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
		sudo echo "up route add -net 172.16.0.0/16 gw 10.NET1.$ROUTE1.1" >> $IFACE
		sudo echo "up route add -net 10.97.250.0/24 gw 10.$NET1.$ROUTE0.1" >> $IFACE
		sudo echo "up route add -net 10.97.252.0/24 gw 10.$NET1.$ROUTE0.1" >> $IFACE
		sudo echo "up route add -net 10.97.254.0/24 gw 10.$NET1.$ROUTE0.1" >> $IFACE
	
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

#---- Main --------------------------------------------------------------------

echo " Checking OS "
checkos
echo " OS is $OS "
echo
echo " Setting up Gateway address "
checknet
echo

if [ "$OS"="Ubuntu" ]
then
	/etc/init.d/networking restart
else 
	echo " You will need to restart networking for this server"
fi
#---- End ---------------------------------------------------------------------
