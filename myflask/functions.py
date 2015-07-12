import sys

def my_max(l):
    try:
        return max(l)
    except:
        return sys.exc_info()

def my_min(l):
    try: 
        return min(l)
    except:
        return sys.exc_info()

def my_min(l):
    try:
        return (sum(l)/len(l))
    except:
        return sys.exc_info()
