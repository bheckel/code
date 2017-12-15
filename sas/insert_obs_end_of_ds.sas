
data l.lims_report_profile;
   set lims_report_profile end=e;

   output;

  if e then do;
     lims_id1 = 'AM0952- Manual Leak Test';
     lims_id2 = 'CALCDATATBL-LEAKAGE';
     lims_id3 = '112.';
     lims_id4 = '';
     long_test_name = 'Leak Rate (mg/year)';
     short_test_name_level1 = 'Leak Rate (mg/year)';
     short_test_name_level2 = '';
     short_test_name_level3 = '';
     data_type = 'INDIVIDUAL';
     trend_flag = 'Y';
     lims_id_key = 'AM0952- Manual Leak Test|CALCDATATBL-LEAKAGE|112.|';
     output;

     lims_id1 = 'AM0952- Manual Leak Test2';
     lims_id2 = 'CALCDATATBL-PCTLEAKAGE2';
     lims_id3 = '112.2';
     lims_id4 = '';
     long_test_name = 'Leak Rate (%/year)2';
     short_test_name_level1 = 'Leak Rate (%/year)2';
     short_test_name_level2 = '';
     short_test_name_level3 = '';
     data_type = 'INDIVIDUAL2';
     trend_flag = 'Y';
     lims_id_key = 'AM0952- Manual Leak Test|CALCDATATBL-PCTLEAKAGE|112.|';
     output;
  end;
run;
