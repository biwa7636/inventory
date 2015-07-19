import requests
import pandas as pd
import json

url = "http://127.0.0.1:8000/calc/"
data = {
    'function': 'testMax', 
    'data': pd.DataFrame([1,2,3,4]).to_json()
}
r = requests.post(url, data=json.dumps(data), headers={'Content-type': 'application/json', 'Accept': 'text/plain'})
print r.text


df = pd.DataFrame(
    {
    'ingestdate': ['20150101', '20150102', '20150103'],
    'qtyavail': [100, 50, 20]
    }
)

data = {
    'function': 'outlier_removal_smoothing_none',
    'data': df.to_json()
}

r = requests.post(url, data=json.dumps(data), headers={'Content-type': 'application/json', 'Accept': 'text/plain'})
print r.text
