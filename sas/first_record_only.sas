options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: first_record_only.sas
  *
  *  Summary: Get information from only the first line of data.  
  *           Sniff detect read single line.
  *
  *  Created: Tue 08 Apr 2003 10:53:48 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source mlogic symbolgen;

%global FOO L;

data _NULL_;
  infile cards MISSOVER;
  input num1 num2  @14 statefullname $char8.;

  /* Want to capture the first non-missing state's fullname. */
  if ( _N_ > 0 ) and ( statefullname ne '' ) then 
    do;
      call symput('FOO', statefullname);
      call symput('L', _N_);
      stop;
    end;
  cards;
53.9 4615.0                 WY
264.3 3163.2 Pennsylvania   PA
51.2 4615.8  Minnesota      MN
55.2 4271.2  Vermont        VT
  ;
run;

%put Found value &FOO on line %sysfunc(compress(&L, ' '));

