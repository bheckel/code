
 /* Insert blank observation after every 5 observations.  One minor
  * disadvantage to this approach is that the observation number column must
  * be suppressed. 
  */
data class_blanks;
  set SASHELP.class;
  output;  /* real observation */
  if mod(_n_,5)=0;
  array allnums {*} _numeric_ ;
  array allchar {*} _character_ ;
  put '!!!' (_all_)(=);
  drop i;
  do i=1 to dim(allnums); allnums{i}=.; end;
  do i=1 to dim(allchar); allchar{i}=' '; end;
  put '!!!x' (_all_)(=);
  output;  /* blank observation */
run;
options missing=' '; /* Display numeric missing as blank */
proc print data=class_blanks noobs;
  title 'SASHELP.CLASS with Blank Line After Every 5 Obs';
run;
