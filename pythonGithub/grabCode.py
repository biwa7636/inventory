import urllib2

url = "https://raw.githubusercontent.com/biwa7636/inventory/master/myflask/functions.py"
code = urllib2.urlopen(url).read()
print code
