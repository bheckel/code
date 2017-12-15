 /* Reload from backup */

 /* Apparently this is ok: WARNING: No matching members in directory. */

libname L 'd:/temp';

libname BPMS oledb provider=sqloledb.1 
        properties=("Persist Security Info"=True "Integrated Security"=SSPI 
        "Data Source"="wnetbpms1\production" "Initial Catalog"="bpms")
        ;

proc datasets lib=BPMS force;
  append base=BPMS.t_ref_bpms_prescriber_info data=L.arproviders29aug05;
quit;
