options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sysparm_cmdline_infile_magic.sas
  *
  *  Summary: Accept parameters from the commandline
  *
  *  Adapted: Tue 21 Jun 2011 11:54:34 (Bob Heckel--http://www.excursive.com/sas/weblog/archive/2006_04_01_index.html)
  *---------------------------------------------------------------------------
  */
options source NOcenter;


 /* DEBUG */
 /***options sysparm='value=37.2 start=01jan2006, end=01mar2006';***/

data _null_;
  /* Optionally override default from command line */
  retain repeats 2.;
  infile cards;
  informat start end date9.;
  input @;
  _infile_ = translate(symget('SYSPARM'), ' ', ',');
  input start= end= value= repeats=; 
  format start end date9.;
  put (_all_) (=);
  call symput('myrepeats', repeats);
  stop;
  /* Must be a blank space */
  cards;

  ;;;; 
run;

%put _all_;


endsas;
Parms can appear in any order
$ sas -sysin sysparm_cmdline_infile_magic.sas -sysparm 'value=37.2 start=01jan2006, end=01mar2006' -log t.log
$ sas -sysin sysparm_cmdline_infile_magic.sas -sysparm 'repeats=42 value=37.2 start=01jan2006, end=01mar2006' -log t.log
