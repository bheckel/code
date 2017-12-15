options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: readin_textfile.sas
  *
  *  Summary: Read in all types of textfiles to a SAS dataset
  *
  *  Created: Thu 18 Oct 2012 12:48:27 (Bob Heckel)
  * Modified: Wed 28 Aug 2013 13:10:37 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

 /* See also the newer read_parse_ini.sas */
filename TXT "./ADO_FW.txt";
data tmp;
  infile TXT LRECL=256 FIRSTOBS=3;
  input
    @1 sBatchNbr $CHAR22.
    @32 sProdName $CHAR30.
    @64 sItemName $CHAR12.
    @95 dtSplTakenTime $CHAR29.
    @119 rValue1 :8.
    @144 rValue2 :8.
    @169 rValue3 :8.
    @194 rValue4 :8.
    @219 rValue5 :8.
    @244 nItemID :8. 
  ;
run;

proc print data=_LAST_(obs=max) width=minimum; run;
proc contents;

/*
sBatchNbr                      sProdName                       sItemName                      dtSplTakenTime          rValue1                  rValue2                  rValue3                  rValue4                  rValue5                  nItemID    
------------------------------ ------------------------------- ------------------------------ ----------------------- ------------------------ ------------------------ ------------------------ ------------------------ ------------------------ -----------
2000725935/8zm3266             Foo 1g Caplets (Fldr-DIVI)  Weight                         2008-11-21 15:46:59.727                   1410.2       1392.9000000000001                   1401.8       1410.4000000000001       1363.0999999999999         192
2000725935/8zm3266             Foo 1g Caplets (Fldr-DIVI)  Weight                         2008-11-21 15:46:59.727       1389.9000000000001                   1396.8                     1400       1393.5999999999999       1410.5999999999999         192
2000725935/8zm3266             Foo 1g Caplets (Fldr-DIVI)  Thickness                      2008-11-21 15:46:59.727       7.4400000000000004       7.4500000000000002       7.5300000000000002                     7.46       7.5499999999999998         193
2000725935/8zm3266             Foo 1g Caplets (Fldr-DIVI)  Thickness                      2008-11-21 15:46:59.727       7.5499999999999998                     7.46       7.5800000000000001       7.4500000000000002       7.6100000000000003         193
2000725935/8zm3266             Foo 1g Caplets (Fldr-DIVI)  Hardness                       2008-11-21 15:46:59.727       30.699999999999999       29.899999999999999       29.199999999999999                     36.5       28.800000000000001         195
2000725935/8zm3266             Foo 1g Caplets (Fldr-DIVI)  Hardness                       2008-11-21 15:46:59.727       36.899999999999999       24.300000000000001       36.200000000000003                       35       33.399999999999999         195

(6 rows affected)
*/



 /* Read tab delimited */
data work.restaurants;
  infile cards DLM='09'x DSD MISSOVER;
  ***length name $35  addr $25  phone $12  web $41  city $20  zip $5;
  ***input name addr phone web city zip;
  /* Better.  Use the colon shortcut to avoid the length statements and the
   * possibility of typos. 
   */
  input name:$35.  addr:$25.  phone:$12.  web:$41.  city:$20.  zip:$5.;
  /* These are tab delimited */
  cards;
Baker's Crust	3553 Cary Street	804-213-0800	http://www.bakerscrust.com/	Richmond	23230
Arby's	11298 Patterson Ave	804-740-9480		Richmond	23230
Bistro R.	10190 West Broad St	804-747-9484	http://www.bistror.com/	Glen Allen	23060
  ;
run;



 /* Multiple delimiters in dlm= is ok! */
data multipledelimiter;
  infile cards DLM=',:';
  input foo $ bar $ baz $;
  cards;
ab,cd:ef
gh,ij:kl
  ;
run;
