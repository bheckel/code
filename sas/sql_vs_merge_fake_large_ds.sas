options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sql_vs_merge_fake_large_ds.sas
  *
  *  Summary: Many-to-many in SQL then SAS example - calc creatinine formula
  *           using weight from a separate ds
  *
  *  Adapted: Thu 22 Jan 2015 15:11:34 (Bob Heckel -- http://www.lexjansen.com/pharmasug/2008/cc/cc07.pdf)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err fullstimer;


 /* Age and creatinine */
data lab;
  length lbtestcd $ 10 lbstresu $ 20 ;
  retain lbtestcd "CREAT" lbstresu "UMOL/L";
  do usubjid=1001 to 6000;
    if ranuni(0)<0.5 then sexcd=1;
    else sexcd=2;
    age=floor(47+sqrt(81)*rannor(1688));
    lbdt=floor(14535+sqrt(219950)*rannor(1688));
    do visitnum= 1 to 6 ;
      lbdt=lbdt+3;
      lbstresn = 70+sqrt(200)*rannor(1688);
      format lbdt yymmdd10.;
      label
        usubjid ='Unique Subject Identifier'
        sexcd ='Sex Code 1=male 2=female'
        age ='Age in Years'
        lbdt ='Parameter Measurement Date'
        lbstresn ='Parameter Value'
        lbtestcd ='Parameter Name'
        lbstresu ='Parameter Unit'
        visitnum ='Visit identifier (numeric)'
        ;
      output;
    end;
  end;
run; 
proc print data=_LAST_(obs=5) width=minimum; run;
proc sort data=lab; by usubjid lbdt; run; 

 /* Weight */
data vital(drop=i);
  length vstestcd $ 10 vsstresu $ 20;
  retain vstestcd "WEIGHT" vsstresu "KG";
  do usubjid=1001 to 6000;
    do i= 1 to 10 ;
      vsstresn = floor(74.5+sqrt(276)*rannor(1688));
      label
        vstestcd ='Vital Parameter Name'
        vsstresn ='Vital Parameter Value'
        vsstresu ='Vital Parameter Unit'
        ;
      output;
    end;
  end;
run;
proc sort data=vital; by usubjid; run;

data firstlab;
  set lab;
  by usubjid lbdt;
  if first.usubjid;
  keep usubjid lbdt;
run; 

data vital(drop=lbdt);
  retain vsdt;
  merge vital(in=a) firstlab(in=b); 
  by usubjid;
  if a;
  if first.usubjid then vsdt=lbdt-1;
  vsdt=vsdt-10;
  format vsdt yymmdd10.;
  label vsdt ='Vital Parameter Measurement Date';
run; 


/* Merge the LAB dataset with the VITAL dataset to get the last available
 * weight on or before serum creatinine measurement date. This is a
 * many-to-many merge, PROC SQL can finish this job quite easily while simply
 * using straight DATA step match merge will not produce the desired result.
 *
 * Calculate the creatinine clearance for each visit, which has a non-missing
 * serum creatinine record and has an available weight on or before such visit.
 */
proc sql;
  create table crcl (label='Creatinine Clearance Dataset') as
  select
    "CRCL" format $10. as lbtestcd label='Parameter Name',
    "ML/MIN" format $20.as lbstresu label='Parameter Unit',
    a.usubjid,
    a.sexcd,
    a.age,
    a.lbdt,
    a.visitnum,
    a.lbstresn as creat label='Parameter Measurement',
    b.vsstresn as weight label='Weight (KG)',
    b.vsdt label='Weight Measurement Date'
  from lab as a left join vital as b
  on a.usubjid=b.usubjid and a.lbdt>=b.vsdt
  where a.lbstresn ne .
  order by lbtestcd, lbstresu, usubjid, visitnum, lbdt, vsdt
  ;
quit; 
proc print data=_LAST_(obs=9) width=minimum; run;

 /* Compare (but takes 10 minutes) */
/*
data crcl;
  set lab(keep=usubjid visitnum lbdt lbstresn sexcd age rename=(lbstresn=creat)) end=eof;
  flag=0;
  do pi=1 to numobs;
    set vital(rename=(usubjid=subid vsstresn=weight)) point=pi nobs=numobs;
    if usubjid=subid and lbdt >= vsdt then do;
      flag=1;
      output;
    end;
    else if pi=numobs and flag=0 then do;
      weight=.;
      output;
    end;
  end;
  if eof then stop;
  drop subid flag; 
run;
*/

/* ... calculation of Cockroft-Gault not included */
