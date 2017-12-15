options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: read_write_excel.sas
  *
  *  Summary: Input/output of Excel
  *
  *  SUGI 074-2011:
  *  For a client: ExcelXP, ODS MSOffice2K, or LIBNAME engine
  *  For programmers, onetimer: PROC EXPORT, ODS MSOffice2K, or ODS CSV
  *  Filesize: ODS CSV smallest, ExcelXP largest
  *
  * Requires the SAS/ACCESS to PC Files module
  *
  *  Created: Mon 04 Aug 2014 12:57:33 (Bob Heckel)
  * Modified: Tue 13 Dec 2016 15:25:40 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

proc import datafile="/Drugs/RFD/2016/12/AN-6052/Data/Patients with No Flu no Aetna_Amy" dbms=xls out=t0 REPLACE;
  sheet='Report 1'n;
  getnames=no;
  datarow=5;
run;

proc import datafile="/Drugs/RFD/2016/12/AN-6052/Data/Patients with No Flu no Aetna_Amy" dbms=xls out=t1 REPLACE;
  sheet='Report 1(1)'n;
  getnames=no;
run;

proc import datafile="/Drugs/RFD/2016/12/AN-6052/Data/Patients with No Flu no Aetna_jim" dbms=xls out=t2 REPLACE;
  sheet='Report 1'n;
  getnames=no;
  datarow=5;
run;

proc import datafile="/Drugs/RFD/2016/12/AN-6052/Data/Patients with No Flu no Aetna_jim" dbms=xls out=t3 REPLACE;
  sheet='Report 1(1)'n;
  getnames=no;
run;

proc import datafile="/Drugs/RFD/2016/12/AN-6052/Data/tempWebiArtifact1779478600849255266" dbms=xls out=t4 REPLACE;
  sheet='Report 1'n;
  getnames=no;
  datarow=5;
run;

proc import datafile="/Drugs/RFD/2016/12/AN-6052/Data/tempWebiArtifact1779478600849255266" dbms=xls out=t5 REPLACE;
  sheet='Report 1(1)'n;
  getnames=no;
run;

proc import datafile="/Drugs/RFD/2016/12/AN-6052/Data/tempWebiArtifact1993807580149957538" dbms=xls out=t6 REPLACE;
  sheet='Report 1'n;
  getnames=no;
  datarow=5;
run;

proc import datafile="/Drugs/RFD/2016/12/AN-6052/Data/tempWebiArtifact1993807580149957538" dbms=xls out=t7 REPLACE;
  sheet='Report 1(1)'n;
  getnames=no;
run;

proc import datafile="/Drugs/RFD/2016/12/AN-6052/Data/tempWebiArtifact4503600567884559404" dbms=xls out=t8 REPLACE;
  sheet='Report 1'n;
  getnames=no;
  datarow=5;
run;

proc import datafile="/Drugs/RFD/2016/12/AN-6052/Data/tempWebiArtifact4503600567884559404" dbms=xls out=t9 REPLACE;
  sheet='Report 1(1)'n;
  getnames=no;
run;

proc import datafile="/Drugs/RFD/2016/12/AN-6052/Data/tempWebiArtifact6290628229565972760" dbms=xls out=t10 REPLACE;
  sheet='Report 1'n;
  getnames=no;
  datarow=5;
run;

proc import datafile="/Drugs/RFD/2016/12/AN-6052/Data/tempWebiArtifact6290628229565972760" dbms=xls out=t11 REPLACE;
  sheet='Report 1(1)'n;
  getnames=no;
run;

proc import datafile="/Drugs/RFD/2016/12/AN-6052/Data/tempWebiArtifact9006066149011498720" dbms=xls out=t12 REPLACE;
  sheet='Report 1'n;
  getnames=no;
  datarow=5;
run;
/***proc contents;run;***/
/*

                                   1    A           Char      1    $1.          $1.         A    
                                   2    B           Char     14    $14.         $14.        B    
                                   3    C           Char     14    $14.         $14.        C    
                                   4    D           Char     14    $14.         $14.        D    
                                   5    E           Num       8    BEST14.                  E    
                                   6    F           Char     23    $23.         $23.        F    
                                   7    G           Char     23    $23.         $23.        G    
                                   8    H           Char     14    $14.         $14.        H    
                                   9    I           Num       8    MMDDYY10.                I    
                                  10    J           Char     14    $14.         $14.        J    
                                  11    K           Num       8    BEST14.                  K    
*/
data t;
  length b c d f g h j $80;
  rename b='Facility ID'n
         c=City
         d=State
         e='Internal Patient Num'n
         f='First Name'n
         g='Last Name'n
         h=Phone
         i='Patient DOB'n
         j=Age
         k="Flu GPI's"n
         ;
  set t0-t12;
  x = scan(j, 1, ' ');
  if d ne: 'Count';
run;

proc sort data=t;
  by descending x;
run;

data t;
  retain 
    'Facility ID'n
    City
    State
    'Internal Patient Num'n
    'First Name'n
    'Last Name'n
    Phone
    'Patient DOB'n
    Age
    "Flu GPI's"n
    ;
  set t(drop=a x);
  if _N_ <= 290000;
run;

 /* Multiple xls */
/***proc export data=t(firstobs=1 obs=65535) dbms=xls outfile='/Drugs/RFD/2016/12/AN-6052/Reports/AN-6052_TOCALL_1' REPLACE; run;***/
/***proc export data=t(firstobs=65536 obs=131070) dbms=xls outfile='/Drugs/RFD/2016/12/AN-6052/Reports/AN-6052_TOCALL_2' REPLACE; run;***/
/***proc export data=t(firstobs=131071 obs=196605) dbms=xls outfile='/Drugs/RFD/2016/12/AN-6052/Reports/AN-6052_TOCALL_3' REPLACE; run;***/
/***proc export data=t(firstobs=196606 obs=262140) dbms=xls outfile='/Drugs/RFD/2016/12/AN-6052/Reports/AN-6052_TOCALL_4' REPLACE; run;***/
/***proc export data=t(firstobs=262141) dbms=xls outfile='/Drugs/RFD/2016/12/AN-6052/Reports/AN-6052_TOCALL_5' REPLACE; run;***/

 /* Single xlsx */
proc export data=t(firstobs=1 obs=65535) dbms=xlsx outfile='/Drugs/RFD/2016/12/AN-6052/Reports/AN-6052_TOCALL' REPLACE; sheet=Sheet1; run;
proc export data=t(firstobs=65536 obs=131070) dbms=xlsx outfile='/Drugs/RFD/2016/12/AN-6052/Reports/AN-6052_TOCALL' REPLACE; sheet=Sheet2; run;
proc export data=t(firstobs=131071 obs=196605) dbms=xlsx outfile='/Drugs/RFD/2016/12/AN-6052/Reports/AN-6052_TOCALL' REPLACE; sheet=Sheet4; run;
proc export data=t(firstobs=196606 obs=262140) dbms=xlsx outfile='/Drugs/RFD/2016/12/AN-6052/Reports/AN-6052_TOCALL' REPLACE; sheet=Sheet5; run;
proc export data=t(firstobs=262141) dbms=xlsx outfile='/Drugs/RFD/2016/12/AN-6052/Reports/AN-6052_TOCALL' REPLACE; sheet=Sheet6; run;

proc sql;
  create table cnt as
  select 'Facility ID'n, count(*) as Count
  from t
  group by 'Facility ID'n
  order by 'Facility ID'n
  ;
quit;
proc export data=cnt dbms=xlsx outfile='/Drugs/RFD/2016/12/AN-6052/Reports/AN-6052_TOCALL' REPLACE; sheet=Counts; run;
