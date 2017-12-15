*  Begin EG generated code (do not edit this line);
*
*  Stored process registered by
*  Enterprise Guide Stored Process Manager V7.1
*
*  ====================================================================
*  Stored process name: TestSTP
*
*  Description: test 06apr16
*  ====================================================================
*
*  Stored process prompt dictionary:
*  ____________________________________
*  CLINAME
*       Type: Text
*      Label: long_client_name
*       Attr: Visible, Required
*  ____________________________________
*;


*ProcessBody;

%global CLINAME;

%STPBEGIN;

*  End EG generated code (do not edit this line);


/* --- Start of code for "Program". --- */
libname l meta library='FuncData';


*%let wild=%nrstr(%%)&cliname.%nrstr(%%);
proc print data=l.clients_shortname_lookup;
  where lowcase(long_client_name) like "&cliname.";
run;
/* --- End of code for "Program". --- */

*  Begin EG generated code (do not edit this line);
;*';*";*/;quit;
%STPEND;

*  End EG generated code (do not edit this line);
