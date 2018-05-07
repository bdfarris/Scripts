#!/usr/bin/python
import sys
from optparse import OptionParser
usage = "usage: %prog [options]"
parser = OptionParser(usage=usage)
parser.add_option("-f", "--file", dest="filename",                  help="write report to FILE", metavar="FILE")
(options, args) = parser.parse_args()

print "Enter the name list you'd like"
name = raw_input("?")
print "What is the beginning of the range(number)?"begin = raw_input()
print "What is the ending of the range(number)?"end = raw_input()
wtf = raw_input("Do you want to save output to a file y/n: ?")
if wtf == "y" or wtf == "yes" or wtf == "Y" or wtf == "Yes" :   
  f = open('output.txt','w')   
  for i in range(int(begin), int(end) + 1):      
    list = (name) + str(i)      
    f.write(list + '\n')      
    print list
f.close()
if wtf == "n" or wtf == "no" or wtf == "N" or wtf == "No" :   
  for i in range(int(begin), int(end)):      
    list = (name) + str(i)      
    print list
