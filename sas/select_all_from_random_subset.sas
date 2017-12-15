
%macro select_all_from_subset;
  proc surveyselect data=l.xrfilldata(keep=masked_patientkey) out=threepat n=3; run;
  proc sql; select quote(strip(masked_patientkey)) into :list separated by ',' from threepat; quit;
  data l2.smallrx(keep=medicationname filldate ndc gpi clientid storeid masked_patientkey paymenttype paidamount copayamount pcn pharmacypatientid age longtermcarefacilitycode); set l.rxfilldata(where=(masked_patientkey in (&list))); run;
  %put _USER_;
%mend;
%select_all_from_subset;
