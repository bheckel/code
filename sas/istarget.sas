options sasautos=(SASAUTOS '/Drugs/Macros') ls=140 ps=max mprint mprintnest NOcenter validvarname=any;%dbpassword;

%odbc_start(lib=work, ds=t, db=db6);
select a.tmmtgtbuildid, a.clientid, a.tmmtgtbuildstatusid, c.name, a.rundatacheck, a.builddate, a.projectedimport, a.lastmodified, a.importpath, a.note
from aar.tmmtgtbuild a left join aar.tmmtgtbuildconfig b on a.clientid=b.clientid
     join aar.tmmtgtbuildstatus c on a.tmmtgtbuildstatusid=c.tmmtgtbuildstatusid
     order by a.builddate;
%odbc_end;

%odbc_start(lib=work, ds=splits, db=db5);
  select clientid from clientinmdfarchive
  where firstfileimported > date('now')-150
%odbc_end;

libname funcdata '/Drugs/FunctionalData';
proc sql;
  create table t2 as
  select clientid, long_client_name, independent, mdfarchive
  from funcdata.clients_shortname_lookup
  ;
quit;

proc sql;
  create table t3 as
  select a.*, b.long_client_name, b.independent, b.mdfarchive, c.clientid as splitclid
  from t a left join t2 b on a.clientid=b.clientid
           left join splits c on a.clientid=c.clientid
  order by builddate
  ;
quit;  

proc print data=_LAST_ width=minimum heading=H noobs;
  var clientid long_client_name name independent mdfarchive splitclid builddate projectedimport lastmodified;
run;
