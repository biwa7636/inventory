#!/usr/bin/python
import sys

delimiter_a = chr(1)
# TAB IS THE DEFAULT KEYVALUE SEPARATOR FOR HADOOP STREAMING
delimiter = '\t' 

# Here is the logic where you can remove certain characters to clean your data
# whitespace, non-alphanumeric from the string field

def clean(rawtext):
    result = ' '.join(elem.split())
    result = result.upper()
    return result


for line in sys.stdin:
    line = line.strip()
    ingestdate,source,mfr,mpn,qtyavail,price = [ clean(elem) for elem in line.split(delimiter_a) ]

    mykey   = delimiter_a.join([source, mfr, mpn])
    myvalue = delimiter_a.join([ingestdate, qtyavail, price])
    print delimiter.join([mykey, myvalue])
