options nosource;
 /*---------------------------------------------------------------------------
  *     Name: n_elems_in_list.sas
  *
  *  Summary: Demo of counting number of objects in a comma separated list and
  *           have access to them via an array element.
  *
  *  Created: Tue 28 Jan 2003 14:39:38 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

%global NS;

%let S = ('AK','AL','AR','AS','AZ','CA','CO','CT','DC','DE', 'FL','GA','GU',
          'HI','IA','ID','IL','IN','KS','KY', 'LA','MA','MD','ME','MI','MN',
          'MO','MP','MS','MT', 'NC','ND','NE','NH','NJ','NM','NV','NY','OH',
          'OK', 'OR','PA','PR','RI','SC','SD','TN','TX','UT','VA', 'VI','VT',
          'WA','WI','WV','WY','YC');

%macro NumStates;
  %local TMP;

  %let TMP = %sysfunc(compress(%quote(&S)));
  /* About 5 chars per state string. */
  %let NS = %eval((%length(&TMP)/5));
  %put &NS;
%mend NumStates;
%NumStates

data _NULL_;
  array stateab[*] $ st1-st&NS &S;
  put stateab[57];
run;
