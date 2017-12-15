options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: detect_yr_and_state.sas
  *
  *  Summary: Determine year and state while reading in data for
  *           other purposes.
  *
  *  Created: Tue 08 Apr 2003 13:28:45 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data uc;                                                                    
  /* Medical has no error checking on their filenames.  so we're not
   * using the filename to determine the state name, instead use the
   * first line in the medmer file.
   */
  infile IN;                                                                
  input @1 yr $char4.  @5 statealpha $char2.  @51 cause $char5.;                
  if yr ne "" then
      call symput('YR', yr);                                                  
  if statealpha ne "" then
      call symput('s', statealpha);
run;
