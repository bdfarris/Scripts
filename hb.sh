#!/bin/bash

# Simple script to check for heartbleed vulnerability
# requires root access and a list (named OPENSSL) of servers to check

command="hostname; openssl version"

connect() {
  if ! ssh -o "ConnectTimeout=4" -o "StrictHostKeyChecking=no" root@$host "$command"
  echo ""
  else
  echo ""
  fi
}

for host in `cat OPENSSL`
do
  connect
done

