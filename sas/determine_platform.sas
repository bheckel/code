options nosource;
 /*---------------------------------------------------------------------------
  *     Name: determine_platform.sas
  *
  *  Summary: Windows detection.
  *
  *  Created: Wed 18 Dec 2002 12:19:25 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;


%macro IsWindows;
  %if &SYSSCP eq WIN %then
      %str(options nosource;);
  %else
    %put We are not on a Microsoftian planet;
%mend;
%IsWindows


 /* Same */
data _NULL_;
  if "&SYSSCP" eq 'WIN' then
    put 'Gates wins';
  else
    put 'Good, maybe you are on Unix';
run;
