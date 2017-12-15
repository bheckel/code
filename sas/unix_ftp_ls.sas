options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: unix_ftp_ls.sas
  *
  *  Summary: Demo of using SAS's internal FTP feature to do an ls on a unix
  *           box while running this code on the MF.
  *
  *           Must specify which month you're interested in b/c it is
  *           difficult to parse the Unix date pieces for sorting.
  *
  *           Run on PC locally, not via Connect.
  *
  *  Created: Mon Oct 27 11:12:14 2003 (Bob Heckel)
  * Modified: Mon 22 Mar 2004 10:43:09 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* Unix ls style. */
%let CURRMO=Oct;

filename IN FTP
            CD='/home/bhb6/data/data1/' 
            HOST='tstdev'
            USER='bqh0'
            PASS='Rfranc10'
            list
            ;

data lsoutput (drop= perms links owner grp);
  infile IN;
  length name $32  size $10;
  /* Parse FTP's ls output. */
  input perms $  links $  owner $  grp $  size $  mo $  dy  yrtime $  
        name $
        ;
  /* Don't need the 'total' line. */
  if perms eq 'total' or name eq '..' then
    delete;

  if mo eq "&CURRMO";

  list;
run;


proc sort;
  by descending dy;
run;


proc print; 
  where name not contains 'library';
run;
