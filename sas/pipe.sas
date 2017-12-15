 /*---------------------------------------------------------------------
  *     Name: pipe.sas
  *
  *  Summary: Demo of using pipes to speed up processing compressed 
  *           input files.
  *
  *           Sample run:
  *             $ zcat test1.txt.gz | sas pipe.sas
  *
  *           See also input.positional.sas
  *
  *  Adapted: Wed 25 Sep 2002 09:21:59 (Bob Heckel--sas.com TechTips
  *                                     David B. Horvath)
  * Modified: Wed 18 Oct 2017 10:42:46 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options linesize=72 pagesize=32767 nocenter date nonumber noreplace
        source source2 notes obs=max errors=5 datastmtchk=allkeywords 
        symbolgen mprint mlogic merror serror
        ;


  %if %sysfunc(fileexist("&path./&cl_foldername./ExternalFile/PE/*.csv")) %then %do; 
    %put &path./&cl_foldername./ExternalFile/PE/ is there;
    filename LSPIPE PIPE "ls -1 &path./&cl_foldername./ExternalFile/PE/";

    data tmp;
      infile LSPIPE PAD;
      input fn $80.;
    run;
  %end;
  %else %do;
    %put &path./&cl_foldername./ExternalFile/PE/ is not there;
  %end;



 /********** Unix only **********/
 /* Read it in. */
data work.testpipes1;
  infile STDIN;
  input @01 field1 $ 4.  @15 field2 $ 2.;
  output;
run;
proc print; run;


filename OUT 'outputjunk';
 /* Write it out. */
data _NULL_;
  set work.testpipes1;
  file OUT;
  put @1 field1  @20 field2;
run;

 /* Sample input:
----+----1----+----2----+
abcd11111efg2222222xx
hijk11111lmno223222
pqrs11111tuv2224222xx
 */


 /**********/

filename LSINFO PIPE 'ls /home/bqh0/tmp';

data tmp;
  infile LSINFO PAD;
  input fn $50.;
run;
proc print; run;

 /********** Unix only **********/



 /********** Windows only **********/
filename q PIPE 'dir "c:\junk\*.csv" /b';
data csvlist;
  infile q;
  input mem $;
run;

 /********** Windows only **********/
