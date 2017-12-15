options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: ismormer.sas
  *
  *  Summary: Determine if file extension is MORMER.
  *
  *  Created: Fri 20 Jun 2003 09:28:39 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

%macro CkExtension(fn);
  %if %index(%scan(&fn,3,.), MORMER) %then
    %put is a MORMER;
%mend CkExtension;
%CkExtension(BF19.NMX0232.MORMER)
