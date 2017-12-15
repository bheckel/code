options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: format.sas
  *
  *  Summary: Display a variety of formats using the format statement.
  *
  *           W.D == width total and decimal total (width includes decimals)
  *
  *  Created: Wed 02 Jun 2010 13:12:35 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data _null_;
  format x 12.2;  /* room to spare */
  format y DOLLAR12.2;
  format z DOLLAR9.2;
  format a DOLLAR8.2;
  format b DOLLAR8.;
  format c BEST.;
  format d BEST9.;  /* rounds the decimal places to 3 to fit in width of 9 */

  format dt1 MMDDYY8.;
  format dt2 MMDDYY10.;

  array arr $  x y z a b c d;
  do over arr;
    /*        10     */
    /*    __________ */
    arr = 12345.6789;
    /* so smallest that will fit is a 10.n or greater format */

    /* x = 12345.6789; */
    /* loop */
    /* y = 12345.6789; */
    /* loop */
    /* ... */
  end;
  
  dt1=0;
  dt2=0;

  put _all_;
run;
