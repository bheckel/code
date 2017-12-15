options ls=180 ps=max NOcenter;

 /* Compare long_test_name across LIMS LIFT and cfg */

libname l '.';

%macro refresh;
  libname LIMSMAP 'Z:\DataPost\data\GSK\Metadata\Reference\LIMS' access=readonly;
  libname GDM oracle user=gdm_zeb password=gdm123zeb45 path=ukprd613 schema=gdm_dist;
  filename MAP 'Z:\DataPost\cfg\DataPost_Configuration.map'; libname XLIB XML 'Z:\DataPost\cfg\DataPost_Configuration.xml' xmlmap=MAP access=READONLY;

  proc sql;
    create table l.JUNKlift as
    select distinct upcase(long_test_name) as long_test_name
    from GDM.vw_zeb_lift_rpt_results_nl
    where mrp_mat_id in('10000000076065','10000000008558','4117352','4117344','4151232','10000000008557','10000000055204','4123123','4123352','10000000007001','4137019',
    '4137027','4152603','10000000047840','10000000017466','10000000064097','10000000017467','10000000017468','10000000064171','10000000064098','10000000064099','10000000017501',
    '10000000024705','4106261','4132537','10000000072746','4062124','10000000017732','10000000024618','10000000026101','10000000026103','10000000029190','10000000066311',
    '4147901','4118391','4118405','4123468','4152597','4117301','4120937','4071147','4071166','10000000047263','10000000068134','10000000068135','10000000068136',
    '10000000038847','10000000038848','10000000038849','10000000038850','4071057','4071042','4071034','4071069','4151119','4151127','4011759','4022467','10000000092343',
    '10000000081909','10000000080782','10000000092344','10000000081910','10000000080783','10000000092345','10000000082051','10000000080784','10000000092347','10000000082052',
    '10000000080785','10000000081908','10000000080781','10000000091961','10000000091962','10000000091963','10000000091964','10000000091965','10000000075299','10000000075440',
    '10000000075441','0695009','0695017','0695025','0696005','0696013','0696021','0697001','0697017','0697028','4136411','4136427','4136438','4136446','4148304','4148312',
    '4148327','4148371','4148387','4148387','4148398','4148401','4148417','4148428','10000000055245','10000000055246','10000000055247','10000000055481','10000000055482',
    '10000000055483','10000000055245','10000000055246','10000000055247','10000000059137','10000000059150','10000000063059','4148387','10000000059137','10000000059139',
    '10000000059150','10000000063058','10000000063058','10000000063059','10000000063070','10000000089315','10000000089317','10000000089319','10000000089323','10000000089324',
    '10000000089325','10000000089330','10000000089394','10000000089396','10000000089421','60000000002485','60000000002484','60000000002483','60000000002489','60000000002490',
    '60000000002491','60000000002488','60000000002487','60000000002486','10000000059062','10000000060721','10000000059064','10000000059066','10000000058960','10000000058961',
    '4104501','4152506','10000000069767','10000000080112','60000000002596','60000000002597','60000000002581','10000000097328','10000000097330','10000000097331','10000000094129',
    '10000000094130','10000000094131','10000000094132','10000000094133','10000000094134','10000000094135','10000000094123','10000000094124','10000000094125','10000000094126',
    '10000000094127','10000000094128','10000000094117','10000000094118','10000000094119','10000000097334','10000000097335','10000000097336','60000000003256','60000000004088')
    and trend_flag = 'Y'
    order by long_test_name
    ;
  quit;

  proc sql;
    create table l.JUNKlims as
    select distinct upcase(long_test_name) as long_test_name
    from LIMSMAP.lims_report_profile
    order by long_test_name
    ;
  quit;

  data t(keep=long_test_name);
    length long_test_name $80;
    set XLIB.condition;
    long_test_name = upcase(columnvalue);
    if columnname eq 'LONG_TEST_NAME';
  run;
  proc sort data=t out=l.JUNKcfg NOdupkey; by long_test_name; run;

  endsas;
%mend refresh;

/***%refresh;***/

data matchall liftonly limsonly cfgonly liftlimsonly liftcfgonly limscfgonly liftnotcfg;
  merge l.JUNKlift(in=ina) l.JUNKlims(in=inb) l.JUNKcfg(in=inc);
  by long_test_name;

  if ina and inb and inc then output matchall;  /* ignore */

  if ina and not inb and not inc then output liftonly;  /* maybe a problem */
  if inb and not ina and not inc then output limsonly;
  if inc and not ina and not inb then output cfgonly;  /* a problem */

  if (ina and inb) and not inc then output liftlimsonly;
  if (ina and inc) and not inb then output liftcfgonly;  /* mostly useless */
  if (inb and inc) and not inb then output limscfgonly;  /* mostly useless */

  if ina and not inc then output liftnotcfg;  /* probably a problem */
run;
/***title 'matchall'; proc print data=matchall(obs=max) width=minimum; run;***/
/***title 'liftonly'; proc print data=liftonly(obs=max) width=minimum; run;***/
/***title 'limsonly'; proc print data=limsonly(obs=max) width=minimum; run;***/
title 'cfgonly'; proc print data=cfgonly(obs=max) width=minimum; run;
/***title 'liftlimsonly'; proc print data=liftlimsonly(obs=max) width=minimum; run;***/
/***title 'liftcfgonly'; proc print data=liftcfgonly(obs=max) width=minimum; run;***/
/***title 'limscfgonly'; proc print data=limscfgonly(obs=max) width=minimum; run;***/
title 'liftnotcfg'; proc print data=liftnotcfg(obs=max) width=minimum; run;
 /* then run this to figure out which prod(s) affected:
  
select distinct material_description --long_test_name
from gdm_dist.vw_zeb_lift_rpt_results_nl
where upper(long_test_name) like 'PARTICULATE MATTER - PARTICLES  GTE 100%'

 */
