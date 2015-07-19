import requests


files = {'file': open('input.csv', 'rb')}
url = "http://127.0.0.1:8000/calc/"
r = requests.post(url, files=files)
print r.text
