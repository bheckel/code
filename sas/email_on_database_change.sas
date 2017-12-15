 /*---------------------------------------------------------------------------
  *     Name: email_on_database_change.sas
  *
  *  Summary: Notify on change to database
  *
  * Created: Wed 19 Jul 2017 08:57:13 (Bob Heckel) 
  *---------------------------------------------------------------------------
  */
options ls=180 ps=max; libname l '/Drugs/FunctionalData';

%macro email_on_database_change;
  %let ATEB_STACK=%sysget(ATEB_STACK);
  %let ATEB_TIER=%sysget(ATEB_TIER);

  proc sql NOprint;
    select clientid into :CLIDS separated by ','
    from l.clientids_in_rxfilldata
/*DEBUG*/
/* where clientid ne 7 */
    ;
  quit;
  %put _user_;

  proc sql;
    connect to postgres as myconn (database=reporting authdomain=Postdb5Auth server='db-05.twa.taeb.com' readbuff=7000);

    create table todaycheck as select * from connection to myconn (
      select clientid
      from rxfilldata_parent
      where filldate > now()-'14 days'::interval

      union

      select clientid
      from sdfarchive
      where filldate > now()-'14 days'::interval
     ;
     );
  quit;

  /* Prepare for tomorrow's run */
  data l.clientids_in_rxfilldata;
    set l.clientids_in_rxfilldata todaycheck;
  run;
  proc sort data=l.clientids_in_rxfilldata NOdup; by clientid; run;

  %let NEWCLIDS=;
  proc sql;
    select distinct clientid into :NEWCLIDS separated by ','
    from todaycheck
    where clientid not in ( &CLIDS )
    ;

    create table newclients as
    select distinct clientid 
    from todaycheck
    where clientid not in ( &CLIDS )
    ;
  quit;

  data _null_;
    n_obs=attrn(open('work.newclients'), 'NOBS'); put n_obs=;
    if n_obs eq 0 then do;
      put 'DEBUG: no records found';
      stop;
    end;
    else do;
      put 'DEBUG: new record(s) exist ' n_obs=;
      /* to=('bob.heckel@ateb.com'); */
      to="('bob.heckel@taeb.com' 'tina.torey@taeb.com' 'James.ellaringattu@taeb.com')";
      /* file dummy email filevar=to subject="New db5 (&ATEB_STACK) clientid found: &NEWCLIDS"; put 'subj'; */
      file dummy EMAIL filevar=to subject="Potentially new db5 (&ATEB_STACK) clientid found: &NEWCLIDS";
      stop;
    end;
  run;
%mend;
%email_on_database_change;
