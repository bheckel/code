#!/bin/bash

# contact.sh 90823911 98951301 42
# for i in `seq -w 5 9`; do contact.sh 90823911 98951301 $i; done

curl -X POST \
'http://rionapi-dev.unx.com/rest/contacts' \
-H 'Accept: application/hal+json;v=EDGE;q=1,application/json;v=EDGE;q=.8,text/plain;v=EDGE;q=.2' \
-H 'X-Orion-Principal-User:arynt\sesppt' \
-H 'Authorization: OWS xxxxxxxxxxxxxxxx' \
-H 'Host: rionapi-dev.unx.com' \
-H 'Content-Type: application/json;v=EDGE' \
-d '{"account":'${1}',"accountNameId":'${2}',"name":{"firstName":"t'${3}'","middleName":null,"lastName":"test","prefix":null,"suffix":null},"type":"CO","gender":null,"linkedInPublicUrl":null,"includeInRevegy":false,"jobTitle1":null,"jobTitle2":null,"assistantName":null,"managerId":null,"department":null,"functionalDomainId":null,"hierarchyLevelId":null,"inputSource":"Third Party","origin":5651132,"originDateTime":"2020-05-27T18:28:00.000Z","phones":[],"emailAddresses":[{"type":"Assistant","email":"xx@y.com"}],"address":null,"primaryPhone":null,"primaryEmail":"Assistant","opportunityId":null}'
