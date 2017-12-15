options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: linelength.sas
  *
  *  Summary: Determine the shortest and longest line lengths of a file.
  *
  *           TODO use STDIN somehow
  *
  *  Created: Tue 29 Apr 2003 08:33:21 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

filename F 'junk';

data work.sample;
  infile F;
  input block $;
run;

proc print; run;
