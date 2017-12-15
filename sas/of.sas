options nosource;
 /*---------------------------------------------------------------------------
  *     Name: of.sas
  *
  *  Summary: Demo of using OF to indicate a range of variables.
	*
  *  Created: Fri 27 Sep 2002 10:04:08 (Bob Heckel)
  * Modified: Mon 14 Jun 2010 13:58:45 (Bob Heckel)
  *---------------------------------------------------------------------------
  */

data t;
  infile cards;
  input one1 one2 one3 yetmore lastone forreal;
  format sizeis $CHAR6.;

  array a[*] one1-one3;
  m=mean(of a[*]);

  /* Variables must be ascending numeric suffixed */
  if max(of one1-one3) < 5 then
    do;
      sizeis = 'small';
      totsmall+1;
    end;
  else
    do;
      sizeis = 'alot bigger';
      totbig+1;
    end;

  smallest = min(of yetmore--forreal);

  summed = sum(of one1-one3);
  cards;
1 2  3 99999 8 19
10 20 30   8888888888888888888888888888888888888 42 2
11 22 33 77777 99  6
  ;
run;

proc print; run;
