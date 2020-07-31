#!/bin/bash

curl -X POST \
'http://rionapi-dev.unx.com/rest/accounts' \
-H 'Accept: application/hal+json;v=EDGE' \
-H 'X-Orion-Principal-User:arynt\bheck' \
-H 'Authorization: OWS xxxxxxxxxxxxxxxx' \
-H 'Host: rionapi-dev.unx.com' \
-H 'Content-Type: application/json' \
-d '{"independentConsultant":false,"name":"test account #'${1}'","noteBody":"y","noteSubject":"x","primaryAccountAttribute":{"industryId":34603,"physicalAddress":{"addressLine1":"666 500000th Rd","addressLine2":null,"addressLine3":null,"addressLine4":null,"city":"New York","stateOrProvince":"NY","countryId":8853,"usCounty":"New York County","postalCode":"10103"}},"salesGroup":"SA","tierId":null,"url":null,"usedInEstars":null}'

#curl --location --request POST 'http://rionapi-dev.unx.sas.com/rest/accounts' \
#--header 'X-Orion-Principal-User: arynt\bheck' \
#--header 'Authorization: OWS slfkjsflskfslkfs' \
#--header 'Accept: application/hal+json;v=EDGE' \
#--header 'Content-Type: application/json' \
#--data-raw '{
#  "independentConsultant": false,
#  "name": "Bobs Test Account for Hub 10",
#  "noteBody": "Bobs Test Account Note Body",
#  "noteSubject": "Bobs Test Account Note Subject",
#  "primaryAccountAttribute": {
#    "industryId": 34588,
#    "physicalAddress": {
#      "addressLine1": "123 Bob Heckel Avenue",
#      "addressLine2": null,
#      "addressLine3": null,
#      "addressLine4": null,
#      "city": "Bob Heckel City",
#      "stateOrProvince": null,
#      "countryId": 8853,
#      "usCounty": null,
#      "postalCode": null
#    }
#  },
#  "salesGroup": "SA",
#  "tierId": null,
#  "url": null,
#  "usedInEstars": null,
#  "verified": true
#}'
