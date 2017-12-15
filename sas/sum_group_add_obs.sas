options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sum_group_add_obs.sas
  *
  *  Summary: Add new record with sum of Casual shoes by subsidiary
  *
  *  Created: Fri 09 May 2014 13:49:21 (Bob Heckel)
  * Modified: Fri 29 Jul 2016 08:45:29 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

proc sort data=sashelp.shoes out=t; by region subsidiary product; run;

data t2(/*drop=totsubsidcasualsales*/);
  set t(where=(region in:('A')));
	by region subsidiary product;  /* usually multiple vars here... */

	if first.subsidiary then do;  /* ...but not here */
	  totsubsidcasualsales = 0;
	end;

	if index(product, 'Casual') then do;
	  totsubsidcasualsales + sales;
	end;

  *output;  /* existing individual record */

	if last.subsidiary then do;
	  product = 'TOTSUBSIDCAS';
		sales = totsubsidcasualsales;
    inventory = .;
    returns = .;
	  output;  /* new group record */
	end;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
