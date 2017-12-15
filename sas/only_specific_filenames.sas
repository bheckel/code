options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: only_specific_filenames.sas
  *
  *  Summary: Continue only if a specific filename has been determined.
  *
  *  Created: Thu 10 Apr 2003 09:08:53 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

filename IN 'C:\cygwin\home\bqh0\code\sas\junk';

data _NULL_;
  length name $35;
  infile IN filename=name;
  name=substr(name, 30, 4);

  if name not in('AL', 'AK', 'junk') then
    abort ABEND;
  else
    put name "<---this is the expected filename";
run;
