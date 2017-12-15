options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: input_lastobs_only.sas
  *
  *  Summary: Capture only the last observation or record in a file like tac.
  *
  *  Created: Wed 25 Aug 2004 10:10:32 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;


data lastrecord;   
  infile 'c:\Temp\junk' end=eof;
  input @;
  if eof;
  input block $;
run;
proc print data=_LAST_; run;
