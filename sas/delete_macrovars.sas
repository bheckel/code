options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: delete_macrovars.sas
  *
  *  Summary: Delete specific macro variables from the symbol table.
  *
  *           Caution - running the data _null_ that deletes the mvars must
  *           occur outside the macro where the mvars exist!
  *           E.g. this doesn't delete TVARs:
  *           ...
  *             DATA _NULL_;
  *               SET mvars;
  *               IF SCOPE = 'GLOBAL' AND NAME =: 'TVAR' THEN
  *                 CALL EXECUTE('%SYMDEL '||TRIM(LEFT(NAME))||';');
  *               RUN;
  *             %PUT _USER_;
  *           %mend LELimsGist;
  *           %LELimsGist;
  *           ...
  *
  *  Adapted: Thu Aug 17 13:29:52 2006 (Bob Heckel -- http://support.sas.com/faq/index.html)
  * Modified: Mon 14 May 2007 12:37:57 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

%let foo1=bar;
%let foo2=baz;
%let zoo=xyz;

%macro DelVars;
  /* 2 datastep approach is mandatory */
  data mvars;
    set sashelp.vmacro;
  run;
  proc print data=_LAST_(obs=max); run;

  data _null_;
    set mvars;
    /* Case sensitive, mvars are always in uppercase */
    if scope='GLOBAL' and name =: 'FOO' then
      call execute('%symdel '||trim(left(name))||';');
  run;
%mend;
%DelVars

%put !!! &foo1;
%put !!!! &foo2;
%put !!!! &zoo;
