options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sortsortmerge.formats.sas
  *
  *  Summary: Fast alternative to the traditional sort-sort-merge lookup.
  *           Apparently 75% faster.
  *
  *  Adapted: Fri 03 Mar 2006 09:24:25 (Bob Heckel --
  *                        http://www2.sas.com/proceedings/sugi30/054-30.pdf)
  * Modified: Wed 14 Jan 2009 13:33:37 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter fullstimer;

 /* Delete macro or comment out ENDSAS to compare (CARDS doesn't work inside
  * macros) 
 */
  data largefile;
    infile cards;
    input keyvar $  b;
    cards;
 k1 2
 k3 4
 k5 6
 k7 8
 k3 0
    ;
  run;
   /* ----Sort---- */
  proc sort; by keyvar; run;

   /* Only care about data in largefile that relates to the employee id
    * numbers we have here 
    */
  data keyfile;
    infile cards;
    input keyvar $;
    cards;
 k66
 k3
    ;
  run;
   /* ----Sort---- */
  proc sort NODUPKEY; by keyvar; run;

   /* ----Merge---- */
  data matched;
    merge largefile(in=ina) keyfile(in=inb);
    by keyvar;
    if ina and inb;
  run;
  proc print data=_LAST_(obs=max); run;
 /*
  *  Obs    keyvar    b
  *
  *  1       k3       4
  *  2       k3       0
  */



 /* Fast alternative to sort-sort-merge:::::::::::::::::::::::::::::: */
data fmtkey; 
  set keyfile(keep=keyvar);
  /* These variables translate to the FORMAT values in the metadata (i.e.
   * FMTNAME, LABEL and START are SAS keywords)
   */
  FMTNAME = '$mykey'; /* any name not conflicting with existing fmts will do for fmtname and label */
  LABEL = '!!!youfounditarthur!!!';  /* warning - be sure your data doesn't hold this value */
  START = keyvar;     /* alternative:  rename keyvar=start;  */
run;
 /* If you ever need to use multiple keys, make changes similar to these:
  * ... (keep= city state) ...
  * ... start = trim(city)||trim(state); ...
  * if put(trim(city)||trim(state), $ctyst.) = '!!!youfounditarthur!!!'; ...
  */
proc sort data=fmtkey NODUPKEY; by start; run;

proc format CNTLIN=fmtkey; run;
title 'fyi - print format innards START/END are same';
proc format FMTLIB; run;

data matched; 
  set largefile;
  if put(keyvar, $mykey.) eq '!!!youfounditarthur!!!';
run;
title 'found these records in largefile based on keyvars in keyfile:';
proc print data=_LAST_(obs=max); run;



 /* Better? style from NESUG paper pm16 */
** Create a dataset to feed proc format **;
data key;
  set largefile(rename=(keyvar=START));
  retain fmtname '$key';
  HLO = ' ';
  output;
  if _N_ = 1 then do;
    START = 'other';
    HLO = 'o';
    LABEL = 'NO';
    output;
  end;
run;

** Create the format $key in the work library **;
proc format cntlin=key; run;
** Process the large dataset choosing only desired members **;
data both;
  set liba.members;
  where put(member_id,$key.) ne 'NO';
  admit_dt = input(put(member_id,$key.),yymmdd10.);
run;
 /* Only member_ids found on both datasets will be kept in the dataset both.
  * The SAS date value admit_dt on the admissions dataset is translated to a
  * label for purposes of the format, then translated back into a SAS date
  * value for both. 
  *
  * Another constraint on the format technique is size. Like the hash technique
  * below, since formats must fit into existing memory, there is a limit to the
  * size of dataset a format can handle. Also, using the format technique in
  * this way requires passing the entire large dataset. Only the indexed access
  * technique allows you to avoid that.
 */


 /* Lookup */
data control(keep= FMTNAME START LABEL);
  set partnamelookup(rename=(partcode=START partname=LABEL));
  retain FMTNAME 'partname';
run;
proc format cntlin=control; run;
data t;
  set order;
  partname = put(partcode, partname.);
run;

