options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: many_to_many_inside_daterange.sas
  *
  *  Summary: Demo of complex merge to include CM data inside an AE range.
  *
  *           You want to know if a concomitant medication was given to a
  *           patient during the time of the adverse event.
  *
  *           Complicated join.
  *
  * Adapted: Wed 07 Nov 2012 15:32:33 (Bob Heckel--Jack Shostak pharma book)
  * Modified: Fri 19 Sep 2014 09:02:32 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data aes;
/***  informat ae_start date9. ae_stop date9.;***/
/***  input @1 subject $3.***/
/***        @5 ae_start DATE9.***/
/***        @15 ae_stop DATE9.***/
/***        @25 adverse_event $15.;***/
  /* Cleaner approach: */
  input @1 subject $3.  @5 ae_start :DATE9.  @15 ae_stop :DATE9.  @25 adverse_event $15.;
  datalines;
101 01JAN2004 02JAN2004 Headache
101 15JAN2004 03FEB2004 Back Pain
102 03NOV2003 10DEC2003 Rash
102 03JAN2004 10JAN2004 Abdominal Pain
102 04APR2004 04APR2004 Constipation
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; format ae_start ae_stop DATE9.; run;

data conmeds;
  input @1 subject $3.  @5 cm_start :DATE9.  @15 cm_stop :DATE9.  @25 conmed $20.;
  datalines;
101 01JAN2004 01JAN2004 Acetaminophen
101 20DEC2003 20MAR2004 Tylenol w/ Codeine
101 12DEC2003 12DEC2003 Sudafed
102 07DEC2003 18DEC2003 Hydrocortisone Cream
102 06JAN2004 08JAN2004 Simethicone
102 09JAN2004 10MAR2004 Esomeprazole
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; format cm_start cm_stop DATE9.; run;

/* Keep medications that started or stopped during an adverse event or entirely
 * spanned across an adverse event.
 */
proc sql;
  create table ae_meds as
  select a.subject, a.ae_start, a.ae_stop, a.adverse_event, c.cm_start, c.cm_stop, c.conmed
  from aes as a left join conmeds as c on a.subject=c.subject
  and  /* WHERE is also an option, see below output, but it's not really a LEFT JOIN then */
  ( 
    /* Started or stopped during (between) an AE: */
    ( (a.ae_start <= c.cm_start <= a.ae_stop) or (a.ae_start <= c.cm_stop  <= a.ae_stop) )
    or
    /* Spanned an entire AE: */
    ( (c.cm_start < a.ae_start) and (a.ae_stop < c.cm_stop) )
  );
quit;
proc print data=_LAST_(obs=max) width=minimum; run;
/*  Using AND
Obs    subject    ae_start    ae_stop    adverse_event     cm_start    cm_stop    conmed

 1       101        16071      16072     Headache            16071      16071     Acetaminophen       
 2       101        16071      16072     Headache            16059      16150     Tylenol w/ Codeine  
 3       101        16085      16104     Back Pain           16059      16150     Tylenol w/ Codeine  
 4       102        16073      16080     Abdominal Pain      16079      16140     Esomeprazole        
 5       102        16073      16080     Abdominal Pain      16076      16078     Simethicone         
 6       102        16012      16049     Rash                16046      16057     Hydrocortisone Cream
 7       102        16165      16165     Constipation            .          .                         
*/
/*  Using WHERE
Obs    subject    ae_start    ae_stop    adverse_event     cm_start    cm_stop    conmed

 1       101        16071      16072     Headache            16071      16071     Acetaminophen       
 2       101        16071      16072     Headache            16059      16150     Tylenol w/ Codeine  
 3       101        16085      16104     Back Pain           16059      16150     Tylenol w/ Codeine  
 4       102        16073      16080     Abdominal Pain      16079      16140     Esomeprazole        
 5       102        16073      16080     Abdominal Pain      16076      16078     Simethicone         
 6       102        16012      16049     Rash                16046      16057     Hydrocortisone Cream
*/
