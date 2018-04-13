#!/bin/bash 

if [ -z "$1" ] ; then
  psql -U bheckel -h db-06.twa.taeb.com TAEBMART -c "
  select a.*,b.client_name
  from dshbrd.dashboardclients a join analytics.vtmmclient b on a.clientid=b.clientid
  order by a.clientid;
  ;"
else
  psql -U bheckel -h db-06.twa.taeb.com TAEBMART -c "
  select a.*,b.client_name
  from dshbrd.dashboardclients a join analytics.vtmmclient b on a.clientid=b.clientid
  where client_name ilike '%${1}%'
  order by a.clientid;
  ;"
fi

