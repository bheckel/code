options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: max_2_variables.sas
  *
  *  Summary: Find max highest of two different variables
  *
  * Adapted: Thu 12 Jun 2008 12:49:57 (Bob Heckel --
  *                              file:///C:/Bookshelf_SAS/proc/zdentify.htm)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data charity;
  input School $ 1-7 Year 9-12 Name $ 14-20 MoneyRaised 22-26 HoursVolunteered 28-29;
  datalines;
Monroe  1992 Allison 31.65 19
Monroe  1992 Barry   23.76 16
Monroe  1992 Candace 21.11  5
Monroe  1992 Stuey   11.11  4
Kennedy 1994 Sid     27.45 42
Kennedy 1994 Will    28.88 21
Kennedy 1994 Morty   94.44 25
Kennedy 1994 Slothy   4.44  5
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


/***proc means data=Charity n mean range;***/
proc means data=Charity;
  class School Year;
  var MoneyRaised HoursVolunteered;
  output out=Prize maxid(MoneyRaised(name) 
         HoursVolunteered(name))= MostCash MostTime
         max= ;
  title 'Summary of Volunteer Work by School and Year';
run;
proc print data=Prize;
  title 'Best Results: Most Money Raised and Most Hours Worked';
  where _TYPE_ eq 0;
run;

