from django.shortcuts import render
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from pprint import pprint
from datetime import datetime
import pandas as pd
from pandas.stats.moments import ewma
import numpy as np
import sys
import json

def myfunc_buy_sale(ts_quantity):
    diffs = np.diff(ts_quantity)
    result_sale = abs(sum(filter(lambda x: x < 0, diffs)))
    result_buy = abs(sum(filter(lambda x: x > 0, diffs)))
    return (result_sale, result_buy)


@csrf_exempt
def index(request):
    try:
        df = pd.read_json(request.body)
        df['ingestdatetime'] = data.apply(lambda row: datetime.strptime(str(row['ingestdate']), "%Y%m%d"), axis=1)
        df = df.sort(['ingestdate'], ascending=[1])
        df['qtyavail_ewma'] = ewma(df['qtyavail'], span=50)
        s, b = myfunc_buy_sale(data['qtyavail_ewma'])
        result = {'status':'success', 'sell':s, 'buy':b}
        return HttpResponse(json.dumps(result), content_type="application/json")
    except: 
        return HttpResponse(json.dumps({'status':'fail', 'reason':sys.exc_info()}), content_type="application/json")
