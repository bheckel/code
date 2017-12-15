 /* s/b symlinked as describe.sas */
options NOreplace;

libname BPMSX oledb provider=sqloledb.1 
        properties=("Persist Security Info"=True "Integrated Security"=SSPI 
        "Data Source"="wnetbpms1\production" "Initial Catalog"="SANDBOX") 
        schema=rheckel ignore_read_only_columns=yes 
        ;  

libname BPMS oledb provider=sqloledb.1 
        properties=("Persist Security Info"=True "Integrated Security"=SSPI 
        "Data Source"="wnetbpms1\production" "Initial Catalog"="BPMS") 
        schema=dbo ignore_read_only_columns=yes access=readonly
        ;  

libname W23SQL02 oledb provider=sqloledb.1 
        properties=("Persist Security Info"=True "Integrated Security"=SSPI 
        "Data Source"="w23psql02\production" "Initial Catalog"="bpms_nd") 
        schema=dbo ignore_read_only_columns=yes access=readonly
        ;  

 /* Output will give you a CREATE TABLE that can be used to copy paste create
  * the same table elsewhere, or below, (without Enterprise Manager).  Use
  * Enterprise Manager to do a more precise template (e.g. bit, tinyint, etc.)
  *
  * Can also just use Object Browser and select "Script Object to New Window
  * As" / Create 
  * That is probably easiest.
  */
proc sql;
 /***   describe table BPMSX.id_hist_clp ***/
 /***   describe table W23SQL02.claims_pharmacy ***/
  describe table BPMS.t_ref_bpms_prescriber_info
  ;
quit;

endsas;

proc sql;  /* paste below */

create table BPMSX.t_ref_bpms_prescriber_info  (
   Plancode char(10) format=$10. informat=$10. label='Plancode',
   Validated num format=2. informat=2. label='Validated',
   Prescriber_ID char(50) format=$50. informat=$50. label='Prescriber_ID',
   Prescriber_Title char(10) format=$10. informat=$10. label='Prescriber_Title',
   Prescriber_FName char(50) format=$50. informat=$50. label='Prescriber_FName',
   Prescriber_MName char(50) format=$50. informat=$50. label='Prescriber_MName',
   Prescriber_LName char(50) format=$50. informat=$50. label='Prescriber_LName',
   Prescriber_Suffix char(30) format=$30. informat=$30. label='Prescriber_Suffix',
   Prescriber_Type1 char(30) format=$30. informat=$30. label='Prescriber_Type1',
   Prescriber_Type2 char(30) format=$30. informat=$30. label='Prescriber_Type2',
   DEA char(30) format=$30. informat=$30. label='DEA',
   UPIN char(30) format=$30. informat=$30. label='UPIN',
   ME_NO char(30) format=$30. informat=$30. label='ME_NO',
   STATE_LICENSE char(30) format=$30. informat=$30. label='STATE_LICENSE',
   SSN char(11) format=$11. informat=$11. label='SSN',
   TAX_ID char(30) format=$30. informat=$30. label='TAX_ID',
   SiteID char(35) format=$35. informat=$35. label='SiteID',
   address1 char(50) format=$50. informat=$50. label='address1',
   address2 char(50) format=$50. informat=$50. label='address2',
   address3 char(50) format=$50. informat=$50. label='address3',
   CITY char(25) format=$25. informat=$25. label='CITY',
   STATE char(2) format=$2. informat=$2. label='STATE',
   ZIP char(5) format=$5. informat=$5. label='ZIP',
   ZIPPLUS4 char(4) format=$4. informat=$4. label='ZIPPLUS4',
   PHONE1 char(12) format=$12. informat=$12. label='PHONE1',
   PHONE2 char(12) format=$12. informat=$12. label='PHONE2',
   PAGERNUM char(12) format=$12. informat=$12. label='PAGERNUM',
   FAX char(12) format=$12. informat=$12. label='FAX',
   EMAIL1 char(255) format=$255. informat=$255. label='EMAIL1',
   EMAIL2 char(255) format=$255. informat=$255. label='EMAIL2',
   INSERT_DATE num format=DATETIME22.3 informat=DATETIME22.3 label='INSERT_DATE',
   INSERT_USERID char(3) format=$3. informat=$3. label='INSERT_USERID',
   UPDATE_DATE num format=DATETIME22.3 informat=DATETIME22.3 label='UPDATE_DATE',
   UPDATE_USERID char(3) format=$3. informat=$3. label='UPDATE_USERID',
   specialty1 char(50) format=$50. informat=$50. label='specialty1',
   specialty2 char(5) format=$5. informat=$5. label='specialty2',
   specialty3 char(5) format=$5. informat=$5. label='specialty3',
   specialty4 char(5) format=$5. informat=$5. label='specialty4',
   specialty5 char(5) format=$5. informat=$5. label='specialty5',
   specialty6 char(5) format=$5. informat=$5. label='specialty6',
   Prescriber_Salutation char(100) format=$100. informat=$100. label='Prescriber_Salutation',
   Organization char(100) format=$100. informat=$100. label='Organization',
   MedicalDegree char(25) format=$25. informat=$25. label='MedicalDegree',
   Encrypted_DEA char(100) format=$100. informat=$100. label='Encrypted_DEA'
  );
