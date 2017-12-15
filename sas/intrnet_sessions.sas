%global save_me;  /* persistent */

 /* PAGE LOAD 1 */
 /* http://parsifal/cgi-sas/broker?_DEBUG=131&_SERVICE=default&_PROGRAM=intrcode.t.sas  */
%macro one;
  %let rc=%sysfunc(appsrv_session(create));

  %let spath=%sysfunc(pathname(SAVE));
  %put !!!a &spath;
  /* SAVE is an IntrNet keyword.  SAVE.foo is persistent */
  data SAVE.foo;
    set SASHELP.shoes (obs=10);
  run;
  %let save_me=foo;
  data _null_; 
    put "!!! &_SESSIONID"; 
    put "!!! &_THISSESSION"; 
    put "!!! &_REPLAY"; 
  run;
%mend one;
***%one;


 /* PAGE LOAD 2 (dataset still exists for the session created in %one) */
 /* http://parsifal/cgi-sas/broker?_DEBUG=131&_SERVICE=default&_PROGRAM=intrcode.t.sas&_SESSIONID=PbjTy6KbJ52 */
 /* note _SESSIONID=..., _PORT=... and _SERVER=... are from previous run (or
  * just use _REPLAY but it appears to be broken).  See also _THISSESSION to
  * get the _SERVER, _PORT, _SESSIONID info via copy 'n' paste.
 */
%macro two;
  ods html body=_webout;
  proc print data=SAVE.foo(obs=max); run;
  ods html close;
  %put &save_me;
%mend two;
%two;


%put _ALL_;

