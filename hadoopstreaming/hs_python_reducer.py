#!/usr/bin/python
import sys
mydelimiter = chr(1)

def myfunction(inputList):
    result = len(inputList)
    return str(result)

firstline = sys.stdin.readline().strip()
fields = firstline.split(mydelimiter, 1)
mykey_current = fields[0]
myvalue_array = [fields[1]]

for line in sys.stdin:
    fields = line.strip().split(mydelimiter, 1)
    mykey_new, myvalue_new = fields

    if mykey_new == mykey_current:
        myvalue_array.append(myvalue_new)
    else:
        # Different Key
        # (1): process existing values
        result = myfunction(myvalue_array)
        print mydelimiter.join([mykey_current, result])
        # (2): reset key, value
        mykey_current = mykey_new
        myvalue_array = [myvalue_new]

# LAST LINE
result = myfunction(myvalue_array)
print mydelimiter.join([mykey_current, result])


