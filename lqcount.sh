#!bin/bash

# bash wrapper to count the total number of long queries (>5sec) in mongo

mongo localhost/admin -u <userid> -p <password> --eval "function fn(op) {
  return (op.secs_running >5);
}

db.currentOp().inprog.filter(fn).length;"
