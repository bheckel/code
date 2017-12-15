 /*---------------------------------------------------------------------------
  *     Name: BQH0.SAS.INTRNET.PDS(WIZ2)
  *
  *  Summary: Generate a dynamic page from which user can further refine the 
  *           query parameters using a wizard-like interface.
  *
  *           At this point, user has chosen to do either a Simple List (list)
  *           or a Two-Way (freq) Table.
  *
  *  Created: Thu 06 Feb 2003 09:01:03 (Bob Heckel)
  *      RCS:
  *  $Log: wiz2.sas,v $
  *  Revision 1.17  2003/12/19 15:50:11  bqh0
  *  Added natality non-reviser and reviser query capability.
  *  Added output to MS Excel option to avoid IE URL length limitation.
  *  Improved interface.
  *
  *  Revision 1.16  2003/10/27 21:25:44  bqh0
  *  Added Racebox String and Hispanic String to the reviser
  *  choices per Adrienne Rouse.
  *
  *  Revision 1.15  2003/10/15 15:01:10  bqh0
  *  Bugfix hidden multirace numbering.
  *
  *  Revision 1.14  2003/10/15 14:50:20  bqh0
  *  Add 'country of birth' widget to reviser state query choices.
  *
  *  Revision 1.13  2003/10/06 20:58:01  bqh0
  *  Changed user message above non-rev multi boxes to warn of 'AND'ing.
  *
  *  Revision 1.12  2003/09/19 19:57:08  bqh0
  *  Fix two-way display of >1 year in output.  Add century to revisers.
  *  Fix educ edit dropdown example.  Cleanup age fields on non-rev and revisers.
  *  Changes based on Brenda's review.
  *
  *  Revision 1.11  2003/08/27 19:05:34  bqh0
  *  Allow partial reviser Multirace info to display if user queries
  *  a Multirace state on race.  Also allow provide checkboxes for
  *  users who know the state has adopted Multirace.
  *
  *  Revision 1.10  2003/08/26 18:17:06  bqh0
  *  Allow partial reviser FIPS info to display if user queries a FIPS state.
  *  Also allow user to enter FIPS strings where numerics are normally used.
  *
  *  Revision 1.9  2003/08/18 21:06:39  bqh0
  *  Added variables to two-way, fixed bugs in two-way, improved interface,
  *  added multirace checkboxes to bottom of reviser page.
  *
  *  Revision 1.8  2003/08/15 19:25:09  bqh0
  *  Fixed DC DE transposition error.  Added County of Occ.
  *
  *  Revision 1.7  2003/08/08 21:09:54  bqh0
  *  Created separate pages for reviser states.
  *
  *  Revision 1.6  2003/07/14 20:03:17  bqh0
  *  Change Birth State label to State of Birth to be consistent with State
  *  of Residence, etc.
  *
  *  Revision 1.5  2003/07/11 15:32:01  bqh0
  *  Forgot the D in nchscode.Dwiz2.sas.
  *
  *  Revision 1.4  2003/07/11 15:17:57  bqh0
  *  Fixed a typo on the states dropdown (IA, ID, IN) were wrong.
  *
  *  Revision 1.3  2003/07/09 19:36:41  bqh0
  *  Improve error trap on requested files that don't exist.  Provide query
  *  details in the output
  *
  *  Revision 1.2  2003/07/09 14:12:09  bqh0
  *  Initial mods for dev version.
  *
  *---------------------------------------------------------------------------
  */

 /* DEBUG toggle */
***options NOsource NOsource2 NOmlogic NOsymbolgen NOfullstimer;
options NOsource NOsource2 mlogic symbolgen fullstimer;

%global STDFOOTR;
%let STDFOOTR=BQH0.SAS.INTRNET.PDS(STDFOOTR);

 /* Parameters provided by the previous webpages.  They must go in a HIDDEN
  * tag if we want them to push forward to subsequent pages.  Convention:
  * 'the_' indicates it has been pushed from more than just the previous page.
  */
%global the_type the_userid the_revreq rptstyle;

 /* Convention: uppercase indicates that we, not form widgets, will create the
  * macrovar. 
  */
%global CURRENTYR MAXNYR;

 /* Years (including current year) available for obtaining merged files. */
%let MAXNYR=5;

 /* Initialize */
data _NULL_;
  call symput('CURRENTYR', substr(put("&SYSDATE9"D, MMDDYY10.), 7, 4));
  if "&the_revreq" eq 1 then
    call symput('REVSTATUS', 'Reviser');
  else
    call symput('REVSTATUS', 'Non-Reviser');
run;


 /*   Accepts:  the string 'list' or 'freq'
  * "Returns":  nothing 
  *
  * Generates HTML for the years checkboxes or dropdown. 
  */
%macro BuildYearWidget(rpttype);
  %local d;

  %if &rpttype eq list %then
    %do;
      put 'Select Year(s):';

      %if &the_revreq eq 1 %then
        %let d=DISABLED;
      %else
        %let d=;

      do i=%eval(&CURRENTYR-&MAXNYR+1) to &CURRENTYR;
        /* Merge file requires a 2 digit year so convert num (i), to char (c). */
        c=put(i, F4.);
        y=substr(c, 3, 2);
        j+1;
        if i eq "&CURRENTYR" then
          put '&nbsp;&nbsp;&nbsp<INPUT TYPE=checkbox NAME=year' j ' VALUE=' y ' CHECKED>' i;
        else if i ge 2003 then
          put '&nbsp;&nbsp;&nbsp<INPUT TYPE=checkbox NAME=year' j ' VALUE=' y '>' i;
        else
          /* 2003 was the first year of revisers. */
          put '&nbsp;&nbsp;&nbsp<INPUT TYPE=checkbox NAME=year' j ' VALUE=' y "&d>" i;
      end;
    %end;
  %else %if &rpttype eq freq %then
    %do;
      put 'Select Year:';
      put '<SELECT NAME=freqselyear>';

      do i=%eval(&CURRENTYR-&MAXNYR-1) to &CURRENTYR;
        c=put(i, F4.);
        y=substr(c, 3, 2);
        j+1;
        put '&nbsp;&nbsp;&nbsp';
        /* MUST put space before the y in v9 */
        if i eq 2003 then
          put '<OPTION SELECTED VALUE=' y '>' i;
        else
          put '<OPTION VALUE=' y '>' i;
      end;

      put '</SELECT>';
    %end;
  %else
    %put "ERROR: wiz2.sas: unknown \&rpttype";
%mend BuildYearWidget;


 /*   Accepts:  nothing
  * "Returns":  nothing 
  *
  * Generates HTML for the Certificate widget.  We're assuming certificate num
  * is always wanted.
  */
%macro BuildCertWidget;
  put '<TABLE>';
  put '<CAPTION>Select items to view (with optional criteria):</CAPTION>';
  put '<TR>';
  put '<TD>';
  /* Ugly hack required to allow for the incomprehensible renaming of certno
   * to fileno for mort reviser input statments.
   */
  /*                    VALUE must match var stmt or dataset variable name  */
  %if &the_revreq eq 1 %then
    %do;
      put '<INPUT TYPE="checkbox" NAME="c1" VALUE="fileno" CHECKED>Certificate';
    %end;
  %else
    %do;
      put '<INPUT TYPE="checkbox" NAME="c1" VALUE="certno" CHECKED>Certificate';
    %end;
  put '<TD>';
  /* These must be the same as the put statements for op2, op3... */
  put '<SELECT NAME="op1"><OPTION VALUE="eq">Equal (e.g. 000002)';
  put '  <OPTION VALUE="ne">Not Equal (e.g. 000002)';
  put '  <OPTION VALUE="lt">Less Than (e.g. 000002)';
  put '  <OPTION VALUE="gt">Greater Than (e.g. 000002)';
  put '  <OPTION VALUE="in">In (e.g. 000001,000002,000003)';
  put '  <OPTION VALUE="not in">Not In (e.g. 000001,000002,000003)';
  put '  <OPTION VALUE="between">Between (e.g. 000001-000005)';
  put '  <OPTION VALUE="" SELECTED> ';
  put '</SELECT>';
  put '<TD>';
  put '<INPUT TYPE="textbox" NAME="t1" SIZE=20 VALUE="">';
  put '</TR>';
%mend BuildCertWidget;


 /*   Accepts:  nothing
  * "Returns":  nothing 
  *
  * Generate HTML to create a collection of checkbox, dropdown and textbox
  * widgets. 
  */
%macro BuildListSelectWidgets;
  %global CMAX CMAXNOCK TAG;

  /* Used to distinguish nat's multirace 2 sets of boxes from mort's one. */
  %if %index(&the_type, natmer) %then
    %let TAG=Mother:;
  %else %if %index(&the_type, mormer) %then
      %let TAG=Decedent:;

  /* CMAX is the max number of checkboxes presented to the user.  Should be
   * the same number as the highest element of description array 'descr' plus
   * the number of Multihisp & Multirace Checkboxes.
   */
  %if %index(&the_type, natmer) %then
    %do;
      %if &the_revreq ne 1 %then
        %do;
          %let CMAX=73;
          /* Not including two sets of multirace boxes. */
          %let CMAXNOCK=%eval(&CMAX-30);
        %end;
      %else %if &the_revreq eq 1 %then
        %do;
          %let CMAX=112;
          /* Not including two sets of hisp and two sets of  multirace boxes. */
          %let CMAXNOCK=%eval(&CMAX-38);
        %end;
    %end;
  %else %if %index(&the_type, mormer) %then
    %do;
      %if &the_revreq ne 1 %then
        %do;
          %let CMAX=35;
          /* Not including one set of multirace boxes. */
          %let CMAXNOCK=%eval(&CMAX-15);
        %end;
      %else %if &the_revreq eq 1 %then
        %do;
          %let CMAX=40;
          /* Not including one set of hisp and one set of multirace boxes. */
          %let CMAXNOCK=%eval(&CMAX-19);
        %end;
    %end;
  %else
    %put "ERROR: wiz2.sas: unknown \&the_type";


  /* Widest description text to the right of the checkbox. */
  array descr[&CMAX] $ 39;
   /* Width of data in bytes.  Must align with descr[].  Used to calc
    * width of examples in dropdown widgets.
    */
  /* TODO I could really use a hash here...v9? */
  array wid[&CMAX];
  /* descr[1] is unused since it's always certno, 6 bytes wide, and it's
   * always checked. 
   */
  wid[1] = 6;

  %if %index(&the_type, natmer) %then
    %do;
      %if &the_revreq ne 1 %then
        %do;
          /* If user knows the state is FIPS, user may ignore these examples
           * and key alphas in the state-oriented fields. 
           */
          descr[2] = 'Month of Birth';               wid[2] = 2;
          descr[3] = 'Day of Birth';                 wid[3] = 2;
          descr[4] = 'Sex';                          wid[4] = 1;
          descr[5] = 'Place of Delivery';            wid[5] = 1;
          descr[6] = 'Attendant';                    wid[6] = 1;
          descr[7] = 'Mother Month of Birth';        wid[7] = 2;
          descr[8] = 'Mother Day of Birth';          wid[8] = 2;
          descr[9] = 'Mother Year of Birth';         wid[9] = 4;
          descr[10] = 'Birthplace of Mother';       wid[10] = 2;
          descr[11] = 'Comp Age of Mother';         wid[11] = 2;
          descr[12] = 'Age of Mother';              wid[12] = 2;
          descr[13] = 'Father Month of Birth';      wid[13] = 2;
          descr[14] = 'Father Day of Birth';        wid[14] = 2;
          descr[15] = 'Father Year of Birth';       wid[15] = 4;
          descr[16] = 'Comp Age of Father';         wid[16] = 2;
          descr[17] = 'Age of Father';              wid[17] = 2;
          descr[18] = 'Marital Status';             wid[18] = 1;
          descr[19] = 'Hispanic Origin-Mother';     wid[19] = 1;
          descr[20] = 'Hispanic Origin-Father';     wid[20] = 1;
          descr[21] = 'Race of Mother';             wid[21] = 1;
          descr[22] = 'Race of Father';             wid[22] = 1;
          descr[23] = 'Education of Mother';        wid[23] = 2;
          descr[24] = 'Children Now Living';        wid[24] = 2;
          descr[25] = 'Children Now Dead';          wid[25] = 2;
          descr[26] = 'Other Terminations';         wid[26] = 2;
          descr[27] = 'Mon Last Norm Menses';       wid[27] = 2;
          descr[28] = 'Day Last Norm Menses';       wid[28] = 2;
          descr[29] = 'Yr Last Norm Menses';        wid[29] = 4;
          descr[30] = 'Computed Gestation';         wid[30] = 1;
          descr[31] = 'Estimated Gestation Weeks';  wid[31] = 2;
          descr[32] = 'Mo Prenatal Care Beg';       wid[32] = 1;
          descr[33] = 'N Mo Prenatal Care Beg';     wid[33] = 2;
          descr[34] = 'Tot Prenatal Visits';        wid[34] = 2;
          descr[35] = 'Plurality';                  wid[35] = 1;
          descr[36] = 'Apgar-5 Minute';             wid[36] = 2;
          descr[37] = 'Birth Weight';               wid[37] = 5;
          descr[38] = 'Tob Use';                    wid[38] = 1;
          descr[39] = 'Tob Use & Cigar/Day';        wid[39] = 2;
          descr[40] = 'Alc Use';                    wid[40] = 1;
          descr[41] = 'Alc Use & Drinks/Day';       wid[41] = 2;
          descr[42] = 'Weight Gained';              wid[42] = 2;
          descr[43] = 'Residence of Mother';        wid[43] = 2;
          /* End nat non-full-reviser.  Change CMAX if add more here. */
        %end;
      %else %if &the_revreq eq 1 %then
        %do;
          /* Full reviser can have alpha chars. */
          /* Negatives indicates a character-based selector is required. */
          /* Always start with 2 since certno is element 1. */
          descr[2] = 'Time of Birth';                            wid[2] = 4;
          descr[3] = 'Sex';                                      wid[3] = -1;
          descr[4] = 'Date of Birth(Infant)--Month';             wid[4] = 2;
          descr[5] = 'Date of Birth(Infant)--Day';               wid[5] = 2;
          descr[6] = 'Place Where Birth Occurred';               wid[6] = 1;
          descr[7] = 'Date of Birth(Mother)--Year';              wid[7] = 4;
          descr[8] = 'Date of Birth(Mother)--Month';             wid[8] = 2;
          descr[9] = 'Date of Birth(Mother)--Day';               wid[9] = 2;
          descr[10] = 'Date of Birth(Mother)--Edit Flag';        wid[10] = 1;
          descr[11] = 'Residence of Mother--Inside City Limits'; wid[11] = -1;
          descr[12] = 'Date of Birth(Father)--Year';             wid[12] = 4;
          descr[13] = 'Date of Birth(Father)--Month';            wid[13] = 2;
          descr[14] = 'Date of Birth(Father)--Day';              wid[14] = 2;
          descr[15] = 'Date of Birth(Father)--Edit Flag';        wid[15] = 1;
          descr[16] = 'Mother Married?--Ever';                   wid[16] = -1;
          descr[17] = 'Mother Married?--Conception or Other';    wid[17] = -1;
          descr[18] = 'Mother Married?--Ack. Paternity';         wid[18] = -1;
          descr[19] = 'Mother Education';                        wid[19] =-1;
          descr[20] = 'Mother Education--Edit Flag';             wid[20] = 1;
          descr[21] = 'Father Education';                        wid[21] = 1;
          descr[22] = 'Father Education--Edit Flag';             wid[22] = 1;
          descr[23] = 'Attendant';                               wid[23] = 1;
          descr[24] = 'Mother Transferred';                      wid[24] = -1;
          descr[25] = 'Date of 1st Prenatal Care Visit--Month';  wid[25] = 2;
          descr[26] = 'Date of 1st Prenatal Care Visit--Day';    wid[26] = 2;
          descr[27] = 'Date of 1st Prenatal Care Visit--Year';   wid[27] = 4;
          descr[28] = 'Date of Last Prenatal Care Visit--Month'; wid[28] = 2;
          descr[29] = 'Date of Last Prenatal Care Visit--Day';   wid[29] = 2;
          descr[30] = 'Date of Last Prenatal Care Visit--Year';  wid[30] = 4;
          descr[31] = 'Total Num of Prenatal Visits';            wid[31] = 2;
          descr[32] = 'Total Num of Prenatal Visits--Edit Flag'; wid[32] = 1;
          descr[33] = 'Mother Height--Feet';                     wid[33] = 1;
          descr[34] = 'Mother Height--Inches';                   wid[34] = 2;
          descr[35] = 'Mother Height--Edit Flag';                wid[35] = 1;
          descr[36] = 'Mother Prepregnancy Weight';              wid[36] = 3;
          descr[37] = 'Mother Prepregnancy Weight--Edit Flag';   wid[37] = 3;
          descr[38] = 'Mother Weight at Delivery';               wid[38] = 3;
          descr[39] = 'Mother Weight at Delivery--Edit Flag';    wid[39] = 1;
          descr[40] = 'Did Mother Get WIC Food For Herself?';    wid[40] = -1;
          descr[41] = 'Previous Live Births Now Living';         wid[41] = 2;
          descr[42] = 'Previous Live Births Now Dead';           wid[42] = 2;
          descr[43] = 'Previous Other Pregnancy Outcomes';       wid[43] = 2;
          descr[44] = 'Date of Last Live Birth--Month';          wid[44] = 2;
          descr[45] = 'Date of Last Live Birth--Year';           wid[45] = 4;
          descr[46] = 'Date of Last Oth Preg Outcome--Month';    wid[46] = 2;
          descr[47] = 'Date of Last Oth Preg Outcome--Year';     wid[47] = 4;
          descr[48] = 'Num Cigarettes Smoked Prior to Preg';     wid[48] = 2;
          descr[49] = 'Num Cigarettes Smoked in First 3 Mos';    wid[49] = 2;
          descr[50] = 'Num Cigarettes Smoked in Second 3 Mos';   wid[50] = 2;
          descr[51] = 'Num Cigarettes Smoked in Last 3 Mos';     wid[51] = 2;
          descr[52] = 'Principal Source of Pmt for Delivery';    wid[52] = 1;
          descr[53] = 'Date Last Normal Menses Began--Year';     wid[53] = 4;
          descr[54] = 'Date Last Normal Menses Began--Month';    wid[54] = 2;
          descr[55] = 'Date Last Normal Menses Began--Day';      wid[55] = 2;
          descr[56] = 'Birthweight';                             wid[56] = 4;
          descr[57] = 'Birthweight--Edit Flag';                  wid[57] = 1;
          descr[58] = 'Obstetric Est of Gestation';              wid[58] = 2;
          descr[59] = 'Obstetric Est of Gestation--Edit Flag';   wid[59] = 1;
          descr[60] = 'Apgar Score at 5 Minutes';                wid[60] =2;
          descr[61] = 'Apgar Score at 10 Minutes';               wid[61] =2;
          descr[62] = 'Plurality';                               wid[62] =2;
          descr[63] = 'Set Order';                               wid[63] =2;
          descr[64] = 'Number of Live Born';                     wid[64] =2;
          descr[65] = 'Plurality--Edit Flag';                    wid[65] =2;
          descr[66] = 'Was Infant Transferred Within 24 Hrs?';   wid[66] =-1;
          descr[67] = 'Is Infant Living at the Time of Report?'; wid[67] =-1;
          descr[68] = 'Is Infant Being Breastfed?';              wid[68] =-1;
          descr[69] = 'Mother Reported Age';                     wid[69] =2;
          descr[70] = 'Father Reported Age';                     wid[70] =2;
          descr[71] = '<I>Mother Hisp Ckbox String';             wid[71] = -4;
          descr[72] = '<I>Mother Race Ckbox String';             wid[72] = -15;
          descr[73] = '<I>Father Hisp Ckbox String';             wid[73] = -4;
          descr[74] = '<I>Father Race Ckbox String';             wid[74] = -15;
          /* End nat reviser.  Change CMAX above if you add more here. */
        %end;
    %end;
  %else %if %index(&the_type, mormer) %then
    %do;
      %if &the_revreq ne 1 %then
        %do;
          /* If user knows the state is FIPS, user may ignore and key alphas
           * in the state-oriented fields. 
           */
          /* FIPS Warning: if element 10 changes must, edit qry001.sas */
          descr[2] = 'Sex';                          wid[2] = 1;
          descr[3] = 'Race';                         wid[3] = 1;
          descr[4] = 'Month of Death';               wid[4] = 2;
          descr[5] = 'Day of Death';                 wid[5] = 2;
          descr[6] = 'Year of Death';                wid[6] = 4;
          descr[7] = 'Month of Birth';               wid[7] = 2;
          descr[8] = 'Day of Birth';                 wid[8] = 2;
          descr[9] = 'Year of Birth';                wid[9] = 4;
          descr[10] = 'State of Birth';             wid[10] = 2;
          descr[11] = 'Type of Place of Death';     wid[11] = 1;
          descr[12] = 'Marital Status';             wid[12] = 1;
          descr[13] = 'Hispanic';                   wid[13] = 1;
          descr[14] = 'Education';                  wid[14] = 2;
          descr[15] = 'Injury at Work';             wid[15] = 1;
          descr[16] = 'State of Residence';         wid[16] = 2;
          descr[17] = 'Age Units';                  wid[17] = 1;
          descr[18] = 'Age Number of Units';        wid[18] = 2;
          descr[19] = 'State of Occurrence';        wid[19] = 2;
          descr[20] = 'County of Occurrence';       wid[20] = 3;
          /* End mor non-full-reviser.  Change CMAX if add more here. */
        %end;
      %else %if &the_revreq eq 1 %then
        %do;
          /* Full revisor can have alpha chars. */
          /* Negatives indicates a character-based selector is required. */
          descr[2] = 'Date of Death--Month';                    wid[2] = 2;
          descr[3] = 'Date of Death--Day';                      wid[3] = 2;
          descr[4] = 'Time of Death';                           wid[4] = 4;
          descr[5] = 'Sex';                                     wid[5] = -1;
          descr[6] = 'Sex--Edit Flag';                          wid[6] = 1;
          descr[7] = 'Decedent Age--Type';                      wid[7] = 1;
          descr[8] = 'Decedent Age--Units';                     wid[8] = 4;
          descr[9] = 'Decedent Age--Edit Flag';                 wid[9] = 1;
          descr[10] = 'Date of Birth--Century';                 wid[10] = 4;
          descr[11] = 'Date of Birth--Month';                   wid[11] = 2;
          descr[12] = 'Date of Birth--Day';                     wid[12] = 2;
          descr[13] = 'Residence of Decent--Inside City Limits';wid[13] = -1;
          descr[14] = 'Marital Status';                         wid[14] = -1;
          descr[15] = 'Marital Status--Edit Flag';              wid[15] = 1;
          descr[16] = 'Place of Death';                         wid[16] = 1;
          descr[17] = 'Method of Disposition';                  wid[17] = -1;
          descr[18] = 'Decedent Education';                     wid[18] = 1;
          descr[19] = 'Decedent Education--Edit Flag';          wid[19] = 1;
          descr[20] = '<I>Hispanic Checkbox String';            wid[20] = -4;
          descr[21] = '<I>Race Checkbox String';                wid[21] = -15;
          /* End mor reviser.  Change CMAX and increment the Hispanic
           * Checkboxes numbers if add more here. 
           */

          /* There are hisp & multirace checkboxes visible to the user that
           * are built below.  They must be renumbered if you change anything
           * above.
           */
        %end;
    %end;

    length widget $15;

    i=1;

    /* descr[1] */
    %BuildCertWidget

    %if %index(&the_type, natmer) %then
      %do;
        /* These MUST be the same as the variables on the appropriate input
         * statement in qry001.sas and the variable names on MVDS.  Order
         * MUST be the same as user sees on wiz3.sas output.  Multi ckboxes
         * are not required here but the literal string ones, if used, e.g.
         * hckboxes are.
         */
        %if &the_revreq eq 0 %then
          %do;
            /*     descr[2]     [3]    [4] ...                         */
            do widget='month', 'day', 'sex', 'birthplc', 'attend', 'mothmo',
                      'mothday', 'mothyr', 'mothplc', 'compmyr', 'mothage',
                      'fathmo', 'fathday', 'fathyr', 'compfyr', 'fathage', 
                      'marstat', 'mothhisp', 'fathhisp', 'mrace',
                      'frace', 'motheduc', 'nowlive', 'nowdead', 'othterm',
                      'mensemo', 'mensedy', 'mensyr', 'compgest',
                      'gest_wks', 'cbegmo', 'nbegmo', 'totvists', 'plural',
                      'apgar', 'wgt_unit', 'tob_use', 'tob_day', 'alc_use',
                      'alc_day', 'wgt_gain', 'stres'
                      ;
          %end;
        %else %if &the_revreq eq 1 %then
          %do;
            do widget='tb', 'isex', 'idob_mo', 'idob_dy', 'bplace', 
                      'mdob_yr', 'mdob_mo', 'mdob_dy', 'mage_bypass', 
                      'limits', 'fdob_yr', 'fdob_mo', 'fdob_dy', 
                      'fage_bypass', 'mare', 'marn', 'ackn',
                      'meduc', 'meduc_bypass', 'feduc', 'feduc_bypass',
                      'attend', 'tran', 'dofp_mo', 'dofp_dy',
                      'dofp_yr', 'dolp_mo', 'dolp_dy', 'dolp_yr', 'nprev',
                      'nprev_bypass', 'hft', 'hin', 'hgt_bypass', 'pwgt',
                      'pwgt_bypass', 'dwgt', 'dwgt_bypass', 'wic', 
                      'plbl', 'plbd', 'popo', 'mllb', 'yllb', 'mopo',
                      'yopo', 'cigpn', 'cigfn', 'cigsn', 'cigln', 'pay',
                      'dlmp_yr', 'dlmp_mo', 'dlmp_dy', 'bwg', 'bw_bypass',
                      'owgest', 'owgest_bypass', 'apgar5', 'apgar10',
                      'plur', 'sord', 'liveb', 'plur_bypass', 'itran',
                      'iliv', 'bfed', 'mager', 'fager',
                      /* Literal strings: */
                      'hckboxes', 'rckboxes', 'Fhckbxes', 'Frckbxes'
                      ;
          %end;
      %end;
    %else %if %index(&the_type, mormer) %then
      %do;
        %if &the_revreq eq 0 %then
          %do;
            do widget='sex', 'race', 'month', 'day', 'year', 'birthmo',
                      'birthdy', 'birthyr', 'birthplc', 'typ_plac',
                      'marital', 'hispanic', 'educ', 'injury', 'stres',
                      'ageunit', 'age', 'state', 'county'
                      ;
          %end;
        %else %if &the_revreq eq 1 %then
          %do;
            do widget='dod_mo', 'dod_dy', 'tod', 'sex', 'sex_bypass', 
                      'agetype', 'age', 'age_bypass', 'dob_yr', 'dob_mo',
                      'dob_dy', 'limits', 'marital', 'marital_bypass',
                      'dplace', 'disp', 'deduc', 'deduc_bypass',
                      /* Literal strings: */
                      'hckboxes', 'rckboxes'
                      ;
          %end;
      %end;

      i+1;

      /* Widest data element is birth weight so its example will need 4
       * zeros: 00002.
       */
      length zro $4  eg $15  eg2 $15  eg3 $15;
      /* Example entry to help user type in valid criteria, used in the
       * operator (op1, op2, ...) dropdown. 
       */
      if wid[i] lt 0 then
        do;
          using_alphas = 1;
          if wid[i] eq -1 then
            do;
              eg='B';
              eg2='C';
              eg3='D';
            end;
          else if wid[i] eq -2 then
            do;
              eg='AL';
              eg2='AK';
              eg3='AZ';
            end;
          else if wid[i] eq -4 then
            do;
              eg='NHUU';
              eg2='NHUU';
              eg3='NHUU';
            end;
          else if wid[i] eq -15 then
            do;
              eg='YNNNNNNNNNNNNNN';
              eg2='YNNNNNNNNNNNNNN';
              eg3='YNNNNNNNNNNNNNN';
            end;
        end;
      else
        do;
          using_alphas = 0;
          eg='2';
          eg2=eg+1;
          eg3=eg+2;
        end;

      zro='';
      /* Zero pad the numeric examples. */
      if i le &CMAXNOCK then
        do z=1 to wid[i]-1;
          zro='0'||zro;
        end;

      if descr[i] ne '' then
        do;
          put '<TR><TD>';
          /* SAS spews a warning about spacing but we have to leave it this
           * way.
           */
          put '<INPUT TYPE="checkbox" NAME="c'i+(-1)'" VALUE="' widget '">';
          put   descr[i];
          put '<TD WIDTH=20>';
          /* These must be the same as the put statements for certno above. */
          put '<SELECT NAME="op'i+(-1)'" SIZE=1>';
          put '  <OPTION VALUE="eq">Equal (e.g. ' zro+(-1) eg +(-1) ')';
          put '  <OPTION VALUE="ne">Not Equal (e.g. ' zro+(-1) eg +(-1) ')';
          if using_alphas eq 0 then
            do;
              put '  <OPTION VALUE="lt">Less Than (e.g. ' zro+(-1) eg +(-1) ')';
              put '  <OPTION VALUE="gt">Greater Than (e.g. ' zro+(-1) eg +(-1) ')';
              put '  <OPTION VALUE="in">In (e.g. ' zro+(-1) eg +(-1) ',' zro+(-1) eg2 +(-1) ',' zro+(-1) eg3 +(-1) ')';
              put '  <OPTION VALUE="not in">Not In (e.g. ' zro+(-1) eg +(-1) ',' zro+(-1) eg2 +(-1) ',' zro+(-1) eg3 +(-1) ')';
              put '  <OPTION VALUE="between">Between (e.g. ' zro+(-1) eg +(-1)'-' zro+(-1) eg3 +(-1) ')';
            end;
          put '  <OPTION VALUE="" SELECTED> ';
          put '</SELECT>';
          put '<TD>';
          put '<INPUT TYPE="textbox" NAME="t'i+(-1)'" SIZE=20 VALUE="">';
          put '</TR>';
        end;
      end;
    put '</TABLE>';

/* Create the hisp and multi HTML widgets (twice each for natality). */
%if &the_revreq eq 1 %then
  %do;
    %if %index(&the_type, natmer) %then
      %do;
        /* Number should start where 'Race Checkbox String' left off.        */
        /*    array elem, HTML value, label, print title, newrow, moth/deced */
        %BuildHispCkbox(%eval(&CMAXNOCK+1), methnic1, Mexican, 1, 0, &TAG);
        %BuildHispCkbox(%eval(&CMAXNOCK+2), methnic2, Puerto Rican, 0, 0);
        %BuildHispCkbox(%eval(&CMAXNOCK+3), methnic3, Cuban, 0, 0);
        %BuildHispCkbox(%eval(&CMAXNOCK+4), methnic4, Other, 0, 1); 
        /* Father too. */
        %BuildHispCkbox(%eval(&CMAXNOCK+5), fethnic1, Mexican, 0, 0, Father:);
        %BuildHispCkbox(%eval(&CMAXNOCK+6), fethnic2, Puerto Rican, 0, 0);
        %BuildHispCkbox(%eval(&CMAXNOCK+7), fethnic3, Cuban, 0, 0);
        %BuildHispCkbox(%eval(&CMAXNOCK+8), fethnic4, Other, 0, 0); 
      %end;
    %else %if %index(&the_type, mormer) %then
      %do;
        %BuildHispCkbox(%eval(&CMAXNOCK+1), dethnic1, Mexican, 1, 0, &TAG);
        %BuildHispCkbox(%eval(&CMAXNOCK+2), dethnic2, Puerto Rican, 0, 0);
        %BuildHispCkbox(%eval(&CMAXNOCK+3), dethnic3, Cuban, 0, 0);
        %BuildHispCkbox(%eval(&CMAXNOCK+4), dethnic4, Other, 0, 1); 
      %end;
    put '</TABLE><BR>';

    %local CMAXTMP;
    /* Maintain the sequence by jumping past hisp boxes. */
    %if %index(&the_type, natmer) %then
      %let CMAXTMP=%eval(&CMAXNOCK+8);
    %else %if %index(&the_type, mormer) %then
      %let CMAXTMP=%eval(&CMAXNOCK+4);

    %if %index(&the_type, natmer) %then
      %do;
        %BuildMRckbox(%eval(&CMAXTMP+1), mrace1, White, 1, 0, &TAG);
        %BuildMRckbox(%eval(&CMAXTMP+2), mrace2, Black, 0, 0);
        %BuildMRckbox(%eval(&CMAXTMP+3), mrace3, Am. Indian or Alaskan, 0, 0);
        put '<TR>';
        %BuildMRckbox(%eval(&CMAXTMP+4), mrace4, Asian Indian, 0, 0);
        %BuildMRckbox(%eval(&CMAXTMP+5), mrace5, Chinese, 0, 0); 
        %BuildMRckbox(%eval(&CMAXTMP+6), mrace6, Filipino, 0, 0);
        put '<TR>';
        %BuildMRckbox(%eval(&CMAXTMP+7), mrace7, Japanese, 0, 0);
        %BuildMRckbox(%eval(&CMAXTMP+8), mrace8, Korean, 0, 0);
        %BuildMRckbox(%eval(&CMAXTMP+9), mrace9, Vietnamese, 0, 0);
        put '<TR>';
        %BuildMRckbox(%eval(&CMAXTMP+10), mrace10, Other Asian, 0, 0); 
        %BuildMRckbox(%eval(&CMAXTMP+11), mrace11, Native Hawaiian, 0, 0);
        %BuildMRckbox(%eval(&CMAXTMP+12), mrace12, Guamanian, 0, 0);
        put '<TR>';
        %BuildMRckbox(%eval(&CMAXTMP+13), mrace13, Samoan, 0, 0);
        %BuildMRckbox(%eval(&CMAXTMP+14), mrace14, Other Pacific Islander, 0, 0);
        %BuildMRckbox(%eval(&CMAXTMP+15), mrace15, Other, 0, 1);
        /* Father */
        %BuildMRckbox(%eval(&CMAXTMP+16), frace1, White, 0, 0, Father:);
        %BuildMRckbox(%eval(&CMAXTMP+17), frace2, Black, 0, 0);
        %BuildMRckbox(%eval(&CMAXTMP+18), frace3, Am. Indian or Alaskan, 0, 0);
        put '<TR>';
        %BuildMRckbox(%eval(&CMAXTMP+19), frace4, Asian Indian, 0, 0);
        %BuildMRckbox(%eval(&CMAXTMP+20), frace5, Chinese, 0, 0); 
        %BuildMRckbox(%eval(&CMAXTMP+21), frace6, Filipino, 0, 0);
        put '<TR>';
        %BuildMRckbox(%eval(&CMAXTMP+22), frace7, Japanese, 0, 0);
        %BuildMRckbox(%eval(&CMAXTMP+23), frace8, Korean, 0, 0);
        %BuildMRckbox(%eval(&CMAXTMP+24), frace9, Vietnamese, 0, 0);
        put '<TR>';
        %BuildMRckbox(%eval(&CMAXTMP+25), frace10, Other Asian, 0, 0); 
        %BuildMRckbox(%eval(&CMAXTMP+26), frace11, Native Hawaiian, 0, 0);
        %BuildMRckbox(%eval(&CMAXTMP+27), frace12, Guamanian, 0, 0);
        put '<TR>';
        %BuildMRckbox(%eval(&CMAXTMP+28), frace13, Samoan, 0, 0);
        %BuildMRckbox(%eval(&CMAXTMP+29), frace14, Other Pacific Islander, 0, 0);
        %BuildMRckbox(%eval(&CMAXTMP+30), frace15, Other, 0, 0);
        put '</TABLE><BR>';
      %end;
    %else %if %index(&the_type, mormer) %then
      %do;
        %BuildMRckbox(%eval(&CMAXTMP+1), race1, White, 1, 0, &TAG);
        %BuildMRckbox(%eval(&CMAXTMP+2), race2, Black, 0, 0);
        %BuildMRckbox(%eval(&CMAXTMP+3), race3, Am. Indian or Alaskan, 0, 0);
        put '<TR>';
        %BuildMRckbox(%eval(&CMAXTMP+4), race4, Asian Indian, 0, 0);
        %BuildMRckbox(%eval(&CMAXTMP+5), race5, Chinese, 0, 0); 
        %BuildMRckbox(%eval(&CMAXTMP+6), race6, Filipino, 0, 0);
        put '<TR>';
        %BuildMRckbox(%eval(&CMAXTMP+7), race7, Japanese, 0, 0);
        %BuildMRckbox(%eval(&CMAXTMP+8), race8, Korean, 0, 0);
        %BuildMRckbox(%eval(&CMAXTMP+9), race9, Vietnamese, 0, 0);
        put '<TR>';
        %BuildMRckbox(%eval(&CMAXTMP+10), race10, Other Asian, 0, 0); 
        %BuildMRckbox(%eval(&CMAXTMP+11), race11, Native Hawaiian, 0, 0);
        %BuildMRckbox(%eval(&CMAXTMP+12), race12, Guamanian, 0, 0);
        put '<TR>';
        %BuildMRckbox(%eval(&CMAXTMP+13), race13, Samoan, 0, 0);
        %BuildMRckbox(%eval(&CMAXTMP+14), race14, Other Pacific Islander, 0, 0);
        %BuildMRckbox(%eval(&CMAXTMP+15), race15, Other, 0, 1);
        put '</TABLE><BR>';
      %end;
  %end;
    /* Increase CMAX, desc[] and wid[] if add more here. */
%else %if &the_revreq eq 0 %then
  %do;
    /* Handle partial revisers polymorphically. */
    put '<BR>Multirace Checkboxes (if the state is a known partial ';
    put 'reviser and you are running a 2003-only query)<BR>';
    put '<I>Please note: selecting more than one of these checkboxes will ';
    put 'produce an "AND" query on all of the selected boxes</I>';
    put '<TABLE BORDER=1 CELLSPACING=0 BGCOLOR=#BEBEBE><TR>';
    %if %index(&the_type, natmer) %then
      %do;
        /* Want to pick up at the next highest element used by the input box
         * lines.     _________________
         */
        %BuildMRckbox(%eval(&CMAXNOCK+1), mrace_box1, White, 0, 0, &TAG);
        %BuildMRckbox(%eval(&CMAXNOCK+2), mrace_box2, Black, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+3), mrace_box3, Am. Indian or Alaskan, 0);
        put '<TR>';
        %BuildMRckbox(%eval(&CMAXNOCK+4), mrace_box4, Asian Indian, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+5), mrace_box5, Chinese, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+6), mrace_box6, Filipino, 0);
        put '<TR>';
        %BuildMRckbox(%eval(&CMAXNOCK+7), mrace_box7, Japanese, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+8), mrace_box8, Korean, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+9), mrace_box9, Vietnamese, 0);
        put '<TR>';
        %BuildMRckbox(%eval(&CMAXNOCK+10), mrace_box10, Other Asian, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+11), mrace_box11, Native Hawaiian, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+12), mrace_box12, Guamanian, 0);
        put '<TR>';
        %BuildMRckbox(%eval(&CMAXNOCK+13), mrace_box13, Samoan, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+14), mrace_box14, Other Pacific Islander, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+15), mrace_box15, Other, 0, 1);
        /* Father too. */
        %BuildMRckbox(%eval(&CMAXNOCK+16), frace_box1, White, 0, 0, Father:);
        %BuildMRckbox(%eval(&CMAXNOCK+17), frace_box2, Black, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+18), frace_box3, Am. Indian or Alaskan, 0);
        put '<TR>';
        %BuildMRckbox(%eval(&CMAXNOCK+19), frace_box4, Asian Indian, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+20), frace_box5, Chinese, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+21), frace_box6, Filipino, 0);
        put '<TR>';
        %BuildMRckbox(%eval(&CMAXNOCK+22), frace_box7, Japanese, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+23), frace_box8, Korean, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+24), frace_box9, Vietnamese, 0);
        put '<TR>';
        %BuildMRckbox(%eval(&CMAXNOCK+25), frace_box10, Other Asian, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+26), frace_box11, Native Hawaiian, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+27), frace_box12, Guamanian, 0);
        put '<TR>';
        %BuildMRckbox(%eval(&CMAXNOCK+28), frace_box13, Samoan, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+29), frace_box14, Other Pacific Islander, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+30), frace_box15, Other, 0, 0);
        put '</TABLE><BR>';
      %end;
    %else %if %index(&the_type, mormer) %then
      %do;
        %BuildMRckbox(%eval(&CMAXNOCK+1), race_box1, White, 0, 0, &TAG);
        %BuildMRckbox(%eval(&CMAXNOCK+2), race_box2, Black, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+3), race_box3, Am. Indian or Alaskan, 0);
        put '<TR>';
        %BuildMRckbox(%eval(&CMAXNOCK+4), race_box4, Asian Indian, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+5), race_box5, Chinese, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+6), race_box6, Filipino, 0);
        put '<TR>';
        %BuildMRckbox(%eval(&CMAXNOCK+7), race_box7, Japanese, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+8), race_box8, Korean, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+9), race_box9, Vietnamese, 0);
        put '<TR>';
        %BuildMRckbox(%eval(&CMAXNOCK+10), race_box10, Other Asian, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+11), race_box11, Native Hawaiian, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+12), race_box12, Guamanian, 0);
        put '<TR>';
        %BuildMRckbox(%eval(&CMAXNOCK+13), race_box13, Samoan, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+14), race_box14, Other Pacific Islander, 0);
        %BuildMRckbox(%eval(&CMAXNOCK+15), race_box15, Other, 0, 1);
        put '</TABLE><BR>';
      %end;
  %end;
%mend BuildListSelectWidgets;


 /*   Accepts:  nothing
  * "Returns":  nothing 
  *
  * Generate HTML to allow X by Y Selects for the freq query. 
  */
%macro BuildFreqSelectWidgets;
  %if &the_type eq natmer %then
    %do i=1 %to 2;;
      /* Build the "dropdown X by dropdown Y" line in Step 3. */
      put "<SELECT NAME=var&i>";
      put '  <OPTION VALUE="month" SELECTED>Month of Birth';
      put '  <OPTION VALUE="day">Day of Birth';
      put '  <OPTION VALUE="sex">Sex';
      put '  <OPTION VALUE="birthplc">Place of Delivery';
      put '  <OPTION VALUE="attend">Attendant';
      put '  <OPTION VALUE="mothmo">Mother Month of Birth';
      put '  <OPTION VALUE="mothday">Mother Day of Birth';
      put '  <OPTION VALUE="mothyr">Mother Year of Birth';
      put '  <OPTION VALUE="mothplc">Birthplace of Mother';
      put '  <OPTION VALUE="fathmo">Father Month of Birth';
      put '  <OPTION VALUE="fathday">Father Day of Birth';
      put '  <OPTION VALUE="fathyr">Father Year of Birth';
      put '  <OPTION VALUE="marstat">Marital Status';
      put '  <OPTION VALUE="mothhisp">Hispanic Origin-Mother';
      put '  <OPTION VALUE="fathhisp">Hispanic Origin-Father';
      put '  <OPTION VALUE="mrace">Race of Mother';
      put '  <OPTION VALUE="frace">Race of Father';
      put '  <OPTION VALUE="motheduc">Education of Mother';
      put '  <OPTION VALUE="mensemo">Mon Last Norm Menses';
      put '  <OPTION VALUE="mensedy">Day Last Norm Menses';
      put '  <OPTION VALUE="mensyr">Yr Last Norm Menses';
      put '  <OPTION VALUE="cbegmo">Mo Prenatal Care Beg';
      put '  <OPTION VALUE="nbegmo">N Mo Prenatal Care Beg';
      put '  <OPTION VALUE="plural">Plurality';
      put '  <OPTION VALUE="apgar">Apgar-5 Minute';
      put '  <OPTION VALUE="tob_use">Tob Use';
      put '  <OPTION VALUE="alc_use">Alc Use';
      put '  <OPTION VALUE="wgt_gain">Weight Gained';
      put '  <OPTION VALUE="stres">State of Residence';
      put '</SELECT>';
    %end;
  %else %if &the_type eq mormer %then
    %do;
      /* Death has a d prefix where the names are the same (and conflicting)
       * on nat. 
       */
      %do i=1 %to 2;
        put "<SELECT NAME=var&i>";
        put '  <OPTION VALUE="sex" SELECTED>Sex';
        put '  <OPTION VALUE="race">Race';
        put '  <OPTION VALUE="dmonth">Month of Death';
        put '  <OPTION VALUE="dday">Day of Death';
        put '  <OPTION VALUE="yr">Year of Death';
        put '  <OPTION VALUE="birthmo">Month of Birth';
        put '  <OPTION VALUE="birthdy">Day of Birth';
        put '  <OPTION VALUE="typ_plac">Type of Place Birth/Death';
        put "  <OPTION VALUE='marital'>Marital Status";
        put '  <OPTION VALUE="hispanic">Hispanic';
        put '  <OPTION VALUE="educ">Education';
        put '  <OPTION VALUE="dstres">State of Residence';
        put '  <OPTION VALUE="ageunit">Age Units';
        put '  <OPTION VALUE="state">State of Occurrence';
        put '</SELECT>';
        %if &i eq 1 %then
          %do;
            /* TODO for some reason, a dot (.) shows up in the HTML if don't
             * use %do...%end here
             */
            put '&nbsp;by&nbsp;';
          %end;
      %end;
    %end;
  %else
    %put "wiz2.sas: error unknown \&the_type";
%mend BuildFreqSelectWidgets;


 /*   Accepts:  index number of element being built, SAS var name, display
  *             string for user, whether to print header, whether to print
  *             ending new row, the string to distinguish mother, father and
  *             decedent.
  * "Returns":  nothing 
  *
  * Generates HTML for the hispanic checkboxes.  Could be combined with
  * BuildHispCkbox macro but kept separate to make code slightly easier to
  * read.
  */
%macro BuildMRckbox(num, name, lbl, printtitle, newrow, m_or_f);
  %if &printtitle eq 1 %then
    %do;
      put '<BR><I><CENTER>Alternative Multirace Checkboxes (please do not use ';
      put 'in combination with Race Checkbox String)</I><BR>';
      put '<TABLE BORDER=1 ALIGN="center" CELLSPACING=0 WIDTH=95%><TR>';
    %end;
  put "<TD>&m_or_f<TD><INPUT TYPE='checkbox' NAME='c&num' VALUE='&name'>&lbl";
  put "<INPUT TYPE='hidden' NAME='op&num' VALUE='eq'>";
  put "<INPUT TYPE='textbox' NAME='t&num' SIZE=1 VALUE='Y'>";
  %if &newrow eq 1 %then
    put '<TR>';
%mend BuildMRckbox;


 /*   Accepts:  index number of element being built, SAS var name, display
  *             string for user, whether to print header, whether to print
  *             ending new row, the string to distinguish mother, father and
  *             decedent
  * "Returns":  nothing 
  *
  * Generates HTML for the hispanic checkboxes.
  */
%macro BuildHispCkbox(num, name, lbl, printtitle, newrow, m_or_f);
  %if &printtitle eq 1 %then
    %do;
      put '<BR><I><CENTER>Alternative Hispanic Checkboxes (please do not ';
      put 'use in combination with Hispanic Checkbox String)</I><BR>';
      put '<TABLE BORDER=1 ALIGN="center" CELLSPACING=0 WIDTH=80%><TR>';
    %end;
  put "<TD>&m_or_f<TD><INPUT TYPE='checkbox' NAME='c&num' VALUE='&name'>&lbl";
  put "<INPUT TYPE='hidden' NAME='op&num' VALUE='eq'>";
  put "<INPUT TYPE='textbox' NAME='t&num' SIZE=1 VALUE='H'>";
  %if &newrow eq 1 %then
    put '<TR>';
%mend BuildHispCkbox;


 /*   Accepts:  nothing
  * "Returns":  nothing 
  *
  * Generates the final HTML to the user.
  */
%macro GenerateListOrFreqPage;
  %local RCRPTSTYLE;

  /* Uppercase (i.e. RightCase) first letter for title bar display. */
  data _NULL_;
    uc=translate(substr("&rptstyle", 1, 1),
                        'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
                        'abcdefghijklmnopqrstuvwxyz') ||
                 substr("&rptstyle", 2);

    call symput('RCRPTSTYLE', uc);
  run;

   /* One huge datastep just to produce an HTML form, most of which is the
    * same regardless of Simple List or Two-Way. 
    */
  data _NULL_;
    file _WEBOUT;
    put '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">';
    put '<HTML>';
    put '<HEAD>';
    put "  <TITLE>Build Query Step 3 of 4 (&the_fulltype &REVSTATUS &RCRPTSTYLE)</TITLE>";
    put '  <META NAME="author" CONTENT="Robert S. Heckel Jr. (BQH0)"> ';
    put '</HEAD> ';
    put '<BODY> ';
    put '  <BR><BR>';
    put '  <TABLE WIDTH=90% ALIGN="center" BORDER=0 CELLSPACING=0 CELLPADDING=1>';
    put '  <TR><TD BGCOLOR=#999999>';
    put '  <TABLE WIDTH=100% BORDER=0 CELLSPACING=0 CELLPADDING=0>';
    put '  <TR><TD BACKGROUND="http://mainframe.cdc.gov/sasweb/nchs/intrnet/y.gif">';
    put '  <FONT SIZE=+1 COLOR=#333333><I>';
    put '  <B>&nbsp;Refine Your ';
    put "  &the_fulltype &RCRPTSTYLE Query:";
    put '  </I></FONT></TABLE></TABLE>';
    put '  <TABLE BORDER=1 ALIGN="center" WIDTH="90%" BGCOLOR="#FFFFFF"';
    put '         CELLSPACING=0 CELLPADDING=5> ';
    put '    <FORM ACTION="http://mainframe.cdc.gov/sasweb/cgi-bin/broker"';
    put '          METHOD="GET" NAME="the_form"> ';
    put '      <INPUT TYPE="hidden" NAME="_DEBUG" VALUE="0"> ';
    put '      <INPUT TYPE="hidden" NAME="_SERVICE" VALUE="default"> ';
    put '      <INPUT TYPE="hidden" NAME="_PROGRAM" VALUE="nchscode.Dwiz3.sas"> ';
    put '    <TR><TD><CENTER> ';
    /* Generate HTML for the MAXNYR years from which the user can select. */
    %BuildYearWidget(&rptstyle)
    put '    </CENTER> ';
    put '    <TR><TD><CENTER> ';
    put "Select &REVSTATUS State:";
    put '      <SELECT NAME="state"> ';
    put '        <OPTION VALUE="AK">Alaska ';
    put '        <OPTION VALUE="AL">Alabama ';
    put '        <OPTION VALUE="AR">Arkansas ';
    put '        <OPTION VALUE="AS">American Samoa ';
    put '        <OPTION VALUE="AZ">Arizona ';
    put '        <OPTION VALUE="CA">California ';
    put '        <OPTION VALUE="CO">Colorado ';
    put '        <OPTION VALUE="CT">Connecticut ';
    put '        <OPTION VALUE="DE">Delaware ';
    put '        <OPTION VALUE="DC">DC ';
    put '        <OPTION VALUE="FL">Florida ';
    put '        <OPTION VALUE="GA">Georgia ';
    put '        <OPTION VALUE="GU">Guam ';
    put '        <OPTION VALUE="HI">Hawaii ';
    put '        <OPTION VALUE="ID">Idaho ';
    put '        <OPTION VALUE="IL">Illinois ';
    put '        <OPTION VALUE="IN">Indiana ';
    put '        <OPTION VALUE="IA">Iowa ';
    put '        <OPTION VALUE="KS">Kansas ';
    put '        <OPTION VALUE="KY">Kentucky ';
    put '        <OPTION VALUE="LA">Louisiana ';
    put '        <OPTION VALUE="MA">Massachusetts ';
    put '        <OPTION VALUE="MD">Maryland ';
    put '        <OPTION VALUE="ME">Maine ';
    put '        <OPTION VALUE="MI">Michigan ';
    put '        <OPTION VALUE="MN">Minnesota ';
    put '        <OPTION VALUE="MO">Missouri ';
    put '        <OPTION VALUE="MP">Norther Marianas ';
    put '        <OPTION VALUE="MS">Mississippi ';
    put '        <OPTION VALUE="MT">Montana ';
    put '        <OPTION VALUE="NC">North Carolina ';
    put '        <OPTION VALUE="ND">North Dakota ';
    put '        <OPTION VALUE="NE">Nebraska ';
    put '        <OPTION VALUE="NH">New Hampshire ';
    put '        <OPTION VALUE="NJ">New Jersey ';
    put '        <OPTION VALUE="NM">New Mexico ';
    put '        <OPTION VALUE="NV">Nevada ';
    put '        <OPTION VALUE="NY">New York State ';
    put '        <OPTION VALUE="YC">New York City ';
    put '        <OPTION VALUE="OH">Ohio ';
    put '        <OPTION VALUE="OK">Oklahoma ';
    put '        <OPTION VALUE="OR">Oregon ';
    put '        <OPTION VALUE="PA">Pennsylvania ';
    put '        <OPTION VALUE="PR">Puerto Rico ';
    put '        <OPTION VALUE="RI">Rhode Island ';
    put '        <OPTION VALUE="SC">South Carolina ';
    put '        <OPTION VALUE="SD">South Dakota ';
    put '        <OPTION VALUE="TN">Tennessee ';
    put '        <OPTION VALUE="TX">Texas ';
    put '        <OPTION VALUE="UT">Utah ';
    put '        <OPTION VALUE="VT">Vermont ';
    put '        <OPTION VALUE="VA">Virginia ';
    put '        <OPTION VALUE="VI">Virgin Islands ';
    put '        <OPTION VALUE="WA">Washington ';
    put '        <OPTION VALUE="WV">West Virginia ';
    put '        <OPTION VALUE="WI">Wisconsin ';
    put '        <OPTION VALUE="WY">Wyoming ';
    /* Waiting for MVDS to come online.  Pathetic virus incubator IE ignores
     * DISABLED tags so have to comment it out. 
     */
    ***put '        <OPTION VALUE="XX">All States ';
    put '      </SELECT> ';
    put '      <TR><TD><CENTER> ';
    %if &rptstyle eq freq %then
      %do;
        %BuildFreqSelectWidgets;
      %end;
    %else %if &rptstyle eq list %then
      %do;
        %BuildListSelectWidgets;
      %end;
    put '      <TR><TD><CENTER> ';
    put '      <INPUT TYPE="submit" VALUE="Next>"> ';
    put '      </CENTER> ';
    /* Macrovariables created on this or prior page to be passed to the next
     * page.  They must be declared as globals in wiz3.  The 'the_' prefix
     * indicates creation on a page other than the current.
     */
    put "      <INPUT TYPE='hidden' NAME='the_maxnyr' VALUE=&MAXNYR> ";
    put "      <INPUT TYPE='hidden' NAME='the_currentyr' VALUE=&CURRENTYR> ";
    put "      <INPUT TYPE='hidden' NAME='the_cmax' VALUE=&CMAX> ";
    put "      <INPUT TYPE='hidden' NAME='the_revstatus' VALUE=&REVSTATUS> ";
    put "      <INPUT TYPE='hidden' NAME='the_rptstyle' VALUE=&rptstyle> ";
    put "      <INPUT TYPE='hidden' NAME='the_type' VALUE=&the_type> ";
    put "      <INPUT TYPE='hidden' NAME='the_revreq' VALUE=&the_revreq> ";
    put "      <INPUT TYPE='hidden' NAME='the_userid' VALUE=&the_userid> ";
    put '    </FORM> ';
    put '  </TABLE> ';
    put '  <BR><BR> ';
    put '  <BR><BR> ';
    %include "&STDFOOTR";
    put '</BODY> ';
    put '</HTML> ';
  run;
%mend GenerateListOrFreqPage;
%GenerateListOrFreqPage
