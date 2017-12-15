options nosource;
 /*---------------------------------------------------------------------------
  *     Name: coercion.sas
  *
  *  Summary: Demo of behind-the-scenes type conversion by SAS.
  *
  *  Created: Thu 16 Jan 2003 10:36:47 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data _NULL_;
  put _ERROR_=;  /* 0 */
  n=3626885;
  length c $ 4;
  /* SAS converts the num to char. */
  c=n;
  put c=;

  n2=66;
  length c2 $ 4;
  c2='1';
  /* SAS converts the char to num. */
  sumd=n2+c2;
  put sumd=;
  /* This will be 1 if a char to num conversion produces invalid numeric
   * values.
   */
  put _ERROR_;  /* should still be 0 */
run;
