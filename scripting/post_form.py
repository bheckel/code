# Adapted: 05-Dec-2022 (Bob Heckel - https://www.youtube.com/watch?v=StmNWzHbQJU&list=WL&index=15&t=340s)
import requests

#url = 'http://rshdev.com/cgi-bin/printenv.pl'
url = 'http://bheckel.f.org/np.pl'

data = {
  'myposttextbox': 'lkj'
}

while True:
    response = requests.post(url, data=data).text
    print(response)
