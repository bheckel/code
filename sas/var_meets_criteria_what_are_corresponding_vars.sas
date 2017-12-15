options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: var_meets_criteria_what_are_corresponding_vars.sas
  *
  *  Summary: What variable in a group meets a certain criteria, and what are
  *           the corresponding variables for each respondent (id)?
  *
  *  Adapted: Wed 10 Dec 2014 10:29:56 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;


data flavors;
  input id (apple orange banana grape kiwi) (:8.) (loc1-loc5) (:$1.) (mydate1-mydate5) (:date9.);
  datalines;
1 100 98 75 84 92     A A B C D 10jul2014 12jul2014 11aug2014 10aug2014 12sep2014
2 80 78 83 88 72 B C A E D 10jul2014 12jul2014 01aug2014 10aug2014 12sep2014
;
run;
proc print; format mydate: date9.; run;

data flavor_min (keep = id flav_min date_min loc_min);
  retain id flav_min loc_min date_min;
  format date_min date9.;
  set flavors;

  array flav[5] apple--kiwi;    
  array loc[5] _CHARACTER_;                      
  array mydate[5] mydate1-mydate5;
  /* same but less clear: */
/***  array mydate[5];***/

  length flav_min $10;

  minflav = min(of flav[*]); 

  do i = 1 to dim(flav);
    if minflav = flav[i] then do;
      flav_min = vname(flav[i]);   
      date_min = mydate[i];
      loc_min = loc[i];
      leave;                                   
    end;
  end;
run;

proc print; run;
