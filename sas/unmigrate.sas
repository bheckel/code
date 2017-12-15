options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: unmigrate.sas
  *
  *  Summary: Use before FTP get, etc. to demigrate mainframe files.
  *           Will give errors but start the unmigration process if files are
  *           migrated.  Will do nothing if they're not migrated.
  *
  *  Created: Thu 08 Jul 2004 12:23:12 (Bob Heckel)
  * Modified: Wed 02 Mar 2005 13:28:52 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOs99nomig;

***filename F1 'dwj2.flmor03o.usres';
***filename F2 'dwj2.flmor03r.usres';

options NOcenter NOs99nomig;
%macro ForEach(s);
  %local i f;

  %let i=1;
  %let f=%qscan(&s, &i, ' '); 

  %do %while ( &f ne  );
    %let i=%eval(&i+1);   /* IMPORTANT */
    /*..............................................................*/
    %let state=%substr(&f, 6, 2);
    filename F "&f";
    /*..............................................................*/
    %let f=%qscan(&s, &i, ' '); 
  %end;
%mend ForEach;
%ForEach(
BF19.AKX0216.MEDMER
BQH0.CAX0402.NATMER
)
