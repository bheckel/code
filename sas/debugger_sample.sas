options nosource;
 /*---------------------------------------------------------------------------
  *     Name: debugger_sample.sas
  *
  *  Summary: Code to use for stepping thru the SAS debugger.
  *           Only works for DATA steps, not PROCs.
  *
  *             / DEBUG  
  *
  *           added to the data statement forces a GUI window to popup and lets
  *           you step through that datastep (ONLY).
  *
  *           Control movement on the DEBUGGER LOG window 
  *           At the  '>' prompt, use these commands:
  *
  *           Pressing enter repeats 'step' by default.
  *           But you can program Enter like this:
  *           TODO how to paste this line to DEBUGGER LOG's >  ?
  *           enter step; ex _all_
  *           or
  *           enter step; ex _all_; list _all_
  *
  *           st            <---step (default, no need to type, just enter)
  *           st 2          <---step twice on each <CR>
  *           ex _all_      <---examine
  *           ex Tournum    <---examine
  *           go            <---run to the end
  *           go 5          <---run to line 5
  *           list _all_    <---see break/watch points, FILES, INFILES, etc.
  *                             including the current buffer
  *           list i        <---list INFILE info and the current buffer
  *           w Tournum     <---set watchpoint
  *           desc Tournum  <---get attributes of one or more variables
  *           set Tournum='France'
  *           help          <---GUI's html help
  *           qui           <---exit debugger
  *
  *           file:///C:/bookshelf_sas/lgref/z0379386.htm#z0379387
  *
  *  Adapted: Tue 04 Jun 2002 16:51:14 (Bob Heckel -- SASv8 Ref z0379345.htm)
  * Modified: Thu 21 Nov 2013 15:11:36 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options linesize=72 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=5 nostimer number serror merror
        noreplace datastmtchk=allkeywords nocenter;

data tours(drop=type) / DEBUG;
/***data tours(drop=type);***/
  retain Tournum;  /* uncomment to fix bug */
  input @1 type $  @;
  if type='H' then do;
    input @3 Tournum $20.;
    return;
  end;
  else if type='P' then do;
    input @3 Name $10.  Age 2.  +1 Sex $1.;
    output;
  end;
  /* Each tour is given a header ('H') line followed by one or more
   * participants ('P').   The header must be RETAINed across iterations.
   */
  datalines;
H Tour 101
P Mary E    21 F
P Lance A    3 F
H Tour 102
P Diesel S  79 M
P Tyler H   55 M
P Fran I    63 F
  ;
run;
proc contents;run;

 /* Can't step thru procs */
proc print data=tours;
  title 'Tour List';
run;
