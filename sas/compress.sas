options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: compress.sas
  *
  *  Summary: Demo of compressing removing characters out of a string.  
  *           Weakly like a regex.
  *
  *           Not compress as in zip!
  *
  *           Use compbl() to convert multiple spaces into single spaces.
  *
  *  Created: Mon 21 Apr 2003 15:30:11 (Bob Heckel)
  * Modified: Tue 07 Apr 2015 09:13:15 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* V9 uses modifiers */
data _null_ ;
  name='Phil Mason 824-9050';

  name1=compress(name);  /* compress spaces - by default */
  put name1= ;

  name2=compress(name,,'a');  /* keep alphabetic chars */
  put name2= ;

  name3=compress(name,,'d');  /* remove numerals */
  put name3= ;

  name4=compress(name,,'l');  /* remove lowercase chars */
  put name4= ;

  name5=compress(name,'hilsox','k');  /* keep specific chars */
  put name5= ;

  name6=compress(name,,'kd');  /* keep digits */
  put name6= ;
run ;
/*
name1=PhilMason824-9050
name2=824-9050
name3=Phil Mason -
name4=P M 824-9050
name5=hilso
name6=8249050
*/



data _null_;
  s='remXove the capital x and A';
  s=compress(s, 'Xa');
  put s=;
run;



%let S=ELIM THE X IN THE X STRING;
data _null_;
  foo="a long X string [ &S ] ok";
  put foo;

  foo2=compress("&S", ' X');
  put foo2;

  put 'On the fly demo: ' %sysfunc(compress("&S", 'X')) ' was here';

  /* Need compbl() */
  foo3=compress("multiple  spaces   to one space does not work", '  ');
  put foo3=;
run;



 /* V8 - remove all chars except selected chars: */
%let T=show ONLY the Xs in the X string;
data _null_;
  bar=compress("&T", compress("&T", 'X')); 
  put bar=;
run;



 /* Remove comma delimiters and quotes */
%let S="APGAR5","FATHYR","MENSYR","MOTHYR";
***%let T=%sysfunc(compress(translate(%quote(&S), ' ', ',')), '"');
%let T=%sysfunc(translate(%quote(&S), ' ', ','));
%let U=%sysfunc(compress(%quote(&T), '"'));
%put &U;
 /* Go-blind version */
%let X=%sysfunc(compress(%quote(%sysfunc(translate(%quote(&S),' ',','))),'"'));
%put &X;



 /* V8 */
data phone;
  input phone $14.;
  cards;
 (555)123-4567
 555.123.4567
  ;
run;

data _null_;
  set phone;
  x=compress(phone, '()- .');
  put x=;
run;
