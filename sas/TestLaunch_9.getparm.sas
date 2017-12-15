 /* Apparently the only version that doesn't crash: */


 /* http://rtpsawn321/links/batchUTC_9.asp */

* Section 1: Initialization - Do Not Change (except for the #);
  OPTIONS NOMLOGIC NOMPRINT SYMBOLGEN PAGESIZE=max NOCENTER;

* Section 2: Change according to procedure step;

%GLOBAL HSqlXMSG HSqlXRC DbServer DbId DbPsw CondCode ServerName;
%LET CondCode=0;
%GetParm(SasServer, CtlDir, N);      %LET CtlDir = &parm;
%GetParm(SasServer, ServerName, N);  %LET ServerName = &parm;
%GetParm(DbServer, ServerName, N);   %LET DbServerName = &parm;
%GetParm(DbServer, SysOperId, N);    %LET DbId = &parm;
%GetParm(DbServer, SysOperPsw, Y);   %LET DbPsw = &parm;
%GetParm(LimsServer, ServerName, N); %LET LimsPath = &parm;
%GetParm(LimsServer, UserId, N);     %LET LimsId = &parm;
%GetParm(LimsServer, UserPsw, Y);    %LET LimsPsw = &parm;

%put _all_;

libname ORALINKS oracle user=&DbId password=&DbPsw path=&DbServerName;

proc sql NOPRINT;
  select distinct quote(left(trim(meth_spec_nm))) into :ITR separated by ','
  from ORALINKS.indvl_tst_rslt
  ;
quit;

* Section 3: Cleanup and Exit - Do Not Change;
ENDSAS; 
