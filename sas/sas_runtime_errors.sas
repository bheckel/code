
 /* _ERROR_ only goes to 1 (boolean) on the bad raw record, then returns to 0 */
data t;
  infile cards;
  /* Don't need a '+1' between n1/n2 since it's "list input" but do for the
   * other, nonstandard, because it's "formatted input"
   */
  input n1  n2 COMMA7.  +1  n3 COMMA12.2  +1  n4 COMMA12.2  +1  n5 COMMA3.  +1  n6 COMMA9.;
  put _ALL_;  /* PDV viewer */
  cards;
123.49 123,456 (123,456.01) (823,456.01) 50% 12,345.67
923.49 923,456 X123,456.01) (823,456.01) 50% 12,345.67
+123.49 123,456 (123,456.01) (823,456.01) 50% 12,345.67
923.48 923,456 (923,456.02) (923,456.02) 95% 12,345.68
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
