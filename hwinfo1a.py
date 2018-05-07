#!/usr/bin/python
import platform,subprocess
import commands
import os

print 'node     :', platform.node()
print 'release  :', platform.release()
print 'cpu type :', commands.getoutput("cat /proc/cpuinfo | grep 'model name' |uniq |awk '{print $4 $5 $6 $7 $8  $9 $10 $11}'")
print 'cpu(s)   :', commands.getoutput("grep -c processor /proc/cpuinfo")
print 'mem(kb)  :', commands.getoutput("free -m | grep Mem: | awk '{print $2}'")
