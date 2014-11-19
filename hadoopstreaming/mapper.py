#!/usr/bin/python
import sys

delimiter = chr(1)
delimiter_col = chr(2)

# Here is the logic where you can remove certain characters to clean your data
# whitespace, non-alphanumeric from the string field
def clean(rawtext):
    result = ' '.join(elem.split())
    return result


for line in sys.stdin:
    line = line.strip()
    ingestdate,source,mfr,mpn,qtyavail,price = [ clean(elem) for elem in line.split(delimiter)]

    mykey = chr(2).join([source, mfr, mpn])
    myvalue = chr(2).join([ingestdate, qtyavail, price])
    print delimiter.join([mykey, myvalue])

