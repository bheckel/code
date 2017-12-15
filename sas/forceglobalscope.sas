options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: forceglobalscope.sas
  *
  *  Summary: See Name:  One of the few places CALL ExECUTE appears to be
  *           useful.
  *
  *           Also see call_execute.sas
  *
  *  Adapted: Tue 24 Jun 2003 11:07:33 (Bob Heckel -- Ian Whitlock paper)
  *---------------------------------------------------------------------------
  */
options source;

 /* CALL SYMPUT chooses the environment for macrovariables that it creates,
  * local in this case. 
  */
%macro Scopetest;
  %local FOO;
  data _NULL_;
    x=66;
    call symput('FOO', x);
  run;
 %put !!!LOCAL> local available: &FOO;
%mend Scopetest;
%Scopetest
%put !!!GLOBAL> local no longer available: &FOO;


 /* Force scope to be global.  Can't reverse this process, local instead of
  * global. 
  */
%macro Listerinetest;
  data _NULL_;
    x=67;
    call execute('%global FOO2; %let FOO2 =' || x || ';');
    %put !!!LOCAL> global not yet available here: &FOO2;
  run;
%mend Listerinetest;
%Listerinetest
%put !!!GLOBAL> global available: &FOO2;
