import requests

#url = 'http://rshdev.com/cgi-bin/printenv.pl'
url = 'http://bheckel.sdf.org/np.pl'

data = {
  'myposttextbox': 'lkj'
}

response = requests.post(url, data=data).text

print(response)
