options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: hash_build_traverse_agg_save.sas
  *
  *  Summary: Using hashes
  *           - build tables in memory during program execution
  *           - traverse tables
  *           - aggregate data without pre-sorting or multiple passes
  *           - sort data
  *           - save the contents of a table to a file
  *
  * 1. Define all the variables in our hash tables for the PDV.
  * 2. Declare (create) a hash table (hash object) for the hospital lookup table.
  * 3. Declare an ordered hash table to hold the hospital summary table.
  * 4. Declare an ordered hash table to hold the patient/hospital summary table.
  * 5. Read each record from the CLAIMS data set.
  * 6. Look for HOSPID in the hospital hash table, in order to retrieve its HOSPTYPE.
  * 7. Accumulate info from the current claim into the hospital summary table (HSUM).
  * 8. Accumulate info from the current claim into the patient/hospital summary table (PSUM).
  * 9. If we’re done reading all the claims, write out the two summary tables.
  *
  * Adapted: Mon 20 Nov 2017 10:45:27 (Bob Heckel--SESUG 68-2017 Axelrod)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

 /* Unsorted data: */

data claims;
  infile cards;
  format admit disch MMDDYY8.;
  input patid :$2. admit :MMDDYY8. disch :MMDDYY8. hospid :$4. payment;
  cards;
P1 03/05/15 03/08/15 H111 1111.11
P1 01/03/16 01/09/16 H333 222.22
P1 10/12/16 10/15/16 H333 333.33
P2 05/05/15 05/06/15 H222 444.44
P2 09/16/15 10/01/15 H222 11.11
P2 12/01/15 12/15/15 H555 5555.55
P2 04/04/16 05/06/16 H111 7777.77
P2 06/06/16 06/08/16 H444 111.11
  ;
run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;
 
data hospitals;
  infile cards;
  input hospid :$4. hosptype :$8.;
  cards;
H111 ACUTE
H222 ACUTE
H333 REHAB
H444 PSYCH
  ;
run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;

/*
Have
 HOSPID Hospital ID
 HOSPTYPE Type of hospital, found in the HOSPITALS data set
Want
 N_CLMS Number of records found in the CLAIMS data set for each hospital
 TOT_PAY The sum of payments found in CLAIMS for each hospital

Have
 PATID Patient ID
 HOSPID Hospital ID
Want
 MIN_ADMIT Earliest admission date for this Patient/Hospital
 MAX_DISCH Latest discharge date for this Patient/Hospital

Desired result:
Obs    n_clms    tot_pay    hospid    hosptype

 1        2      8888.88     H111      ACUTE  
 2        2       455.55     H222      ACUTE  
 3        2       555.55     H333      REHAB  
 4        1       111.11     H444      PSYCH  
 5        1      5555.55     H555      ?      
                                                                                                                                                                                                                                                                
Desired result:
         min_        max_
Obs     admit       disch      patid    hospid

 1     03/05/15    03/08/15     P1       H111 
 2     01/03/16    10/15/16     P1       H333 
 3     04/04/16    05/06/16     P2       H111 
 4     05/05/15    10/01/15     P2       H222 
 5     06/06/16    06/08/16     P2       H444 
 6     12/01/15    12/15/15     P2       H555 
*/



 /* Pass through the data only once! */
data hosp_sum(keep=hospid hosptype n_clms tot_pay) pat_sum(keep=patid hospid min_admit max_disch);
  /****** Setup 3 hashes ******/
  /* Provide a "conduit" for communication between your hash table variables and their PDV counterparts */
  attrib n_clms length=4
         tot_pay length=8
         min_admit length=4 format=MMDDYY8.
         max_disch length=4 format=MMDDYY8.
         ;
  if 0 then set claims hospitals;

  if _N_ eq 1 then do;
    /* HID: Hospital ID table, for lookup and data retrieval */
    declare hash HID(dataset:'hospitals');  /* declare & instatiate simultaneously */
    HID.definekey('hospid');
    HID.definedata('hosptype');
    HID.definedone();
    call missing(of _all_);

    /* HSUM: Hospital summary hash table (empty) */
    declare hash HSUM(ordered:'A');  /* we want to order the output ds, ascending */
    declare hiter HIX('HSUM');
    HSUM.definekey('hospid');
    /* hospid is both key & value because we want it to populate in the hsum table */
    HSUM.definedata('hospid','hosptype','n_clms','tot_pay');
    HSUM.definedone();
    call missing(of _all_);

    /* PSUM: Patient/Hospital summary hash table (empty) */
    declare hash PSUM(ordered:'A');  /* we want to order the output ds, ascending */
    declare hiter PIX('PSUM');
    /* Two keys because we want summary measures for all unique combos of patid/hospid encountered in claims */
    PSUM.definekey('patid', 'hospid');
    PSUM.definedata('patid', 'hospid', 'min_admit', 'max_disch');
    PSUM.definedone();
    call missing(of _all_);
  end;
  /****************************/

  set claims end=EOF;

  /* call missing(hosptype); */
  /* Is the hopsital ID from the claim in the list of hospital IDs in the HID hash table? */
  rc=HID.find();
  found=(rc=0);

  /* If the result of a FIND() call is unsuccessful, then the value of the data item you are trying to retrieve, in this case HOSPTYPE, is not
   * automatically set to missing. Instead, it is the value of your last successfull call. That is why we're  explicitly assigning a value 
   * to HOSPTYPE if I did not find the HOSPID in the HID hash table.  Alternative is to add  call missing(hosptype);  prior to the find() line.
   */
  if not(found) THEN hosptype='?';

  /* Now see if this HOSPID is already in the HSUM hash table. If not, initialize the vars and add a new entry in the HSUM hash table */
  rc=HSUM.find();
  found=(rc=0);  /* '0' is success in hash-land */

  if not(found) then do;
    /* This HOSPID is not yet in the HSUM hash table so initialize the summary vars, then add a new entry in the HSUM hash table */
    n_clms = 0;
    tot_pay = 0;
    HSUM.add();
  end;

  /* In all cases, sum the vars, then replace the data in the hash table.  Note Items in a hash table are not reinitialized at each execution 
   * of a DATA step so we don't need a RETAIN.
   */
  n_clms = sum(n_clms, 1);
  tot_pay = sum(tot_pay, payment);
  HSUM.replace();

  /* Is this patient/hospital combo already in the PSUM hash table? If not, initialize the vars and add a new entry for the PATID/HOSPID in
   * the PSUM hash table
   */
  rc=PSUM.find();
  found=(rc=0);
  if not(found) then do;
    min_admit=.;
    max_disch=.;
    PSUM.add();
  end;

  /* Hold onto the earliest ADMIT and the latest DISCH dates for this PATID/HOSPID combo, then replace these values in the table */
  min_admit = min(admit, min_admit);
  max_disch = max(disch, max_disch);
  PSUM.replace();

  /* Are we done reading CLAIMS? If yes, write out the contents of the HSUM and PSUM hash tables. */
  if EOF then do;
    rc=HIX.first();
    do while(rc=0);
      /* Write each of the 5 unique hospid */
      output hosp_sum;
      rc=HIX.next();
    end;

    rc=PIX.first();
    do while(rc=0);
      /* Write each unique combo of patid/hospid */
      output pat_sum;
      rc=PIX.next();
    end;
  end;
run;

title 'sum by hospital'; proc print data=hosp_sum width=minimum heading=H;run;title;
title 'min max visits'; proc print data=pat_sum width=minimum heading=H;run;title;
