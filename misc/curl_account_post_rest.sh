#!/bin/bash

curl -X POST \
'http://rionapi-dev.unx.com/rest/accounts' \
-H 'Accept: application/hal+json;v=EDGE' \
-H 'X-Orion-Principal-User:arynt\bheck' \
-H 'Authorization: OWS xxxxxxxxxxxxxxxx' \
-H 'Host: rionapi-dev.unx.com' \
-H 'Content-Type: application/json' \
-d '{"independentConsultant":false,"name":"test account #'${1}'","noteBody":"y","noteSubject":"x","primaryAccountAttribute":{"industryId":34603,"physicalAddress":{"addressLine1":"666 500000th Rd","addressLine2":null,"addressLine3":null,"addressLine4":null,"city":"New York","stateOrProvince":"NY","countryId":8853,"usCounty":"New York County","postalCode":"10103"}},"salesGroup":"SA","tierId":null,"url":null,"usedInEstars":null}'
