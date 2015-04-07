#!/bin/bash

# Simple script to check port is open on a list of mongo nodes

# Array of mongo config server shards
MONGOCFG=(mongocfg1.domain.com
mongocfg2.domain.com
mongocfg3.domain.com)

# Array of mongo shards
MONGO=(mongos1r1.domain.com
mongos1r2.domain.com
mongos1r3.domain.com)

# Array of servers
SERVER=(server1.domain.com
server2.domain.com
server3.domain.com
server4.domain.com
server5.domain.com
server6.domain.com
server7.domain.com
server8.domain.com
server9.domain.com)

portchk() {
  for node in "${MONGO[@]}"
  do
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no <userid>@$host "nc -z -w5 $node 10000";
      if [$? -eq 0]
      then
        echo "Success! == $host to port 10000 on $node";
      else
        echo "Error! == $host cannot connect to port 10000 on $node";
      fi
  done
}
  
portCFG()chk {
  for CFGnodes in "${MONGOCFG[@]}"
  do
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no <userid>@$host "nc -z -w5 $node 27019";
      if [$? -eq 0]
      then
        echo "Success! == $host to port 27019 on $CFGnode";
      else
        echo "Error! == $host cannot connect to port 27019 on $CFGnode";
      fi
  done
}

for host in "{SERVER[@]}"
do
  echo "Testing $host"
portchk
portCFGchk
done

