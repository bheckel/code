/*----------------------------------------------------------------------------
 * Program Name: input_hierarch.sas
 *
 *      Summary: Demo subsetting if and hierarchical file reading
 *
 *      Created: Wed Apr 21 1999 08:18:14 (Bob Heckel)
 * Modified: Fri 25 Jun 2010 13:07:47 (Bob Heckel)
 *----------------------------------------------------------------------------
 */
options linesize=180 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=3 nostimer number serror merror;

title; footnote;

 /* One observation per detail record */
data work.health(drop=type);
  infile CARDS;
  retain idnum;
  input type $1.  @;
  if type = 'H' then  /* header raw record */
    input @3 idnum $4.;
  /* Subsetting IF -- if not true, sends program back to beginning of data step
   * (different from IF...THEN which lets step continue even when false).  If this
   * happens we still haven't lost the idnum since we've RETAINed it.
   */
  if type eq 'D';  /* detail raw record */
  input @3 date MMDDYY6.  +1  chol 5.;
  put '!!!implied OUTPUT here (i.e. lines 2,3,5,6,7,9 write): ' _all_;  /* important pedantically */
  cards;
H 1891
D 010891 172.53
D 011791 181.93
H 1101
D 030991 183.63
D 051991 179.63
D 052879 164.33
H 2909
D 010260 390.3
;
run;
/*
Obs    idnum      date     chol

 1     1891     910108    172.5
 2     1891     910117    181.9
 3     1101     910309    183.6
 4     1101     910519    179.6
 5     1101     790528    164.3
 6     2909     600101    390.3
 */
proc print data=work.health; format date yymmdd6.; run;
/* 
 * IDNUM  N Obs        Mean
 * -------------------------
 * 1101     3         175.8
 * 1891     2         177.2
 * 2909     1         390.3
 */
proc means mean maxdec=1;
  class idnum;
  var chol;
run;
proc sort data=health; by idnum;run;
proc transpose;
  by idnum;
  var chol;
run;
proc print data=_LAST_(obs=max) width=minimum; run;



filename F 'input_hierarch.dat';
data supplies/*(drop= type amt)*/;
  infile F end=last;
  retain dept ext;
  input type $1.  @;
  if type eq 'D' then do;
    if _N_ gt 1 then do;
      put "!!! we're on 5th raw record so write the 1st obs " _ALL_;
      output;
    end;
    tot = 0;
    input @3 dept $10. @17 ext $5.;  /* header record */
  end;
  else if type eq 'S' then do;
    input @17 amt COMMA5.;
    tot+amt;
    if last then do;  /* no more (D)epartments exist so OUTPUT what we have built */
      output;
    end;
  end;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
/*
Obs       dept        ext     type     tot      amt

 1     Accounting    x3808     D      16.50     .  
 2     Personnel     x3810     S      12.33    3.35
 */

endsas;
input_hierarch.dat:
D Accounting    x3808
S Paper Clips   $2.50
S Paper         $4.95
S Binders       $9.05
D Personnel     x3810
S Markers       $8.98
S Pencils       $3.35
