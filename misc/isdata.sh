#!/bin/bash 

echo "$TAEB_STACK $TAEB_TIER"

psql -t -U bheckel -h db-08.twa.taeb.com taeb -c "
select id, name, short_name from amc.clients where id in($1)
;"

echo '........................... Any data yet? ............................'
psql -t -U bheckel -h db-05.twa.taeb.com reporting -c "
  SELECT clientid, count(*) FROM rxfilldata_parent where clientid in($1) and filldate>CURRENT_DATE-7 group by 1;
;"
echo

echo '........................... Any RP data yet? ............................'
psql -t -U bheckel -h db-05.twa.taeb.com reporting -c "
  SELECT clientid, count(*) FROM sdfarchive where clientid in($1) and filldate>CURRENT_DATE-7 group by 1;
;"
echo
