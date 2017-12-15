 /* Template for adhoc LMITHELP queries.  Good for viewing single records and
  * comparing raw mergefiles to SAS mvds. 
  */
options NOcenter;


data work.mergefile (drop= alias);
  infile 'BF19.MNX0422.MORMER';
  input @477 block $CHAR4.  @47 alias $CHAR1.;
  
  if alias eq '1' then delete;
run;


data tmp;
  set mergefile;
  /* This avoids having to recompile the regex for every obs. */
  if _n_ = 1 then 
    pattern_num = prxparse("/H/"); 
  if missing(pattern_num) then
    do;
      put 'ERROR: problem compiling regex';
      stop;
    end;
  retain pattern_num; 

  if prxmatch(pattern_num, block); 
run;
proc print data=_LAST_; run;
