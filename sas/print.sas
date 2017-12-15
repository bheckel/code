
%macro print(obs=, libn=, dsn=, wh=, ord=, vars=);

  %put &=libn;
  libname l "&libn" access=readonly;
/***  proc contents data=l.&dsn;run;***/

  proc sql;
    create table t as
    %if "&vars" eq ""  %then %do;
      select *
/***      select patient_dob,cardholder_id,patient_last_name,patient_first_name,patient_zip,target_pharmacy_name,drug_ndc,npi,clientid,clientstoreid,externalpatientid,atebpatientid***/
    %end;
    %else %do;
      select &vars
    %end;
    from l.&dsn
    %if &wh ne  %then %do;
      where &wh
    %end;
    &ord
    ;

  title "!!!&dsn";proc print data=t(obs=&obs) width=minimum heading=H; run;
%mend;

options NOcenter ls=max ps=max;
/***%print( obs=max, libn=%str(/Drugs/Drugs/Freds/FG1_31JUL2015_SAS), dsn=ar2_advair323, wh=%str( status='CANCELLED') , ord=%str(order by postts) );***/
/***%print(obs=max, libn=%str(/Drugs/Immunizations/GiantEagle/Imports/20160929/Data), dsn=rxfilldata_extra, wh=%str(pharmacypatientid='DINESU1' and storeid='0002') , ord=%str() );***/
/***%print( obs=100, libn=%str(/Drugs/Immunizations/Wakefern/Imports/20160929/Data), dsn=zostavax_e3, wh=%str(age < 60) , ord=%str() );***/
/***%print( obs=100, libn=%str(/Drugs/Immunizations/Wakefern/Imports/20160929/Data), dsn=zostavax_e2, wh=%str(pharmacypatientid='3681846') , ord=%str() );***/
/***%print( obs=100, libn=%str(/Drugs/Immunizations/Wakefern/Imports/20161116/Data), dsn=rxfilldata_extra, wh=%str(storeid='0325') , ord=%str() );***/
/***%print(obs=max, libn=%str(/Drugs/FunctionalData), dsn=adbs2, wh=%str(cgid=559 or cgid=1088 or cgid=1113), ord=%str() );***/
/***%print(obs=max, libn=%str(/Drugs/FunctionalData), dsn=adbs2, wh=%str(), ord=%str(), vars=%str(drug,cgid,shortdn) );***/
/***%print( obs=max, libn=%str(/Drugs/TMMEligibility/Meijer/HPTasks/20161008/Data), dsn=eligible_orig, wh=%str(pharmacypatientid='12042'), ord=%str() );***/
/***%print( obs=max, libn=%str(/Drugs/Personnel/bob/tmp), dsn=eligible, wh=%str(externalpatientid='12042'), ord=%str() );***/
/***%print( obs=5, libn=%str(/Drugs/RFREval/Ahold/2016/20161107/Dataset), dsn=ar2_advair511, wh=%str( ptsex ne 'M' and ptsex ne 'F') , ord=%str() );***/
/***%print( obs=max, libn=%str(/Drugs/RFREval/Ahold/2016/20161108/Dataset), dsn=ar2_advair511, wh=%str( cpid eq 87553015) , ord=%str() );***/
/***%print( obs=max, libn=%str(/Drugs/RFREval/Ahold/2016/20161108/Orig), dsn=pat_advair511, wh=%str(campaignrefillid=87553015) , ord=%str() );***/
/***%print( obs=1000, libn=%str(/Drugs/TMMEligibility/ClarksRxSu/Dashboard/20161101/Data), dsn=table6_1_2, wh=%str(clientid=884) , ord=%str() );***/
/***%print( obs=max, libn=%str(/Drugs/RFD/2016/12/AN-6004/Datasets), dsn=rxf_1, wh=%str( storeid='0105' and pharmacypatientid='1363378') , ord=%str() );***/
/***%print( obs=max, libn=%str(/Drugs/RFD/2016/12/AN-6004/Datasets), dsn=rxf_1, wh=%str( storeid='0105' and pharmacypatientid='3279087') , ord=%str() );***/
/***%print( obs=max, libn=%str(/Drugs/RFD/2016/12/AN-6004/Datasets), dsn=final_1, wh=%str( storeid='0105') , ord=%str() );***/
/***%print( obs=3, libn=%str(/Drugs/Immunizations/AssociatedFood/Imports/20161214/Data), dsn=rxfilldata_extra, wh=%str(clientstoreid ne '0565') , ord=%str() );***/
/***%print( obs=3, libn=%str(/Drugs/HealthPlans/Ahold/Multi/Tasks/20170105/Data), dsn=rank, wh=%str(no_chance_adht=0 and enrolled=0 and one_med =0 and pharmacypatientid^=' ' and atebpatientid=1) , ord=%str() );***/
%print(obs=max, libn=%str(/Drugs/Immunizations/Wakefern/Imports/20170118/Data), dsn=rxfilldata_extra, wh=%str(pharmacypatientid='2823223') , ord=%str() );
