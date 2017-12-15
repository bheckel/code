options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: authorize.sas
  *
  *  Summary: Verify user's id and password.  Used in wiz.sas
  *
  *  Created: Mon 12 May 2003 13:22:04 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* DEBUG */
%let userid = bqh0;
%let passwd_key = bob0;

 /* Create pseudo-hash with key uid and value passwd */
proc format;
  invalue $hash
  'bqh0' = 'bob0'
  'bhb6' = 'brenda6'
  'vpm1' = 'van1'
  other = .
  ;
run;

 /* Authorize user before proceeding. */
data _NULL_;
  passwd_val = input("&userid", $hash.);

  if "&passwd_key" eq passwd_val then
    put "&userid ok";
  else
    put "&userid password is wrong";
run;

