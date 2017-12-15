options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: infile_underscore_write_external.sas
  *
  *  Summary: Directly write external file in datastep using CARDS and change
  *           the format on the fly.
  *
  *           Uses the special automatic SAS variable _INFILE_
  *
  *  Adapted: Wed 11 Jun 2003 21:26:37 (Bob Heckel -- Missing Semi Winter 2002)
  * Modified: Mon 29 Nov 2010 11:00:37 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data _NULL_;
  input foo;
  file 'junk.txt';
  if foo eq 34 then do;
    put _INFILE_;
  end;
  cards;
 12 97
 34 98
 56 99
  ;
run;



endsas;
data _NULL_;
/***  infile cards;***/
  input @2 foo;
  file 'junk.txt';
  if _INFILE_ eq 34 then do;
    put _INFILE_ @5 foo Z6.;
  end;
  cards;
 12
 34
 56
  ;
run;
