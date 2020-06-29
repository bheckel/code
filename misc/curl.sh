curl -X GET 'http://rion.sas.com/rest/contacts?firstName=J&lastName=Heckel&accountId=9999999' \
     -H 'Accept: application/hal+json;v=EDGE' \
     -H 'X-Rion-Principal-User:arynt\sppt' \
     -H 'Authorization: OWS myauthkey' \
     -H 'Host: rionapi.sas.com' \
     -d '{"account":00000911,"accountNameId":00051301,"name":{"firstName":"t2","middleName":null,"lastName":"test","prefix":null,"suffix":null},"type":"CO","opportunityId":null}'

