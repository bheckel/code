
/* Connect to the SAS metadata server */
options metaserver = "sas-01.twa.taeb.com"
        metaport = 8561
        metauser = "sasadm@saspw" 
        metapass = "X"
        metarepository = Foundation
        metaprotocol = bridge
    ; 

/* Extract user information from the SAS metadata */
%mduextr(libref=work);

/* Combine data from multiple tables */
data work.metadata_users (drop=keyid);
  merge  
    work.person (keep=keyid name DisplayName title description in=user)
    work.logins (keep=keyid UserID)
    work.groupmempersons_info (keep=memid name rename=(name=groupname memid=keyid))
    work.email (keep=keyid emailAddr)
    ;
  by keyid;
  if user;
run;

proc sort data=work.metadata_users;
  by name groupname;
run;

/* Blank out duplicate information */
data work.metadata_users_ready;
  set work.metadata_users;
  by name;
  array a [*] name DisplayName title description emailAddr UserID;
  if not first.name then
  do i=1 to dim(a);
    a[i] = '';
  end;
run;

filename fout '/Drugs/Personnel/bob/user-roster.html';

/* Generate report on SAS metadata users and their groups */
ods html file=fout;
title "SAS Metadata Registered Users (as of %sysfunc(putn(%sysfunc(datetime()),datetime19.)))";
proc print data=work.metadata_users_ready noobs label;
  var name DisplayName title description emailAddr UserID groupname;
  label
    name = 'User Name'
    DisplayName = 'Display Name'
    title = 'Job Title'
    description = 'Description'
    emailAddr = 'Email Address'
    UserID = 'User ID'
    groupname = 'Member of Group'
    ;
run;
ods html close;
