options sasautos=(SASAUTOS '/Drugs/Macros' '.') mprint mprintnest validvarname=any;
/********************************************************************************
*  SAVED AS:                rm_merged_patients.sas
*                                                                         
*  CODED ON:                22-Aug-17 (bheckel)
*                                                                         
*  DESCRIPTION:             Remove merged patients from a dataset
*                                                                           
*  PARAMETERS:              - Y flag if using atebpatientid, N if using pharmacypatientid
*                           - comma separated client id(s)
*                           - dataset to modify
*                           - client store id if not using atebpatientid and if named 
*                             other than clientstoreid
*
*  MACROS CALLED:           %dbpassword 
*                                                                         
*  INPUT GLOBAL VARIABLES:  NONE
*                                                                         
*  OUTPUT GLOBAL VARIABLES: NONE  
*
*  SAMPLE CALLS:            %rm_merged_patients(atebpatientid=Y, clids=%str(123,456), ds=mydataset);
*                           %rm_merged_patients(atebpatientid=N, clids=%str(123,456), ds=mydataset, csid=storenum);
*                                                                         
*  LAST REVISED:                                                          
*   22-Aug-17 (bheckel)     Initial version
********************************************************************************/
%macro rm_merged_patients(atebpatientid=Y, clids=, ds=, csid=clientstoreid);
  %let ATEB_STACK=%sysget(ATEB_STACK); %put &=ATEB_STACK;
  %let ATEB_TIER=%sysget(ATEB_TIER); %put &=ATEB_TIER;
  %dbpassword;

  %if &atebpatientid eq Y %then %do;
    proc sql;
      connect to odbc as myconn (user=&usr_tableau password=&psw_tableau dsn='db8' readbuff=7000);

      create table mergedpatients as select * from connection to myconn (

        select distinct atebpatientid from patient.atebpatient where mdfcodeid=83 and clientid in( &clids )
        ;

      );

      disconnect from myconn;
    quit;
    %put !!!&=SQLRC &=SQLOBS;

    proc sql NOprint;
      create table &ds as
      select * from &ds
      where atebpatientid not in (select atebpatientid from mergedpatients)
      ;
    quit;
  %end;
  %else %do;
    proc sql;
      connect to odbc as myconn (user=&usr_tableau password=&psw_tableau dsn='db8' readbuff=7000);

      create table mergedpatients as select * from connection to myconn (

        select distinct concat(a.clientid::text,trim(leading '0' from b.clientstoreid::text),pharmacypatientid::text) as upid
        from patient.atebpatient a join client.store b on a.storeid=b.storeid 
        where mdfcodeid=83 and clientid in( &clids )
        ;

      );

      disconnect from myconn;
    quit;
    %put !!!&=SQLRC &=SQLOBS;


    proc sql NOprint;
      create table &ds as
      select * from &ds
      where cats(clientid,%rml0(&csid),externalpatientid) not in (select upid from mergedpatients)
      ;
    quit;
  %end;
%mend;
