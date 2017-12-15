options ls=180; libname l 'c:/datapost/data/gsk/Zebulon/MDI/albuterol';


/***proc contents data=l._all_ ; run;***/

%macro ods;
  data l.DEBUGODS_0304E_Albuterol;
    set l.ODS_0304E_Albuterol;
    if mrp_batch_id in:('1ZP1319','1ZM1908','1ZM3295');
  run;
%mend;
%ods;


%macro lims;
  data l.DEBUGlims_0037e_albuterolsum;
    set l.lims_0037e_albuterolsum;
  /***  if sampid ge 307000 and sampid le 309000;***/
    if sampname in:('9ZM6909','0ZM2259','0ZM8289');
  run;

  data l.DEBUGlims_0039e_albuterolind;
    set l.lims_0039e_albuterolind;
  /***  if sampid ge 307000 and sampid le 309000;***/
    if sampname in:('9ZM6909','0ZM2259','0ZM8289');
  run;
%mend lims;
/***%lims;***/

endsas;
proc freq data=l.lims_0020t_albuterol; tables mrp_batch_id*long_test_name / nocum norow nocol nopct; run;
