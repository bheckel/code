//BQH0RAND JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=1,CLASS=F,REGION=0M             
//STEP1    EXEC SAS,TIME=100,OPTIONS='MEMSIZE=0'                        
//OUT      DD DISP=(NEW,CATLG,DELETE),UNIT=NCHS,
//            DSN=BQH0.TEST2003,
//            DCB=(LRECL=700,RECFM=FB),
//            SPACE=(CYL,(10,2),RLSE)
//WORK     DD SPACE=(CYL,(100,100),,,ROUND)                                     
//SYSIN    DD *                                                                 
options nosource;
 /*---------------------------------------------------------------------------
  *     Name: randomizer.sas
  *
  *  Summary: Create a randomly generated 2003 NCHS formatted textfile.
  *
  *  Created: Tue 26 Nov 2002 17:18:31 (Bob Heckel)
  * Modified: Fri 21 Feb 2003 15:51:33 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* Date of Death. */
%let YR=2003;
 /* Number of output file lines. */
%let LINES=5000;


%macro Ckplat;
  %if &SYSSCP=WIN %then
    filename OUTTXT "test&YR";
%mend;
%Ckplat;


 /* Not sure how the FIPS codes run so we're going conservative. */
%let NUM_STATES = 48;
 /* Subtract one from the real total. */
%let SSN_MAX = 999999998;
%let AGE_MAX = 135;
%let DOBYR_START = 1900;
%let DOBYR_MAX = 102;
%let DOBMON_MAX = 11;
%let DOBDAY_MAX = 30;


%macro Randomize(hi, lo, feed);
  /* -1 forces seed to be the current system clock */
  &feed = &hi*ranuni(-1) + &lo;
%mend Randomize;


proc format;
  value f_sex        0.0 - 0.3 = 'M'
                    0.31 - 0.6 = 'F'
                         OTHER = 'U';

  value f_yorn       0.0 - 0.3 = 'Y'
                    0.31 - 0.6 = 'N'
                         OTHER = 'U';

  value f_bool       0.0 -< 0.5 = 'Y'
                     0.5 - HIGH = 'N';
run;


 /* Create a dataset of randomly generated "names" */
data work.randnames (keep= name1-name3);
  do i=1 to &LINES;
    validchars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"; 
    totlen = length(validchars);
    /* Number between 1 and 26 */
    spos = int(totlen * ranuni(0) + 1);
    gofor = int((totlen-spos) * ranuni(0) + 1);
    ***put gofor=;
    name1 = substr(validchars, spos, gofor);
    /* Arbitrarily take only the first character. */
    name2 = substr(validchars, spos, 1);
    if spos < totlen-1 then
      do;
        if gofor > 2 then
          gofor = 2;
        name3 = substr(validchars, spos+2, gofor-1);
      end;
    else
      name3 = substr(validchars, spos, gofor);
    output;
  end;
run;


 /* Create the output (randomly generated) dataset. */
data work.randdata (drop= name1-name3 x1-x6);
  set work.randnames;
  dod_yr = &YR;
  /*       max add to lo  lo  variable name to fill */
  /*         ___________  _                         */
  %Randomize(&NUM_STATES, 1, fipnum);
  dstate = fipstate(int(fipnum));
  /* FIPS codes have holes that produce '--' */
  if dstate eq '--' then
    dstate='NC';
  ***put dstate=;
  ***put fipnum=;
  %Randomize(999998, 1, fileno);
  %Randomize(1, 0, void);
  %Randomize(999999999998, 1, auxno);
  %Randomize(2, 0, mfilled);
  gname = name3;
  mname = name2;
  lname = name1;
  suff = '';
  %Randomize(1, 0, alias);
  flname = name1;
  /* Uses f_sex */
  sex = ranuni(-1);
  %Randomize(1, 0, sex_bypass);
  %Randomize(&SSN_MAX, 1, ssn);

  array tmparr[*] x1-x6 (1 2 4 5 6 9);
  %Randomize(dim(tmparr), 1, arr_elem);
  agetype = tmparr[arr_elem];

  %Randomize(&AGE_MAX, 1, age);
  %Randomize(1, 0, age_bypass);
  %Randomize(&DOBYR_MAX, &DOBYR_START, dob_yr);
  %Randomize(&DOBMON_MAX, 1, dob_mo);
  %Randomize(&DOBDAY_MAX, 1, dob_dy);
  %Randomize(98, 1, bplace_cnt);
  %Randomize(&NUM_STATES, 1, fipnum);
  bplace_st = fipstate(fipnum);
  %Randomize(99998, 1, cityc);
  %Randomize(998, 1, countyc);
  %Randomize(98, 1, statec);
  %Randomize(98, 1, countryc);
  /* Uses f_yorn */
  limits = ranuni(-1);

  array tmparr2[*] $1 typ2_1-typ2_6 ('M' 'A' 'W' 'D' 'S' 'U');
  %Randomize(hbound(tmparr2), 1, arr_elem);
  /* arr_elem is floating pt but doesn't seem to matter. */
  marital = tmparr2[arr_elem];

  array tmparr3[*] x3_1-x3_4 (0 1 2 4);
  %Randomize(hbound(tmparr3), 1, arr_elem);
  marital_bypass = tmparr3[arr_elem];

  array tmparr35[*] x35_1-x35_8 (1 2 3 4 5 6 7 9);
  %Randomize(hbound(tmparr35), 1, arr_elem);
  dplace = tmparr35[arr_elem];

  ***cod = '   ';
  cod = 123;

  array tmparr4[*] $1 typ4_1-typ4_7 ('B' 'C' 'D' 'E' 'R' 'O' 'U');
  %Randomize(hbound(tmparr4), 1, arr_elem);
  disp = tmparr4[arr_elem];

  %Randomize(11, 1, dod_mo);
  %Randomize(30, 1, dod_dy);
  %Randomize(2359, 0, tod);
  %Randomize(7, 1, deduc);
  %Randomize(4, 0, deduc_bypass);
  dethnic1 = ranuni(-1);
  dethnic2 = ranuni(-1);
  dethnic3 = ranuni(-1);
  dethnic4 = ranuni(-1);
  dethnic5 = ' ';
  race1 = ranuni(-1);
  race2 = ranuni(-1);
  race3 = ranuni(-1);
  race4 = ranuni(-1);
  race5 = ranuni(-1);
  race6 = ranuni(-1);
  race7 = ranuni(-1);
  race8 = ranuni(-1);
  race9 = ranuni(-1);
  race10 = ranuni(-1);
  race11 = ranuni(-1);
  race12 = ranuni(-1);
  race13 = ranuni(-1);
  race14 = ranuni(-1);
  race15 = ranuni(-1);
  race16 = ' ';
  race17 = ' ';
  race18 = ' ';
  race19 = ' ';
  race20 = ' ';
  race21 = ' ';
  race22 = ' ';
  race23 = ' ';
  race1e = ' ';
  race2e = ' ';
  race3e = ' ';
  race4e = ' ';
  race5e = ' ';
  race6e = ' ';
  race7e = ' ';
  race8e = ' ';
  race16c = ' ';
  race17c = ' ';
  race18c = ' ';
  race19c = ' ';
  race20c = ' ';
  race21c = ' ';
  race22c = ' ';
  race23c = ' ';

  array tmparr5[*] $1 typ5_1-typ5_3 ('R', 'S', 'C');
  %Randomize(hbound(tmparr5), 1, arr_elem);
  race_mvr = tmparr5[arr_elem];

  occup = ' ';
  %Randomize(998, 1, occupc);
  indust = ' ';
  %Randomize(998, 1, industc);
  %Randomize(999998, 1, bcno);
  %Randomize(199, 1803, idob_yr);
  bstate = ' ';
  %Randomize(199, 1803, r_yr);
  %Randomize(10, 1, r_mo);
  %Randomize(29, 1, r_dy);
run;


 /* Print to textfile in NCHS format. */
data _NULL_;
  set work.randdata;
  ***file OUT;
  /* BLKSIZE is usualyy needed for the MF. */
  file OUTTXT BLKSIZE=7000 LRECL=700 PAD;
  options linesize=256;
  put @1 dod_yr F4.  @5 dstate $char2.  @7 fileno Z6.  @13 void F1.
      @14 auxno Z12.  @26 mfilled F1.  @27 gname $char50.
      @77 mname $char1.  @78 lname $char50.  @128 suff $char10.
      @138 alias F1.  @139 flname $char50.  @189 sex f_sex.
      @190 sex_bypass F1.  @191 ssn Z9.  @200 agetype F1.
      @201 age Z3.  @204 age_bypass F1.  @205 dob_yr F4.  
      @209 dob_mo Z2.  @211 dob_dy Z2.  @213 bplace_cnt Z2. 
      @215 bplace_st $char2.  @217 cityc Z5.  @222 countyc Z3.  
      @225 statec Z2.  @227 countryc Z2.  @229 limits f_yorn.
      @230 marital $char1.  @231 marital_bypass F1.  @232 dplace F1.
      @233 cod F3.  @236 disp $char1.  @237 dod_mo Z2.  
      @239 dod_dy Z2.  @241 tod Z4.  @245 deduc F1.  
      @246 deduc_bypass F1.  @247 dethnic1 f_yorn.
      @248 dethnic2 f_yorn.  @249 dethnic3 f_yorn.
      @250 dethnic4 f_yorn.  @251 dethnic5 $char20.
      @271 race1 f_bool.  @272 race2 f_bool.  @273 race3 f_bool.
      @274 race4 f_bool.  @275 race5 f_bool.  @276 race6 f_bool.
      @277 race7 f_bool.  @278 race8 f_bool.  @279 race9 f_bool.
      @280 race10 f_bool.  @281 race11 f_bool.  @282 race12 f_bool.
      @283 race13 f_bool.  @284 race14 f_bool.  @285 race15 f_bool.
      @286 race16 $char30.  @316 race17 $char30.  @346 race18 $char30.
      @376 race19 $char30.  @406 race20 $char30.  @436 race21 $char30.
      @466 race22 $char30.  @496 race23 $char30.  @526 race1e $char3.
      @529 race2e $char3.  @532 race3e $char3.  @535 race4e $char3.
      @538 race5e $char3.  @541 race6e $char3.  @544 race7e $char3.
      @547 race8e $char3.  @550 race16c $char3.  @553 race17c $char3.
      @556 race18c $char3.  @559 race19c $char3.  @562 race20c $char3.
      @565 race21c $char3.  @568 race22c $char3.  @571 race23c $char3.
      @574 race_mvr $char1.  @575 occup $char40.  @615 occupc Z3.
      @618 indust $char40.  @658 industc Z3.  @661 bcno Z6.
      @667 idob_yr Z4.  @672 bstate $char2.  @673 r_yr Z4.
      @677 r_mo Z2.  @679 r_dy Z2.
      ;
run;


 /* Place here to avoid spawning prior to writing OUTTXT. */
***x 'c:/util/vim/vim61/gvim.exe -c "set lines=20 columns=150" NCHS_mortality_sample.txt';
