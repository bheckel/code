
 /* Remove everything from the T to the end of the string */
%let ENDDT= 2012-06-04T14:44:01;
/***%let x=%substr(&ENDDT, 0, %index(&ENDDT, T));***/
/***%let x=%substr(&ENDDT, %index(&ENDDT, T), 4);***/
%let x=%substr(&ENDDT, 1, %eval(%index(&ENDDT, T)-1));
%put !!!&x;
