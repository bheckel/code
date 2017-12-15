options nosource;
 /*---------------------------------------------------------------------
  *     Name: multi.sas
  *
  *  Summary: Tabulate the count of Y/N multi-race checkboxes.
  *
  *           See also the mainframe version MULTRCM
  *
  *  Created: Mon 10 Feb 2003 14:42:08 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options source;

filename IN 'BF19.ZZX0366.MORMER' LRECL=420;

data work.racedata;
  length name $ 35;
  infile IN FILENAME=name;
  /* Expanded Old format Mortality is 166, Expanded Old format Natality
   * is 277 for mother, 532 for father. 
   */
  input @166 (r1-r15) ($char1.);
  call symput('FNAME', name);
run;


data work.countboxes (keep= t1-t15);
  set work.racedata END=lastone;

  array rckboxes[*] r1-r15;
  array binaries[*] m1-m15;
  array totals[*] t1-t15;

  do i=1 to hbound(rckboxes);
    if rckboxes[i] = 'Y' then
      binaries[i]=1;

    totals[i]+sum(of binaries[i]);
  end; 
run;


data work.final;
  set work.countboxes END=lastone;
  /* The 'lastone' observation will be the total count of 'Y's. */
  if lastone then
    output;
run; 


proc print data=work.final LABEL NOOBS; 
  title "Count of 'Y' Race Checkboxes for &FNAME";
  label t1='White';
  label t2='Black';
  label t3='American Indian or Alaskan Native';
  label t4='Asian';
  label t5='Chinese';
  label t6='Filipino';
  label t7='Japanese';
  label t8='Korean';
  label t9='Vietnamese';
  label t10='Other Asian';
  label t11='Native Hawaiian';
  label t12='Guamanian';
  label t13='Samoan';
  label t14='Other Pacific Islander';
  label t15='Other';
run;




endsas;
 /* Contrast with this approch which is more tedious.  And proc sql won't
  * allow spaces in the titles.
  */
filename IN 'BF19.ZZX0366.MORMER' LRECL=420;

data work.racedata;
  infile IN;
  input wht $ 166  blk $ 167  aian $ 168  asian $ 169  chi $ 170  
        fili $ 171  japa $ 172  kor $ 173  viet $ 174  oas $ 175 
        nha $ 176  gua $ 177  sam $ 178  opi $ 179  oth $ 180 
        ;
  if wht = 'Y' then
    cwht+1;
  if blk = 'Y' then
    cblk+1;
  if chi = 'Y' then
    cchi+1;
  /* ... */
run;

proc sql;
  title 'Total Count of Race Blocks Checked:';
  select Max(cwht) as White, Max(cchi) as Chinese
  from work.racedata
  ;
quit;
