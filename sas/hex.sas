options nosource;
 /*---------------------------------------------------------------------
  *     Name: hex.sas
  *
  *  Summary: Demo of hexadecimal constants in SAS.
  *
  *  Created: Tue 22 Oct 2002 12:56:33 (Bob Heckel)
  * Modified: Wed 15 Jan 2003 10:17:01 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options source;

 /* These automatically translate to print the ASCII char to Log. */
data _NULL_;
  put '61'x;           /* a is ASCII 97, 0x61 is 97 in base 10 */
  put '62'x;           /* prints b */
  put '63'x;
  put '00'x;           /* NULL char */
  put '3132,3334'x;    /* comma is ignored, prints 1234 */
  put '31,32,33,34'x;  /* comma is ignored, prints 1234 */
  foo='63'x;
  bar=97;
  baz=put(bar, $hex4.);
  put baz=;            /* prints 0061 */

  /* Numeric hex constant. */
  witch=061x;
  put witch=;  /* prints 97 */
run;
