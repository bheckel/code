options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: infile.oneobs.sas
  *
  *  Summary: Demo of reading a single record from an external file.
  *
  *  Created: Wed 01 Oct 2003 16:15:16 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

filename IN 'BF19.NCX0318.NATMER';

data work.tmp;
  length name $ 80  statename $ 8;
  infile IN filename=name obs=1;
  put name=;
  statename = trim(stname(substr(name,6,2)));
  put statename=;
  input @1 block $CHAR5.;
run;

proc print; run;
