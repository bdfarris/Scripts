#!/bin/bash -x

# Version 2.0
# Changes Created flags so strings do not need to be set manually
#
# Version 1.0
# Script first created requires strings to be set manually
#

while getopts "O:I:S:K:h-" opt ; do
	case "$opt" in
       	h) usage ; exit 0 ;;
    	O) OS="$OPTARG" ;;
        I) SSHIDENT="$OPTARG" ;;
    	S) SERVERLIST="$OPTARG" ;;
        K) KEY="$OPTARG" ;; 
    	-) break ;;
      	*) usage 1>&2 ; exit 1 ;;
    	esac
done

# Remove arguments as they are set
shift $(($OPTIND - 1))

# Print script usage and flags. All flags must be set
usage() {

   echo "Usage: pushkey.sh -O -I -S -K"
   echo ""
   echo "Copies a public key to the authorized_keys folders"
   echo "for a list of Ubuntu servers or list of Centos servers"
   echo ""
   echo "-O : Specify ubuntu or centos"
   echo "-I : Specify path to your SSH Ident key"
   echo "-S : Specify path to server list ubuntu or centos"
   echo "-K : Specify path to key file to be appended to authorized keys"
   echo ""
   echo "Example: "
   echo "pushkey.sh -O ubuntu -I /Users/<username>/.ssh/v2root.pem -S /Users/<username>/ubuntuservers -K /Users/<username>/keys2add"
   exit 1
}

# Make sure all flags have been set or run usage
if [ $# -ne "0" ]
then
	  usage
fi

# Push function checks supplied user and then runs the appropriate ssh command and appends the authorized
# key file for the procon user
push() {
	if [ "$OS" = "Ubuntu" ]
	then
		SSHUSER="ubuntu"
		for host in `cat $SERVERLIST`
		do

			cat $KEY | /usr/bin/ssh -i $SSHIDENT $SSHUSER@$host "sudo tee -a /home/<user>/.ssh/authorized_keys"

		done

	elif [ "$OS" = "centos" ]
	then
		SSHUSER="root"
		for host in `cat $SERVERLIST`
		do

			cat $KEY | /usr/bin/ssh -i $SSHIDENT $SSHUSER@$host "tee -a /home/<user>/.ssh/authorized_keys"

		done

	else
		echo "Incorrect OS specified. Specify either ubuntu or centos"

		usage
	fi
	}

push
