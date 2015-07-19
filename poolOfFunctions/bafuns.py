from pandas import DataFrame
import pandas as pd
import numpy as np
from datetime import datetime
from pandas.stats.moments import ewma
import inspect
from scipy.fftpack import dct, idct

__author__ = "Bin Wang"
__maintainer__ = "Bin Wang"
__status__ = "Development"
__version__ = "0.0.1"

"""
This is a module which contains a pool of trustworthy functions to calculate certain metrics from a pandas DataFrame
The team need to agree on, and then follow the 'interface' as indicated by the myFunctionTemplate.

All functions need to:

1. be in the format of myFunctionTemplate
2. read input.csv as the test input and doctest-ed

"""


def testMax(l=[1,2,3]):
    return max(l)

def testMin(l=[1,2,3]):
    return min(l)


def myFunctionTemplate(tsData):
    #tsData has to be:
    #1. a panda DataFrame:
    #2. contains column ingestdate in string format 'YYYYmmhh' 
    #3. contains coumn qtyavail 
   
    """
    >>> data = pd.read_csv('input.csv')
    >>> data.shape
    (2005, 2)
    >>> myFunctionTemplate(data)
    {'method': 'myFunctionTemplate'}
    """
    tsData['ingestdatetime'] = tsData.apply(lambda row: datetime.strptime(str(row['ingestdate']), "%Y%m%d"), axis=1)
    tsData = tsData.sort(['ingestdate'], ascending=[1])

    # Your Logic Goes Here

    result = {}
    result['method'] = inspect.stack()[0][3]
    return result


##################################
# YOUR CODE SHOULD GO BELOW HERE #
##################################

def outlier_removal_smoothing_none(tsData):
    """
    >>> data = pd.read_csv('input.csv')
    >>> outlier_removal_smoothing_none(data)
    {'buy': 128555888, 'sale': 140672986, 'method': 'outlier_removal_smoothing_none'}
    """
    
    tsData['ingestdatetime'] = tsData.apply(lambda row: datetime.strptime(str(row['ingestdate']), "%Y%m%d"), axis=1)
    tsData = tsData.sort(['ingestdate'], ascending=[1])

    diffs = np.diff(tsData['qtyavail'])
    result_sale = abs(sum(filter(lambda x: x < 0, diffs)))
    result_buy = abs(sum(filter(lambda x: x > 0, diffs)))

    result = {}
    result['sale'] = result_sale
    result['buy'] = result_buy
    result['method'] = inspect.stack()[0][3]
    return result


def outlier_removal_smoothing_ewma(tsData):
    """
    >>> data = pd.read_csv('input.csv')
    >>> outlier_removal_smoothing_ewma(data)
    {'buy': 43904257, 'sale': 55054485, 'method': 'outlier_removal_smoothing_ewma'}
    """
    
    tsData['ingestdatetime'] = tsData.apply(lambda row: datetime.strptime(str(row['ingestdate']), "%Y%m%d"), axis=1)
    tsData = tsData.sort(['ingestdate'], ascending=[1])
    tsData['qtyavail_ewma'] = ewma(tsData['qtyavail'], span=50)

    diffs = np.diff(tsData['qtyavail_ewma'])
    result_sale = abs(sum(filter(lambda x: x < 0, diffs)))
    result_buy = abs(sum(filter(lambda x: x > 0, diffs)))

    result = {}
    result['sale'] = int(result_sale)
    result['buy'] = int(result_buy)
    result['method'] = inspect.stack()[0][3]
    return result


def outlier_removal_smoothing_dct(tsData, n):
    """
    >>> data = pd.read_csv('input.csv')
    >>> outlier_removal_smoothing_dct(data, 15)
    {'buy': 28833387.903209731, 'sale': 40508532.108399086, 'method': 'outlier_removal_smoothing_dct'}
    >>> outlier_removal_smoothing_dct(data, 20)
    {'buy': 30315166.377325296, 'sale': 42088164.543017924, 'method': 'outlier_removal_smoothing_dct'}
    """

    tsData['ingestdatetime'] = tsData.apply(lambda row: datetime.strptime(str(row['ingestdate']), "%Y%m%d"), axis=1)
    tsData = tsData.sort(['ingestdate'], ascending=[1])

    N = len(tsData)
    t = range(len(tsData))
    x = [float(elem) for elem in tsData['qtyavail']]
    y = dct(x, norm='ortho')
    window = np.zeros(N)
    window[:n] = 1
    yr = idct(y*window, norm='ortho')
    
    diffs = np.diff(yr)
    result_sale = abs(sum(filter(lambda x: x < 0, diffs)))
    result_buy = abs(sum(filter(lambda x: x > 0, diffs)))

    result = {}
    result['sale'] = result_sale
    result['buy'] = result_buy
    result['method'] = inspect.stack()[0][3]
    return result


if __name__ == '__main__':
    import doctest
    doctest.testmod()

