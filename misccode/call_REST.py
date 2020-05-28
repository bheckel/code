import base64
import hashlib
import hmac
import json
import requests
import sys

def make_digest(message, key):
    key = bytes(key).encode('UTF-8')
    message = bytes(message).encode('UTF-8')
    
    digester = hmac.new(key, message, hashlib.sha1)
    signature1 = digester.digest()
     
    signature2 = base64.standard_b64encode(signature1) 
    
    return str(signature2).encode('UTF-8')

def make_request(access_key, secret_key, url):
    print 'arg 1 ' + sys.argv[1]
    print 'arg 2 ' + sys.argv[2]

    url_without_query_string = url.split("?")[0]
    print 'url ' + url_without_query_string

    authorization_header = 'OWS ' + sys.argv[1] + ':' + make_digest('GET\n' + url_without_query_string, sys.argv[2])
    print 'auth ' + authorization_header

    headers = { "Authorization" : authorization_header,
                    "X-Orion-Principal-User": "carynt\\essppt"}
    
    res = requests.get(url, headers=headers)
    print(json.dumps(res.json()))


if __name__ == '__main__':
    if len(sys.argv) != 4:
        print("Invalid usage. Try: {} <ACCESS_KEY> <SECRET_KEY> <URL>")
        sys.exit(1)
    make_request(sys.argv[1], sys.argv[2], sys.argv[3])

