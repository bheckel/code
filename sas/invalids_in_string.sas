options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: invalids_in_string.sas
  *
  *  Summary: Select obs with invalid character(s) in a string.
  *
  *  Created: Fri 20 Feb 2004 12:43:33 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data tmp;
  length allboxes $15;
  input allboxes $;
  cards;
YNNNNNNNNNNNNNN
NNNNNNNNNNNNNNN
YYNNNNNNNNNNNNY 
Y NNNNNNNNNNNNN
YNNNNNNNNNNNNNN
YNNNNNNNNNNNNNY
NYNNNNNNNNNNNNN
YNYNNNNNNnNNNNN
YNNNNYYNYANNNNN
YYYYYYYYYYYYYYY
;
run;


data;
  set tmp;
  
  /* Only Y or N is a valid char.  Appears to work for ASCII or EBCDIC. */
  ycnt = length(compress(upcase(allboxes),
                                  compress(collate(0,255),'Y'))||'.')-1;
  ncnt = length(compress(upcase(allboxes),
                                  compress(collate(0,255),'N'))||'.')-1;

  /* Keep only the invalids. */
  if ycnt+ncnt lt 15;
run;
proc print; run;
