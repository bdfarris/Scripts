#!/bin/bash

# script to check for long running queries in mongo assuming long queries are greater than 5sec
# bash wrapper around json query

mongo localhost/admin -u <userid> -p <password>
--eval "db.currentOp().inprog.forEach( function(op) { if(op.secs_running >5) printjson(oo);})"
