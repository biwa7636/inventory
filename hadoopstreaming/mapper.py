#!/usr/bin/python
import sys
import re
delimiter_a = chr(1)
# TAB IS THE DEFAULT KEYVALUE SEPARATOR FOR HADOOP STREAMING
delimiter = '\t'
# Here is the logic where you can remove certain characters to clean your data
# whitespace, non-alphanumeric from the string field
 
# clean MPN
# [^a-zA-Z0-9_]
def clean_mpn(rawtext):
    result = re.sub(r'\W+', '', rawtext)
    return result
# remove whitespace
# change to upper case
def clean(rawtext):
    result = ' '.join(elem.split())
    result = result.upper()
    return result
 
for line in sys.stdin:
    line = line.strip()
    # general cleaning
    ingestdate,source,mfr,mpn,qtyavail,price = [ clean(elem) for elem in line.split(delimiter_a) ]
    # specific cleaning
    mpn = clean_mpn(mpn)
 
    # determine key and value
    mykey   = delimiter_a.join([source, mfr, mpn])
    myvalue = delimiter_a.join([ingestdate, qtyavail, price])
    print delimiter.join([mykey, myvalue])
