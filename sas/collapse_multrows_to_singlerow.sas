options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: collapse_multrows_to_singlerow.sas
  *
  *  Summary: For a given key, flatten multiple rows into a single row.
  *
  *           Usually get the "stair stepping" after a proc transpose.
  *
  *           This is not a "tall" to "wide" solution!
  *
  *           See also collapse.sas
  *
  *  Created: Thu 19 Feb 2009 09:04:55 (Bob Heckel)
  * Modified: Fri 30 Mar 2012 14:35:16 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* Wow */

data xx;
  input idnum sat_math sat_verbal act_comp;
  cards;
8188 560    .    .  
8188   .  540    .   
8188   .    .   12
8189 660    .    .  
8189   .  740    .  
8189   .    .   13
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;  

 /* Flatten, compress, collapse to 2 lines */

 /*------------------------------------------------*/
 /* Option A                                       */
proc freq data=xx NOPRINT;
  tables idnum / out=x(keep=idnum);
run;
proc print data=_LAST_(obs=max) width=minimum; run;
data xx;
  update x xx;
  by idnum;
run;
 /*
                             sat_
Obs    idnum    sat_math    verbal    act_comp

 1      8188       560        540        12   
 2      8189       660        740        13   
 */
proc print data=_LAST_(obs=max) width=minimum; run;  
 /*------------------------------------------------*/


 /*------------------------------------------------*/
 /* Option B                                       */
 /* Better, self join-like, no freq needed */
title 'best';
data xx;
  update xx(obs=0) xx;
  by idnum;
run;
 /*
                             sat_
Obs    idnum    sat_math    verbal    act_comp

 1      8188       560        540        12   
 2      8189       660        740        13   
 */
proc print data=_LAST_(obs=max) width=minimum; run;  
 /*------------------------------------------------*/



endsas;
But if data looks like this:
  1     900201     01/12/2009                            
  2     900201     Valtrex 1000mg Caplets (Fielder)      
  3     901710     01/15/2009                            
  4     901710     Valtrex 1000mg Caplets (Fielder)      
  5     902933     01/14/2009                            
  6     902933     Valtrex 1000mg Caplets (Fielder)      
Then we need a two step:
/* Collapse to single row by request_id */
data eforms&product.reqids(drop=field_value);
  set eforms&product.reqids;
  by request_id field_value;
  if first.request_id and first.field_value then do;
    fv1 = field_value;
  end;
  else do;
    fv2 = field_value;
  end;
run;
data eforms&product.reqids;
  update eforms&product.reqids(obs=0) eforms&product.reqids;
  by request_id;
run;
To get this:
  1     900201     01/12/2009    Valtrex 1000mg Caplets (Fielder)      
  2     901710     01/15/2009    Valtrex 1000mg Caplets (Fielder)      
  3     902933     01/14/2009    Valtrex 1000mg Caplets (Fielder)      





proc sql; create index fw&i on FWBATCHS.&ds(mfg_batch, process_order, nSplNbr, sItemName); quit;
data FWBATCHS.&ds(drop=nEventType);
  update FWBATCHS.&ds(obs=0) FWBATCHS.&ds;
  by mfg_batch process_order nSplNbr sItemName;
run;
