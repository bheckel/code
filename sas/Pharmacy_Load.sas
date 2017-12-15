options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: Pharmacy_Load.sas
  *
  *  Summary: Load textfile containing pharmacy info into SQL Server.
  *
  *  Created: Tue 01 Nov 2005 11:28:05 (RH)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

%let plan=al;

 /* These are the only edits required */
%let fname=PH_AL0509.txt;
%let insert_userID=rh;  


libname W23PSQL1 oledb provider=sqloledb.1 
        properties=("Persist Security Info"=True "Integrated Security"=SSPI
        "Data Source"="W23PSQL01\PRODUCTION" "Initial Catalog"=bpms_al)
        direct_exe=delete
        ;
libname LOC 'X:\BPMS\AL\Data\Pharmacy\SAS';

proc datasets kill; quit;

proc printto log="x:\BPMS\&plan\LOGs\Alabama_Load_Pharmacy.&fname..&SYSDATE..log" NEW;
run;


data pharmacy_new;
  length city $25  state $2  zip $5  phone $10;
  infile "X:\BPMS\&plan\Data\Pharmacy\Incoming\&fname" delimiter="09"x DSD
         firstobs=11
         ;

  /* Full Provider Name	Provider Number	Provider County Description	Complete Street Address	City/State/ Zip	Provider Phone Number */
  /* ADAMS DRUGS PRATTVILLE     	100003104	Autauga	103 S MEMORIAL DRIVE  	PRATTVILLE, AL  36066-0000	(334) 358-5353 */
  input pharmacy_name :$CHAR100.
        pharmacy_id :$CHAR15.
        county :$CHAR1.
        address1 :$CHAR50.
        citystatezip :$CHAR100.
        fullphone :$CHAR100.
        ;

  city = strip(scan(citystatezip, 1, ','));
  state = strip(scan(citystatezip, 2, ','));
  zip = scan(strip(scan(citystatezip, 2, ',')), 2, '  ');
  phone = compress(fullphone, '()- ');
  source = 'new';
run;
proc sort data=pharmacy_new; by pharmacy_id source; run;


 /* Providers already in database */
data LOC.pharmacies_on_file&SYSDATE;
  set W23PSQL1.AL_Pharmacy_Providers;
  source = 'old';
run;
proc sort data=LOC.pharmacies_on_file&SYSDATE; by pharmacy_id source; run;


/* Merge providers already in database with new file.  Each prescriber_id can
 * only be in file 2 times--once in old file and once in new file 
 */
data pharmacy_update;
  merge pharmacy_new LOC.pharmacies_on_file&SYSDATE;
  by pharmacy_id descending source;
run;
proc sort data=pharmacy_update; by pharmacy_id descending source; run;


/* A prescriber_id in the file twice will have two good addresses.   Use the
 * last record received (source eq new) 
 */
data pharmacy_update (drop=source county citystatezip fullphone);
  set pharmacy_update;

  by pharmacy_id descending source; 

  if last.pharmacy_id then 
    output pharmacy_update;
run;


%macro Update_db;
  %if &SYSERR eq 0 %then
    %do;
      proc sql;
        delete * 
        from W23PSQL1.AL_Pharmacy_Providers
        ;
      quit;

      proc datasets nolist nodetails lib=W23PSQL1 force;
        append base=W23PSQL1.AL_Pharmacy_Providers data=work.pharmacy_update;
      quit;
    %end;
%mend Update_db;
%Update_db


libname W23PSQL1 clear;

proc printto; run;
