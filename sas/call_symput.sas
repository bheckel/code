options nosource;
 /*---------------------------------------------------------------------------
  *     Name: call_symput.sas
  *
  *  Summary: Demo of CALL SYMPUT.  SAS doesn't know the values of your
  *           data until runtime and by that time it is usually too
  *           late, *unless* you use CALL SYMPUT.
  *
  *           E.g. you can't do this (&fred will wrongly hold the string uid):
  *           
  *           data work.passwd;
  *             input uid $  pw $;
	*             if pw = 'wtf' then
	*              %let fred = uid;   <---uid resolution happens during RUNTIME,
	*           run;                      variable uid is just text at this point
	*                                     (compile time) so &fred is always 'uid'
  *
  *           You MUST say:
  *
  *           data work.passwd;
  *             input uid $  pw $;
	*             if pw = 'wtf' then
  *             call symput('fred', uid);
  *           run;
  *
  *           BUT macro variables created by call symput still may NOT be
  *           referenced in the same DATA step in which they are created
  *
  *  Adapted: Thu 11 Apr 2002 14:41:23 (Bob Heckel--Little SAS Book)
  * Modified: Sun 16 Jul 2006 11:57:51 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;


data flowersales;
  input CustomerID $4.  @6 SaleDate MMDDYY10.  @17 Variety $9.  Quantity;
  cards;
240W 02-07-2000 Ginger    200
356W 02-08-2000 Heliconia 260
240W 02-12-2000 Protea    80
240W 02-12-2000 Heliconia    320
188W 02-11-2000 Ginger    24
  ;
run;


data _NULL_;
  set flowersales;
  %global badhione goodhione;
  /* Init to NULL. */
  %let badhione = ;
  %let goodhione = ;

  if Quantity > 260 then
    do;
      /* This executes immediately so it will always be 'yes' */
      %let badhione = yes;
      /* Quotes (single or double) required!  Unless it's a dataset
       * variable on the righthand parameter.  Lefthand param is
       * autovivified if necessary.
       */
      call symput('goodhione', 'yes');
      output;
    end;
  else 
    call symput('goodhione', 'no');
run;


 /*------------------------------------*/
 /* Can't refer to a macro variable in the same step that creates it so
  * do it here instead:
  */
%macro testimmediacy;
  %put approach A: &badhione potaitoe;
  %put &goodhione;
%mend;
%testimmediacy;

data _NULL_;
  /* Double quotes! */
  put "approach B: &badhione pototoe";
  put "&goodhione";
run;
 /*------------------------------------*/


 /* To allow selecting the highest number. */
proc sort data=flowersales;
  by DESCENDING Quantity;
run;


data _NULL_;
  set flowersales;
  if _N_ = 1 then call symput("selectedcustomer", CustomerID);
  /* Not necessary but it is efficient. */
  else STOP;
run;


proc print data=flowersales;
  where CustomerID = "&selectedcustomer";
  title 'Customer Sales summarized:';
  title2 "(Customer &selectedcustomer Had the Largest Order)";
run;



 /**************************************/
 /* Good concatenation demo:           
data _NULL_;
  set doesntexistinthisexample;
  call symput('N'||left(put(_n_,1.)), myvar);
run;
%put &N1;
%put &N2;
%put &N3;
 /**************************************/



 /* Using character variable (instead of character string examples above) to
  * create *multiple* macrovars
  */
data _NULL_;
  set SASHELP.shoes;
  macvar = substr(region, 1, 6);
  call symput (macvar, stores);
run;
%put !!!&Africa;
%put _all_;
