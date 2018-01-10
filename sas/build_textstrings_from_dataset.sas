
data t;
  set funcdata.tmm_targeted_list_refresh;
  str="select * from aar.tmmtgt_client_build_config(_clientid:=" || strip(clid) || ")";
  str2="update aar.tmmtgtbuild set rundatacheck=false where clientid=" || strip(clid);
  str3="update aar.tmmtgtbuild set builddate=" || "'" || put(projected_build_date,DATE9.) || "'" || ' where clientid=' || strip(clid);
  put str=;
  put str2=;
  put str3=;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;


endsas;
select * from aar.tmmtgt_client_build_config(_clientid:=1233);
update aar.tmmtgtbuild set rundatacheck=false where clientid=1233;
update aar.tmmtgtbuild set builddate = '2018-01-22' where clientid=1233;
