import requests



data = {'function':'testMax', 'data': [1,2,3,4,5], }
url = "http://127.0.0.1:8000/calc/"
r = requests.post(url, data=data)
print r.text
