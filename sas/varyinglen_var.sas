options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: varyinglen_var.sas
  *
  *  Summary: Capture a string that may be 2 or more chars, the shipment
  *           number in this case.
  *
  *  Created: Tue 18 Mar 2003 15:52:54 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data work.tmp (drop= block middle);
  input @1 block $char25.;

  middle=scan(block, 2, '.');
  mergetype=scan(block, 3, '.');
 
  st=substr(middle, 1, 2);
  yr=substr(middle, 4, 2);
  ship=substr(middle, 6);

  cards;
BF19.AKX9915.MORMER1
BF19.ALX99267.MORMER2
BF19.ARX9919.MORMER1M
  ;
run;
proc print; run;
