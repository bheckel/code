options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: lookup_format.sas
  *
  *  Summary: Demo of using formats to do lookups.
  *
  *  Adapted: Tue 16 Aug 2005 16:06:27 (Bob Heckel -- Aster Shortcuts p. 357)
  * Modified: Fri 27 Oct 2006 15:03:31 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* Lookup something using a scalar */
proc format;
  /* Using VALUE b/c num is mapped to char (opposite of PUT vs INPUT thing) */
  value f_ustz
    -5 = 'Eastern'
    -6 = 'Central'
    -7 = 'Mountain'
    ;
run;

data _null_;
  zone=-5;
  zonename=put(zone, f_ustz.);
  put zonename=;
run;


 /* Lookup something in a range */
proc format;
  /* Using INVALUE instead of VALUE b/c we're mapping char values to numeric
   * values so we need the INPUT statement later.
   * Mnemonic atoi:
   *  (a)scii is closer to (I)NPUT 
   * Mnemonic itoa:
   *  (i)nteger is closer to * (P)UT
   */
  invalue f_parts
    '100'-'200' = 2.99
    '300'-'400' = 5.99
    '500'-'600' = 9.99
    ;
run;

data _null_;
  stockid='150';
  price=input(stockid, f_parts.);
  put price=;
run;
