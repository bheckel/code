options nosource;
 /*---------------------------------------------------------------------------
  *     Name: is_defined.sas
  *
  *  Summary: Verifying the contents of variables.  NEW_FILE='' is !not! equal
  *           to NEW_FILE=
  *
  * Created: Thu Jan 16 11:16:05 2003 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source replace;

 /* This is considered a value! */
***%let NEW_FILE='';
%let NEW_FILE=;
%let NEWF=&NEW_FILE;

%macro IsDefined;
  ***%if &NEWF EQ '' %then  ;
  /* Bizarre, NEW_FILE= must be used. */
  %if &NEWF EQ   %then
    %put no it is not;
  %else
    %put yes it is;
%mend;
%IsDefined
