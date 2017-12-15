options NOsource NOsource2;
 /*---------------------------------------------------------------------------
  *     Name: BQH0.SAS.INTRNET.PDS(WIZ3)
  *
  *  Summary: Generate a dynamic page from which user can further refine the 
  *           query parameters using a wizard-like interface.
  *
  *  Created: Fri 21 Mar 2003 10:43:13 (Bob Heckel)
  *      RCS:
  *  $Log: wiz3.sas,v $
  *  Revision 1.16  2003/12/19 15:50:11  bqh0
  *  Added natality non-reviser and reviser query capability.
  *  Added output to MS Excel option to avoid IE URL length limitation.
  *  Improved interface.
  *
  *  Revision 1.15  2003/10/27 21:25:44  bqh0
  *  Added Racebox String and Hispanic String to the reviser
  *  choices per Adrienne Rouse.
  *
  *  Revision 1.14  2003/10/15 14:50:20  bqh0
  *  Add 'country of birth' widget to reviser state query choices.
  *
  *  Revision 1.13  2003/10/06 20:59:16  bqh0
  *  Bugfixed gap in multirace checkbox series (element 30).
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
  *  Revision 1.6  2003/07/15 20:17:55  bqh0
  *  Forgot to do the JavaScript on looping variables (e.g. days).
  *
  *  Revision 1.5  2003/07/15 20:13:09  bqh0
  *  Use JavaScript to automatically unselect 'All' checkbox (two-way table
  *  queries only) when use chooses at least one other checkbox.
  *
  *  Revision 1.4  2003/07/11 20:24:35  bqh0
  *  Detect FIPS & multirace states and warn user, clean up and
  *  standardize titles.
  *
  *  Revision 1.3  2003/07/09 19:36:56  bqh0
  *  Improve error trap on requested files that don't exist.  Provide query
  *  details in the output
  *
  *  Revision 1.2  2003/07/09 14:13:04  bqh0
  *  Initial mods for dev version.
  *
  *---------------------------------------------------------------------------
  */

  /* DEBUG toggle */
***options NOsource NOsource2 NOmlogic NOsymbolgen NOfullstimer;
options NOsource NOsource2 mlogic mprint symbolgen fullstimer;


%global STDFOOTR;
%let STDFOOTR=BQH0.SAS.INTRNET.PDS(STDFOOTR);

 /* Parameters provided by the HIDDEN tags on the previous page: */
%global the_type the_rptstyle the_currentyr the_maxnyr the_cmax the_userid
        the_userid the_revstatus the_revreq
        ;
 /* Other important macrovars provided by the previous
  * form submission(s): 
  * year1-N e.g. 03
  * state, c1-N e.g. AK
  * c1 for checkbox e.g. certno
  * op1 for operator e.g. =
  * t1 e.g. for textbox data 000002
  */

 /* E.g. MORMER */
%let the_type=%upcase(&the_type);

 /*   Accepts:  nothing
  * "Returns":  a 4 digit year
  *
  * Convert 2 digit year.
  */
%macro YrTwo2Four;
  %global FREQYR4;

  %if %sysfunc(indexw(" 90 91 92 93 94 95 96 97 98 99 ", &freqselyear)) %then
    %let FREQYR4=%eval(1900+&freqselyear);

  %if %sysfunc(indexw(" 00 01 02 03 04 05 06 07 08 09 ", &freqselyear)) %then
    %let FREQYR4=%eval(2000+&freqselyear);
%mend YrTwo2Four;
%YrTwo2Four


 /*   Accepts:  nothing but uses globals
  * "Returns":  a string (e.g.  X X X X 04) 
  *
  * Determine which year checkbox(es) are checked. 
  * TODO raise error if i eq 1 (no boxes ckd)
  */
%macro YrsRequested;
  %global yearsrequest;
  %local i j;

  %if &the_rptstyle eq list %then
    %do i=1 %to &the_maxnyr;
      %global year&i;
      %if &&year&i ne  %then 
        %do;
          /* TODO mult resolution -- elim temp variable */
          %let foo=&&year&i;
          /* Concatenate the years to a single string. */
          %let yearsrequest=&yearsrequest &foo ;
        %end;
      %else
        /* 'X' is used as a delimiter/placeholder for looping over years.  The
         * &yearsrequest string is later parsed to determine which year(s) have
         * been chosen by the user.
         */
        %let yearsrequest=&yearsrequest X;
    %end;
  /* Design change -- Single year only (for now, due to lack of
   * mainframe/IntrNet resources). 
   */
  %else %if &the_rptstyle eq freq %then
    %do;
      /* year1, year2, etc. is not generated by freq query's select widget,
       * so we must do it here.  TODO this is an ugly hack caused by limiting
       * the freq to one year
       */
      %do j=1 %to &the_maxnyr;
        %global year&j;
        %let year&j =  ;
      %end;

      /* Must edit this section yearly. */
      %if &freqselyear eq 00 %then
        %do;
          %let year1 = &freqselyear ;
          %let yearsrequest=&freqselyear X X X X ;
        %end;
      %else %if &freqselyear eq 01 %then
        %do;
          %let year2 = &freqselyear ;
          %let yearsrequest=X &freqselyear X X X ;
        %end;
      %else %if &freqselyear eq 02 %then
        %do;
          %let year3 = &freqselyear ;
          %let yearsrequest=X X &freqselyear X X ;
        %end;
      %else %if &freqselyear eq 03 %then
        %do;
          %let year4 = &freqselyear ;
          %let yearsrequest=X X X &freqselyear X ;
        %end;
      %else %if &freqselyear eq 04 %then
        %do;
          %let year5 = &freqselyear ;
          %let yearsrequest=X X X X &freqselyear ;
        %end;
    %end;
%mend YrsRequested;
%YrsRequested


 /* A nightly-generated dataset exists on the mainframe to determine which
  * BF19 merged file(s) to use, see INTRLATE JobTrac code
  * MISC.JOBTRAC.JCL(BQH0LATR)
  *
  * E.g.
  * BF19.NDX0102.MORMER
  * BF19.XXX0199.MORMER    <---all 57 states placeholder, file doesn't exist
  *
  * TODO when all years are in Register, use that instead of this
  */

 /*   Accepts: 2 char state
  *            string mormer or natmer
  *            2 digit year
  *            a counter 1-N for closeds or 1-N for opens 
  *            a string indicating if it's an open or closed year.  
  *
  * "Returns": the highest 2 digit shipment number and extension (e.g.
  *            MORMER1), if any, of the closed or open year passed in.
  */
%macro ShipAndExt(st, ty, yr, num);
  /* TODO de-hardcode */
  %global ship1 ship2 ship3 ship4 ship5 ext1 ext2 ext3 ext4 ext5;

  libname L 'DWJ2.INTRNLIB' DISP=SHR;

  data _NULL_;
    set L.latebf19;

    /* E.g. AKX9917 */
    middle=scan(fn, 2, '.');
    /* E.g. NATMER1 */
    mergetype=scan(fn, 3, '.');

    if substr(middle, 1, 2) eq "&st" 
       and substr(middle, 4, 2) eq "&yr" 
       and mergetype =: %upcase("&ty") then
      do;
        call symput("ship&num", substr(middle, 6));
        call symput("ext&num", upcase(mergetype));
      end;
  run;
%mend ShipAndExt;


 /*   Accepts:  nothing but uses globals
  * "Returns":  
  *
  * Build ship lines for each year.
  */
%macro RunShipAndExtMcr;
  %local i;

  %do i=1 %to &the_maxnyr;
    /* E.g.      ND       NATMER    02     */
    %ShipAndExt(&state, &the_type, &&year&i, &i)
  %end;
%mend RunShipAndExtMcr;
%RunShipAndExtMcr


 /* The next several BuildXCkbxs macros build the checkboxes that are used on
  * the same screen where the merge filename is selected.  Used by Freq Style
  * queries only but a single macro is sometimes shared between nat and mort.
  */

%macro BuildSexCkbxs;
  put ' <TR><TD><CENTER>Sex:<BR>';
  put ' <INPUT TYPE="checkbox" NAME="sex1" VALUE="1" onClick="UnCkAllBox(document.the_form, this)">Male (1)';
  put ' <INPUT TYPE="checkbox" NAME="sex2" VALUE="2" onClick="UnCkAllBox(document.the_form, this)">Female (2)';
  put ' <INPUT TYPE="checkbox" NAME="sex3" VALUE="9" onClick="UnCkAllBox(document.the_form, this)">Not Classifiable (9)';
  put ' <BR><INPUT TYPE="checkbox" NAME="sex" VALUE="all" CHECKED>All ';
  put ' </CENTER> ';
%mend BuildSexCkbxs;


 /*   Accepts:  part of the display title and the input prefix letter (if any)
  * "Returns":  nothing.
  */
%macro BuildRaceCkbxs(lbl, x);
  put " <TR><TD><CENTER>&lbl Race:<BR>";
  put " <INPUT TYPE='checkbox' NAME='&x.race1' VALUE='1' onClick='UnCkAllBox(document.the_form, this)'>White (1) ";
  put " <INPUT TYPE='checkbox' NAME='&x.race2' VALUE='2' onClick='UnCkAllBox(document.the_form, this)'>Black (2) ";
  put " <INPUT TYPE='checkbox' NAME='&x.race3' VALUE='3' onClick='UnCkAllBox(document.the_form, this)'>Indian (3) ";
  put " <INPUT TYPE='checkbox' NAME='&x.race4' VALUE='4' onClick='UnCkAllBox(document.the_form, this)'>Asian (4) ";
  put " <INPUT TYPE='checkbox' NAME='&x.race5' VALUE='5' onClick='UnCkAllBox(document.the_form, this)'>Japanese (5) ";
  put " <INPUT TYPE='checkbox' NAME='&x.race6' VALUE='6' onClick='UnCkAllBox(document.the_form, this)'>Hawaiian (6) ";
  put " <INPUT TYPE='checkbox' NAME='&x.race7' VALUE='7' onClick='UnCkAllBox(document.the_form, this)'>Filipino (7) ";
  put " <INPUT TYPE='checkbox' NAME='&x.race8' VALUE='8' onClick='UnCkAllBox(document.the_form, this)'>Other (8) ";
  put " <INPUT TYPE='checkbox' NAME='&x.race9' VALUE='A' onClick='UnCkAllBox(document.the_form, this)'>Asian Indian (A) ";
  put " <INPUT TYPE='checkbox' NAME='&x.race10' VALUE='B' onClick='UnCkAllBox(document.the_form, this)'>Korean (B) ";
  put " <INPUT TYPE='checkbox' NAME='&x.race11' VALUE='C' onClick='UnCkAllBox(document.the_form, this)'>Samoan (C) ";
  put " <INPUT TYPE='checkbox' NAME='&x.race12' VALUE='D' onClick='UnCkAllBox(document.the_form, this)'>Vietnamese (D) ";
  put " <INPUT TYPE='checkbox' NAME='&x.race13' VALUE='E' onClick='UnCkAllBox(document.the_form, this)'>Guamanian (E) ";
  put " <INPUT TYPE='checkbox' NAME='&x.race14' VALUE='F' onClick='UnCkAllBox(document.the_form, this)'>Multi-racial (F) ";
  put " <INPUT TYPE='checkbox' NAME='&x.race15' VALUE='0' onClick='UnCkAllBox(document.the_form, this)'>Other Entries (0) ";
  put " <INPUT TYPE='checkbox' NAME='&x.race16' VALUE='9' onClick='UnCkAllBox(document.the_form, this)'>Not Reported (9) ";
  put " <BR><INPUT TYPE='checkbox' NAME='&x.race' VALUE='all' CHECKED>All ";
  put ' </CENTER> ';
%mend BuildRaceCkbxs;


 /*   Accepts:  part of the display title and the input prefix letter (if any)
  * "Returns":  nothing.
  */
%macro BuildMonthCkbxs(lbl, x);
  put " <TR><TD><CENTER>Month of &lbl:<BR>";
  put '<INPUT TYPE=checkbox NAME=month1 VALUE=01 onClick="UnCkAllBox(document.the_form, this)">January (01)';
  put '<INPUT TYPE=checkbox NAME=month2 VALUE=02 onClick="UnCkAllBox(document.the_form, this)">February (02)';
  put '<INPUT TYPE=checkbox NAME=month3 VALUE=03 onClick="UnCkAllBox(document.the_form, this)">March (03)';
  put '<INPUT TYPE=checkbox NAME=month4 VALUE=04 onClick="UnCkAllBox(document.the_form, this)">April (04)';
  put '<INPUT TYPE=checkbox NAME=month5 VALUE=05 onClick="UnCkAllBox(document.the_form, this)">May (05)';
  put '<INPUT TYPE=checkbox NAME=month6 VALUE=06 onClick="UnCkAllBox(document.the_form, this)">June (06)';
  put '<INPUT TYPE=checkbox NAME=month7 VALUE=07 onClick="UnCkAllBox(document.the_form, this)">July (07)';
  put '<INPUT TYPE=checkbox NAME=month8 VALUE=08 onClick="UnCkAllBox(document.the_form, this)">August (08)';
  put '<INPUT TYPE=checkbox NAME=month9 VALUE=09 onClick="UnCkAllBox(document.the_form, this)">September (09)';
  put '<INPUT TYPE=checkbox NAME=month10 VALUE=10 onClick="UnCkAllBox(document.the_form, this)">October (10)';
  put '<INPUT TYPE=checkbox NAME=month11 VALUE=11 onClick="UnCkAllBox(document.the_form, this)">November (11)';
  put '<INPUT TYPE=checkbox NAME=month12 VALUE=12 onClick="UnCkAllBox(document.the_form, this)">December (12)';
  put '<INPUT TYPE=checkbox NAME=month13 VALUE=99 onClick="UnCkAllBox(document.the_form, this)">Not Classifiable (99)';
  put " <BR><INPUT TYPE='checkbox' NAME='&x' VALUE='all' CHECKED>All ";
  put ' </CENTER> ';
%mend BuildMonthCkbxs;


 /*   Accepts:  number of days, the display title and the input name.
  * "Returns":  nothing.
  *  TODO not working, using the dumb ones for now
  */
%macro BuildDayCkbxs(ndays, daytitle, x);
  %local i;

  put "<TR><TD><CENTER>Day of &daytitle:<BR>";
  %do i=1 %to &ndays;
    /* Want to left zero pad. */
    %if &i < 10 %then
      %do;
        put " <INPUT TYPE=checkbox NAME=&x&i VALUE=0&i onClick='UnCkAllBox(document.the_form, this)'>&i";
      %end;
    %else
      %do;
        put " <INPUT TYPE=checkbox NAME=&x&i VALUE=&i onClick='UnCkAllBox(document.the_form, this)'>&i";
      %end;
  %end;
  put "<BR><INPUT TYPE=checkbox NAME=&x VALUE=all CHECKED>All ";
  put '</CENTER> ';
%mend BuildDayCkbxs;


%macro BuildTyplacCkbxs;
  put ' <TR><TD><CENTER>Type/Place of Death<BR>';
  put ' <INPUT TYPE="checkbox" NAME="typlac1" VALUE="1" onClick="UnCkAllBox(document.the_form, this)">Inpatient (1) ';
  put ' <INPUT TYPE="checkbox" NAME="typlac2" VALUE="2" onClick="UnCkAllBox(document.the_form, this)">Outpatient/ER (2) ';
  put ' <INPUT TYPE="checkbox" NAME="typlac3" VALUE="3" onClick="UnCkAllBox(document.the_form, this)">DOA (3) ';
  put ' <INPUT TYPE="checkbox" NAME="typlac4" VALUE="4" onClick="UnCkAllBox(document.the_form, this)">Status Unknown (4) ';
  put ' <INPUT TYPE="checkbox" NAME="typlac5" VALUE="5" onClick="UnCkAllBox(document.the_form, this)">Nursing Home (5) ';
  put ' <INPUT TYPE="checkbox" NAME="typlac6" VALUE="6" onClick="UnCkAllBox(document.the_form, this)">Residence of Decedent (6) ';
  put ' <INPUT TYPE="checkbox" NAME="typlac7" VALUE="7" onClick="UnCkAllBox(document.the_form, this)">Other (7) ';
  put ' <INPUT TYPE="checkbox" NAME="typlac8" VALUE="9" onClick="UnCkAllBox(document.the_form, this)">Not Classifiable (9) ';
  put ' <BR><INPUT TYPE="checkbox" NAME="typlac" VALUE="all" CHECKED>All ';
  put ' </CENTER> ';
%mend BuildTyplacCkbxs;


%macro BuildMarstatCkbxs;
  put ' <TR><TD><CENTER>Marital Status:<BR>';
  put ' <INPUT TYPE="checkbox" NAME="marstat1" VALUE="1" onClick="UnCkAllBox(document.the_form, this)">Married (1) ';
  put ' <INPUT TYPE="checkbox" NAME="marstat2" VALUE="2" onClick="UnCkAllBox(document.the_form, this)">Never Married, Single (2) ';
  put ' <INPUT TYPE="checkbox" NAME="marstat3" VALUE="3" onClick="UnCkAllBox(document.the_form, this)">Widowed (3) ';
  put ' <INPUT TYPE="checkbox" NAME="marstat4" VALUE="4" onClick="UnCkAllBox(document.the_form, this)">Divorced (4) ';
  put ' <INPUT TYPE="checkbox" NAME="marstat5" VALUE="9" onClick="UnCkAllBox(document.the_form, this)">Not Classifiable (9) ';
  put ' <BR><INPUT TYPE="checkbox" NAME="marstat" VALUE="all" CHECKED>All ';
  put ' </CENTER> ';
%mend BuildMarstatCkbxs;


 /*   Accepts:  part of the display title and, if nat, the input prefix 
  *             variable to differential mother and father
  * "Returns":  nothing
  */
%macro BuildHispCkbxs(lbl, x);
  put " <TR><TD><CENTER>Hispanic Origin &lbl.:<BR>";
  put " <INPUT TYPE='checkbox' NAME='&x.hisp0' VALUE='0' onClick='UnCkAllBox(document.the_form, this)'>Non-Hispanic (0) ";
  put " <INPUT TYPE='checkbox' NAME='&x.hisp1' VALUE='1' onClick='UnCkAllBox(document.the_form, this)'>Mexican (1) ";
  put " <INPUT TYPE='checkbox' NAME='&x.hisp2' VALUE='2' onClick='UnCkAllBox(document.the_form, this)'>Puerto Rican (2) ";
  put " <INPUT TYPE='checkbox' NAME='&x.hisp3' VALUE='3' onClick='UnCkAllBox(document.the_form, this)'>Cuban (3) ";
  put " <INPUT TYPE='checkbox' NAME='&x.hisp4' VALUE='4' onClick='UnCkAllBox(document.the_form, this)'>Central or S. American (4) ";
  put " <INPUT TYPE='checkbox' NAME='&x.hisp5' VALUE='5' onClick='UnCkAllBox(document.the_form, this)'>Other and Unknown (5) ";
  put " <INPUT TYPE='checkbox' NAME='&x.hisp9' VALUE='9' onClick='UnCkAllBox(document.the_form, this)'>Not Classifiable (9) ";
  put " <BR><INPUT TYPE='checkbox' NAME='&x.hisp' VALUE='all' CHECKED>All ";
  put ' </CENTER> ';
%mend BuildHispCkbxs;


 /*   Accepts:  part of the display title and the input prefix letter (if any)
  * "Returns":  nothing.
  */
%macro BuildEducCkbxs(lbl, x);
  put " <TR><TD><CENTER>&lbl Education:<BR>";
  put "<INPUT TYPE='checkbox' NAME='&x.educ0' VALUE='00' onClick='UnCkAllBox(document.the_form, this)'>Elementary or Secondary (00)";
  put "<INPUT TYPE='checkbox' NAME='&x.educ1' VALUE='01' onClick='UnCkAllBox(document.the_form, this)'>Elementary or Secondary (01)";
  put "<INPUT TYPE='checkbox' NAME='&x.educ2' VALUE='02' onClick='UnCkAllBox(document.the_form, this)'>Elementary or Secondary (02)";
  put "<INPUT TYPE='checkbox' NAME='&x.educ3' VALUE='03' onClick='UnCkAllBox(document.the_form, this)'>Elementary or Secondary (03)";
  put "<INPUT TYPE='checkbox' NAME='&x.educ4' VALUE='04' onClick='UnCkAllBox(document.the_form, this)'>Elementary or Secondary (04)";
  put "<INPUT TYPE='checkbox' NAME='&x.educ5' VALUE='05' onClick='UnCkAllBox(document.the_form, this)'>Elementary or Secondary (05)";
  put "<INPUT TYPE='checkbox' NAME='&x.educ6' VALUE='06' onClick='UnCkAllBox(document.the_form, this)'>Elementary or Secondary (06)";
  put "<INPUT TYPE='checkbox' NAME='&x.educ7' VALUE='07' onClick='UnCkAllBox(document.the_form, this)'>Elementary or Secondary (07)";
  put "<INPUT TYPE='checkbox' NAME='&x.educ8' VALUE='08' onClick='UnCkAllBox(document.the_form, this)'>Elementary or Secondary (08)";
  put "<INPUT TYPE='checkbox' NAME='&x.educ9' VALUE='09' onClick='UnCkAllBox(document.the_form, this)'>Elementary or Secondary (09)";
  put "<INPUT TYPE='checkbox' NAME='&x.educ10' VALUE='10' onClick='UnCkAllBox(document.the_form, this)'>Elementary or Secondary (10)";
  put "<INPUT TYPE='checkbox' NAME='&x.educ11' VALUE='11' onClick='UnCkAllBox(document.the_form, this)'>Elementary or Secondary (11)";
  put "<INPUT TYPE='checkbox' NAME='&x.educ12' VALUE='12' onClick='UnCkAllBox(document.the_form, this)'>Elementary or Secondary (12)";
  put "<INPUT TYPE='checkbox' NAME='&x.educ13' VALUE='13' onClick='UnCkAllBox(document.the_form, this)'>1 Year College (13)";
  put "<INPUT TYPE='checkbox' NAME='&x.educ14' VALUE='14' onClick='UnCkAllBox(document.the_form, this)'>2 Year College (14)";
  put "<INPUT TYPE='checkbox' NAME='&x.educ15' VALUE='15' onClick='UnCkAllBox(document.the_form, this)'>3 Year College (15)";
  put "<INPUT TYPE='checkbox' NAME='&x.educ16' VALUE='16' onClick='UnCkAllBox(document.the_form, this)'>4 Year College (16)";
  put "<INPUT TYPE='checkbox' NAME='&x.educ17' VALUE='17' onClick='UnCkAllBox(document.the_form, this)'>5+ Year College (17)";
  put "<INPUT TYPE='checkbox' NAME='&x.educ18' VALUE='18' onClick='UnCkAllBox(document.the_form, this)'>Not Classifiable (99)";
  put " <BR><INPUT TYPE='checkbox' NAME='&x.educ' VALUE='all' CHECKED>All ";
  put ' </CENTER> ';
%mend BuildEducCkbxs;


 /*   Accepts:  part of the display title and the input prefix variable
  * "Returns":  nothing.
  */
%macro BuildStateCkbxs(lbl, x);
  put " <TR><TD><CENTER>State of &lbl:<BR>";
  put "<INPUT TYPE='checkbox' NAME='&x.1' VALUE='01' onClick='UnCkAllBox(document.the_form, this)'>Alabama (01)";
  put "<INPUT TYPE='checkbox' NAME='&x.2' VALUE='02' onClick='UnCkAllBox(document.the_form, this)'>Alaska (02)";
  put "<INPUT TYPE='checkbox' NAME='&x.3' VALUE='03' onClick='UnCkAllBox(document.the_form, this)'>Arizona (03)";
  put "<INPUT TYPE='checkbox' NAME='&x.4' VALUE='04' onClick='UnCkAllBox(document.the_form, this)'>Arkansas (04)";
  put "<INPUT TYPE='checkbox' NAME='&x.5' VALUE='05' onClick='UnCkAllBox(document.the_form, this)'>California (05)";
  put "<INPUT TYPE='checkbox' NAME='&x.6' VALUE='06' onClick='UnCkAllBox(document.the_form, this)'>Colorado (06)";
  put "<INPUT TYPE='checkbox' NAME='&x.7' VALUE='07' onClick='UnCkAllBox(document.the_form, this)'>Connecticut (07)";
  put "<INPUT TYPE='checkbox' NAME='&x.8' VALUE='08' onClick='UnCkAllBox(document.the_form, this)'>Delaware (08)";
  put "<INPUT TYPE='checkbox' NAME='&x.9' VALUE='09' onClick='UnCkAllBox(document.the_form, this)'>DC (09)";
  put "<INPUT TYPE='checkbox' NAME='&x.10' VALUE='10' onClick='UnCkAllBox(document.the_form, this)'>Florida (10)";
  put "<INPUT TYPE='checkbox' NAME='&x.11' VALUE='11' onClick='UnCkAllBox(document.the_form, this)'>Georgia (11)";
  put "<INPUT TYPE='checkbox' NAME='&x.12' VALUE='12' onClick='UnCkAllBox(document.the_form, this)'>Hawaii (12)";
  put "<INPUT TYPE='checkbox' NAME='&x.13' VALUE='13' onClick='UnCkAllBox(document.the_form, this)'>Idaho (13)";
  put "<INPUT TYPE='checkbox' NAME='&x.14' VALUE='14' onClick='UnCkAllBox(document.the_form, this)'>Illinois (14)";
  put "<INPUT TYPE='checkbox' NAME='&x.15' VALUE='15' onClick='UnCkAllBox(document.the_form, this)'>Indiana (15)";
  put "<INPUT TYPE='checkbox' NAME='&x.16' VALUE='16' onClick='UnCkAllBox(document.the_form, this)'>Iowa (16)";
  put "<INPUT TYPE='checkbox' NAME='&x.17' VALUE='17' onClick='UnCkAllBox(document.the_form, this)'>Kansas (17)";
  put "<INPUT TYPE='checkbox' NAME='&x.18' VALUE='18' onClick='UnCkAllBox(document.the_form, this)'>Kentucky (18)";
  put "<INPUT TYPE='checkbox' NAME='&x.19' VALUE='19' onClick='UnCkAllBox(document.the_form, this)'>Louisiana (19)";
  put "<INPUT TYPE='checkbox' NAME='&x.20' VALUE='20' onClick='UnCkAllBox(document.the_form, this)'>Maine (20)";
  put "<INPUT TYPE='checkbox' NAME='&x.21' VALUE='21' onClick='UnCkAllBox(document.the_form, this)'>Maryland (21)";
  put "<INPUT TYPE='checkbox' NAME='&x.22' VALUE='22' onClick='UnCkAllBox(document.the_form, this)'>Massachusetts (22)";
  put "<INPUT TYPE='checkbox' NAME='&x.23' VALUE='23' onClick='UnCkAllBox(document.the_form, this)'>Michigan (23)";
  put "<INPUT TYPE='checkbox' NAME='&x.24' VALUE='24' onClick='UnCkAllBox(document.the_form, this)'>Minnesota (24)";
  put "<INPUT TYPE='checkbox' NAME='&x.25' VALUE='25' onClick='UnCkAllBox(document.the_form, this)'>Mississippi (25)";
  put "<INPUT TYPE='checkbox' NAME='&x.26' VALUE='26' onClick='UnCkAllBox(document.the_form, this)'>Missouri (26)";
  put "<INPUT TYPE='checkbox' NAME='&x.27' VALUE='27' onClick='UnCkAllBox(document.the_form, this)'>Montana (27)";
  put "<INPUT TYPE='checkbox' NAME='&x.28' VALUE='28' onClick='UnCkAllBox(document.the_form, this)'>Nebraska (28)";
  put "<INPUT TYPE='checkbox' NAME='&x.29' VALUE='29' onClick='UnCkAllBox(document.the_form, this)'>Nevada (29)";
  put "<INPUT TYPE='checkbox' NAME='&x.30' VALUE='30' onClick='UnCkAllBox(document.the_form, this)'>New Hampshire (30)";
  put "<INPUT TYPE='checkbox' NAME='&x.31' VALUE='31' onClick='UnCkAllBox(document.the_form, this)'>New Jersey (31)";
  put "<INPUT TYPE='checkbox' NAME='&x.32' VALUE='32' onClick='UnCkAllBox(document.the_form, this)'>New Mexico (32)";
  put "<INPUT TYPE='checkbox' NAME='&x.33' VALUE='33' onClick='UnCkAllBox(document.the_form, this)'>New York State (33)";
  put "<INPUT TYPE='checkbox' NAME='&x.34' VALUE='34' onClick='UnCkAllBox(document.the_form, this)'>North Carolina (34)";
  put "<INPUT TYPE='checkbox' NAME='&x.35' VALUE='35' onClick='UnCkAllBox(document.the_form, this)'>North Dakota (35)";
  put "<INPUT TYPE='checkbox' NAME='&x.36' VALUE='36' onClick='UnCkAllBox(document.the_form, this)'>Ohio (36)";
  put "<INPUT TYPE='checkbox' NAME='&x.37' VALUE='37' onClick='UnCkAllBox(document.the_form, this)'>Oklahoma (37)";
  put "<INPUT TYPE='checkbox' NAME='&x.38' VALUE='38' onClick='UnCkAllBox(document.the_form, this)'>Oregon (38)";
  put "<INPUT TYPE='checkbox' NAME='&x.39' VALUE='39' onClick='UnCkAllBox(document.the_form, this)'>Pennsylvania (39)";
  put "<INPUT TYPE='checkbox' NAME='&x.40' VALUE='40' onClick='UnCkAllBox(document.the_form, this)'>Rhode Island (40)";
  put "<INPUT TYPE='checkbox' NAME='&x.41' VALUE='41' onClick='UnCkAllBox(document.the_form, this)'>South Carolina (41)";
  put "<INPUT TYPE='checkbox' NAME='&x.42' VALUE='42' onClick='UnCkAllBox(document.the_form, this)'>South Dakota (42)";
  put "<INPUT TYPE='checkbox' NAME='&x.43' VALUE='43' onClick='UnCkAllBox(document.the_form, this)'>Tennessee (43)";
  put "<INPUT TYPE='checkbox' NAME='&x.44' VALUE='44' onClick='UnCkAllBox(document.the_form, this)'>Texas (44)";
  put "<INPUT TYPE='checkbox' NAME='&x.45' VALUE='45' onClick='UnCkAllBox(document.the_form, this)'>Utah (45)";
  put "<INPUT TYPE='checkbox' NAME='&x.46' VALUE='46' onClick='UnCkAllBox(document.the_form, this)'>Vermont (46)";
  put "<INPUT TYPE='checkbox' NAME='&x.47' VALUE='47' onClick='UnCkAllBox(document.the_form, this)'>Virginia (47)";
  put "<INPUT TYPE='checkbox' NAME='&x.48' VALUE='48' onClick='UnCkAllBox(document.the_form, this)'>Washington (48)";
  put "<INPUT TYPE='checkbox' NAME='&x.49' VALUE='49' onClick='UnCkAllBox(document.the_form, this)'>West Virginia (49)";
  put "<INPUT TYPE='checkbox' NAME='&x.50' VALUE='50' onClick='UnCkAllBox(document.the_form, this)'>Wisconsin (50)";
  put "<INPUT TYPE='checkbox' NAME='&x.51' VALUE='51' onClick='UnCkAllBox(document.the_form, this)'>Wyoming (51)";
  put "<INPUT TYPE='checkbox' NAME='&x.52' VALUE='52' onClick='UnCkAllBox(document.the_form, this)'>Puerto Rico (52)";
  put "<INPUT TYPE='checkbox' NAME='&x.53' VALUE='53' onClick='UnCkAllBox(document.the_form, this)'>Virgin Island (53)";
  put "<INPUT TYPE='checkbox' NAME='&x.54' VALUE='54' onClick='UnCkAllBox(document.the_form, this)'>Guam (54)";
  put "<INPUT TYPE='checkbox' NAME='&x.55' VALUE='55' onClick='UnCkAllBox(document.the_form, this)'>New York City (55)";
  put "<INPUT TYPE='checkbox' NAME='&x.56' VALUE='59' onClick='UnCkAllBox(document.the_form, this)'>Remainder of World (59)";
  put "<INPUT TYPE='checkbox' NAME='&x.57' VALUE='61' onClick='UnCkAllBox(document.the_form, this)'>American Samoa (61)";
  put "<INPUT TYPE='checkbox' NAME='&x.58' VALUE='62' onClick='UnCkAllBox(document.the_form, this)'>Northern Marianas (62)";
  put " <BR><INPUT TYPE='checkbox' NAME='&x' VALUE='all' CHECKED>All ";
  put ' </CENTER> ';
%mend BuildStateCkbxs;


%macro BuildAgeunitCkbxs;
  put ' <TR><TD><CENTER>Age Unit<BR>';
  put ' <INPUT TYPE="checkbox" NAME="ageunit1" VALUE="0" onClick="UnCkAllBox(document.the_form, this)">Years-less than 100 (0) ';
  put ' <INPUT TYPE="checkbox" NAME="ageunit2" VALUE="1" onClick="UnCkAllBox(document.the_form, this)">Years-100 or more (1) ';
  put ' <INPUT TYPE="checkbox" NAME="ageunit3" VALUE="2" onClick="UnCkAllBox(document.the_form, this)">Months (2) ';
  put ' <INPUT TYPE="checkbox" NAME="ageunit4" VALUE="3" onClick="UnCkAllBox(document.the_form, this)">Weeks (3) ';
  put ' <INPUT TYPE="checkbox" NAME="ageunit5" VALUE="4" onClick="UnCkAllBox(document.the_form, this)">Days (4) ';
  put ' <INPUT TYPE="checkbox" NAME="ageunit6" VALUE="5" onClick="UnCkAllBox(document.the_form, this)">Hours (5) ';
  put ' <INPUT TYPE="checkbox" NAME="ageunit7" VALUE="6" onClick="UnCkAllBox(document.the_form, this)">Minutes (6) ';
  put ' <INPUT TYPE="checkbox" NAME="ageunit9" VALUE="9" onClick="UnCkAllBox(document.the_form, this)">Not Classifiable (9) ';
  put ' <BR><INPUT TYPE="checkbox" NAME="ageunit" VALUE="all" CHECKED>All ';
  put ' </CENTER> ';
%mend BuildAgeunitCkbxs;


%macro BuildAttendCkbxs;
  put ' <TR><TD><CENTER>Attendant<BR>';
  put ' <INPUT TYPE="checkbox" NAME="attend1" VALUE="1" onClick="UnCkAllBox(document.the_form, this)">M.D. (1) ';
  put ' <INPUT TYPE="checkbox" NAME="attend2" VALUE="2" onClick="UnCkAllBox(document.the_form, this)">D.O. (2) ';
  put ' <INPUT TYPE="checkbox" NAME="attend3" VALUE="3" onClick="UnCkAllBox(document.the_form, this)">C.N.M (3) ';
  put ' <INPUT TYPE="checkbox" NAME="attend4" VALUE="4" onClick="UnCkAllBox(document.the_form, this)">Other Midwife (4) ';
  put ' <INPUT TYPE="checkbox" NAME="attend5" VALUE="5" onClick="UnCkAllBox(document.the_form, this)">Other (5) ';
  put ' <INPUT TYPE="checkbox" NAME="attend9" VALUE="9" onClick="UnCkAllBox(document.the_form, this)">Not Classifiable (9) ';
  put ' <BR><INPUT TYPE="checkbox" NAME="attend" VALUE="all" CHECKED>All ';
  put ' </CENTER> ';
%mend BuildAttendCkbxs;


%macro BuildBirthplcCkbxs;
  put ' <TR><TD><CENTER>Place of Delivery<BR>';
  put ' <INPUT TYPE="checkbox" NAME="birthplc1" VALUE="1" onClick="UnCkAllBox(document.the_form, this)">Hospital (1) ';
  put ' <INPUT TYPE="checkbox" NAME="birthplc2" VALUE="2" onClick="UnCkAllBox(document.the_form, this)">Free Birth Ctr (2) ';
  put ' <INPUT TYPE="checkbox" NAME="birthplc3" VALUE="3" onClick="UnCkAllBox(document.the_form, this)">Clinic/Drs Office (3) ';
  put ' <INPUT TYPE="checkbox" NAME="birthplc4" VALUE="4" onClick="UnCkAllBox(document.the_form, this)">Residence (4) ';
  put ' <INPUT TYPE="checkbox" NAME="birthplc5" VALUE="5" onClick="UnCkAllBox(document.the_form, this)">Other (5) ';
  put ' <INPUT TYPE="checkbox" NAME="birthplc9" VALUE="9" onClick="UnCkAllBox(document.the_form, this)">Not Classifiable (9) ';
  put ' <BR><INPUT TYPE="checkbox" NAME="birthplc" VALUE="all" CHECKED>All ';
  put ' </CENTER> ';
%mend BuildBirthplcCkbxs;


%macro BuildMoPrenatalCkbxs;
  put ' <TR><TD><CENTER>Mo Prenatal Care Beg<BR>';
  put ' <INPUT TYPE="checkbox" NAME="cbegmo1" VALUE="11" onClick="UnCkAllBox(document.the_form, this)">Month Named ';
  put ' <INPUT TYPE="checkbox" NAME="cbegmo2" VALUE="0" onClick="UnCkAllBox(document.the_form, this)">None (0) ';
  put ' <INPUT TYPE="checkbox" NAME="cbegmo3" VALUE="1" onClick="UnCkAllBox(document.the_form, this)">First Month (1) ';
  put ' <INPUT TYPE="checkbox" NAME="cbegmo4" VALUE="2" onClick="UnCkAllBox(document.the_form, this)">Second Month (2) ';
  put ' <INPUT TYPE="checkbox" NAME="cbegmo5" VALUE="3" onClick="UnCkAllBox(document.the_form, this)">Third Month (3) ';
  put ' <INPUT TYPE="checkbox" NAME="cbegmo6" VALUE="4" onClick="UnCkAllBox(document.the_form, this)">Fourth Month (4) ';
  put ' <INPUT TYPE="checkbox" NAME="cbegmo7" VALUE="5" onClick="UnCkAllBox(document.the_form, this)">Fifth Month (5) ';
  put ' <INPUT TYPE="checkbox" NAME="cbegmo8" VALUE="6" onClick="UnCkAllBox(document.the_form, this)">Sixth Month (6) ';
  put ' <INPUT TYPE="checkbox" NAME="cbegmo9" VALUE="7" onClick="UnCkAllBox(document.the_form, this)">Seventh Month (7) ';
  put ' <INPUT TYPE="checkbox" NAME="cbegmo10" VALUE="8" onClick="UnCkAllBox(document.the_form, this)">Eighth Month (8) ';
  put ' <INPUT TYPE="checkbox" NAME="cbegmo11" VALUE="9" onClick="UnCkAllBox(document.the_form, this)">Ninth Month (9) ';
  put ' <INPUT TYPE="checkbox" NAME="cbegmo12" VALUE="10" onClick="UnCkAllBox(document.the_form, this)">Not Stated (-) ';
  put ' <BR><INPUT TYPE="checkbox" NAME="cbegmo" VALUE="all" CHECKED>All ';
  put ' </CENTER> ';
%mend BuildMoPrenatalCkbxs;


%macro BuildPluralCkbxs;
  put ' <TR><TD><CENTER>Plurality<BR>';
  put ' <INPUT TYPE="checkbox" NAME="plural1" VALUE="1" onClick="UnCkAllBox(document.the_form, this)">Single (1) ';
  put ' <INPUT TYPE="checkbox" NAME="plural2" VALUE="2" onClick="UnCkAllBox(document.the_form, this)">Twin (2) ';
  put ' <INPUT TYPE="checkbox" NAME="plural3" VALUE="3" onClick="UnCkAllBox(document.the_form, this)">Triplet (3) ';
  put ' <INPUT TYPE="checkbox" NAME="plural4" VALUE="4" onClick="UnCkAllBox(document.the_form, this)">Quadruplet (4) ';
  put ' <INPUT TYPE="checkbox" NAME="plural5" VALUE="5" onClick="UnCkAllBox(document.the_form, this)">Quint and Higher (5) ';
  put ' <INPUT TYPE="checkbox" NAME="plural6" VALUE="9" onClick="UnCkAllBox(document.the_form, this)">Not Classifiable (9) ';
  put ' <BR><INPUT TYPE="checkbox" NAME="plural" VALUE="all" CHECKED>All ';
  put ' </CENTER> ';
%mend BuildPluralCkbxs;


%macro BuildApgarCkbxs;
  put ' <TR><TD><CENTER>Apgar 5 Minute<BR>';
  put ' <INPUT TYPE="checkbox" NAME="apgar1" VALUE="1" onClick="UnCkAllBox(document.the_form, this)">1 (01) ';
  put ' <INPUT TYPE="checkbox" NAME="apgar2" VALUE="2" onClick="UnCkAllBox(document.the_form, this)">2 (02) ';
  put ' <INPUT TYPE="checkbox" NAME="apgar3" VALUE="3" onClick="UnCkAllBox(document.the_form, this)">3 (03) ';
  put ' <INPUT TYPE="checkbox" NAME="apgar4" VALUE="4" onClick="UnCkAllBox(document.the_form, this)">4 (04) ';
  put ' <INPUT TYPE="checkbox" NAME="apgar5" VALUE="5" onClick="UnCkAllBox(document.the_form, this)">5 (05) ';
  put ' <INPUT TYPE="checkbox" NAME="apgar6" VALUE="9" onClick="UnCkAllBox(document.the_form, this)">Not Classifiable (9) ';
  put ' <BR><INPUT TYPE="checkbox" NAME="apgar" VALUE="all" CHECKED>All ';
  put ' </CENTER> ';
%mend BuildApgarCkbxs;


 /*   Accepts:  part of the display title and the input prefix letter (if any)
  * "Returns":  nothing.
  */
%macro BuildUseCkbxs(lbl, x);
  put " <TR><TD><CENTER>&lbl Use<BR>";
  put "<INPUT TYPE=checkbox NAME=&x.1 VALUE=1 onClick='UnCkAllBox(document.the_form, this)'>Yes (1)";
  put "<INPUT TYPE=checkbox NAME=&x.2 VALUE=2 onClick='UnCkAllBox(document.the_form, this)'>No (2)";
  put "<INPUT TYPE=checkbox NAME=&x.3 VALUE=9 onClick='UnCkAllBox(document.the_form, this)'>Not Classifiable (9)";
  put " <BR><INPUT TYPE='checkbox' NAME='&x' VALUE='all' CHECKED>All ";
  put ' </CENTER> ';
%mend BuildUseCkbxs;


 /* Build the dropdown widgets, using the above macros, in the order that
  * the user will see them. 
  */
%macro FreqCategoryItems;
  %local i;

  /* Need to build X (&var1) then Y (&var2) checkboxes for e.g. Race by Sex
   * queries.  This section contains both nat and mor variables intermixed.
   *
   * If add any items here, MUST also add its [vari name]max to the
   * freqHIDDENs below and to qry001.sas %global line must add the vari name.
   */
  %do i=1 %to 2;
    /* &&var&i comes from the SELECT widget */
    %if &&var&i eq sex %then
      %do;
        /* Must be same as input statement's variable name with a 'max' 
         * extension. 
         */
        %global sexmax;
        /* The number of checkboxes including Not Class, etc. but excluding
         * the 'All' ckbox. 
         */
        %let sexmax=3;
        %BuildSexCkbxs
      %end;
    /* Conflict, using a 'd' prefix for mort. */
    %else %if &&var&i eq month %then
      %do;
        %global monthmax;
        %let monthmax=13;
        %BuildMonthCkbxs(Birth, month);
      %end;
    %else %if &&var&i eq dmonth %then
      %do;
        %global dmonthmax;
        %let dmonthmax=13;
        %BuildMonthCkbxs(Death, dmonth);
      %end;
    /* Conflict, using a 'd' prefix for mort. */
    %else %if &&var&i eq day %then
      %do;
        %global daymax;
        %let daymax=31;
        %BuildDayCkbxs(31, Birth, day)
      %end;
    %else %if &&var&i eq dday %then
      %do;
        %global ddaymax;
        %let ddaymax=31;
        %BuildDayCkbxs(31, Death, dday)
      %end;
    %else %if &&var&i eq birthplc %then
      %do;
        %global birthplcmax;
        %let birthplcmax=6;
        %BuildBirthplcCkbxs;
      %end;
    %else %if &&var&i eq stres %then
      %do;
        %global stresmax;
        %let stresmax=58;
        %BuildStateCkbxs(Residence, stres);
      %end;
    %else %if &&var&i eq yr %then
      %do;
        %global yrmax;
        %let yrmax=1;
        put ' <TR><TD><CENTER>Year of Death:<BR>';
        /* This could be misleading since it's not really ALL, but the mainframe
         * resource constraint forces us to use only a single year on any
         * year-based two-way queries.
         * And extra misleading b/c I rename year to yr in the data step in
         * qry001.sas so it has to be yr here (and in wiz2.sas).
         */
        put "<INPUT TYPE=checkbox NAME=yr VALUE=all CHECKED>&FREQYR4";
      %end;
    %else %if &&var&i eq race %then
      %do;
        %global racemax;
        %let racemax=16;
        %BuildRaceCkbxs(,);
      %end;
    %else %if &&var&i eq birthmo %then
      %do;
        %global birthmomax;
        %let birthmomax=13;
        %BuildMonthCkbxs(Birth, birthmo);
      %end;
    %else %if &&var&i eq birthdy %then
      %do;
        %global birthdymax;
        %let birthdymax=31;
        %BuildDayCkbxs(&birthdymax, Birth, birthdy)
      %end;
    %else %if &&var&i eq typ_plac %then
      %do;
        %BuildTyplacCkbxs;
        %global typ_placmax;
        %let typ_placmax=8;
      %end;
    %else %if &&var&i eq marital %then
      %do;
        %BuildMarstatCkbxs;
        %global maritalmax;
        %let maritalmax=5;
      %end;
    %else %if &&var&i eq hispanic %then
      %do;
        %BuildHispCkbxs(,);
        %global hispanicmax;
        %let hispanicmax=7;
      %end;
    %else %if &&var&i eq educ %then
      %do;
        %BuildEducCkbxs(,);
        %global educmax;
        %let educmax=19;
      %end;
    /* mor */
    %else %if &&var&i eq ageunit %then
      %do;
        %BuildAgeunitCkbxs;
        %global ageunitmax;
        %let ageunitmax=8;
      %end;
    /* mor */
    %else %if &&var&i eq state %then
      %do;
        %BuildStateCkbxs(Occurrence, state);
        %global statemax;
        %let statemax=58;
      %end;
    %else %if &&var&i eq mothhisp %then
      %do;
        %BuildHispCkbxs(Mother, moth);
        %global mothhispmax;
        %let mothhispmax=7;
      %end;
    %else %if &&var&i eq fathhisp %then
      %do;
        %BuildHispCkbxs(Father, fath);
        %global fathhispmax;
        %let fathhispmax=7;
      %end;
    /* nat */
    %else %if &&var&i eq month and &the_type eq natmer %then
      %do;
        %BuildMonthCkbxs(Birth, month);
        %global monthmax;
        %let monthmax=13;
      %end;
    %else %if &&var&i eq attend %then
      %do;
        %BuildAttendCkbxs;
        %global attendmax;
        %let attendmax=6;
      %end;
    %else %if &&var&i eq day %then
      %do;
        %BuildDayCkbxs(31, Birth, day);
        %global daymax;
        %let daymax=31;
      %end;
    /* nat */
    %else %if &&var&i eq mothmo %then
      %do;
        %BuildMonthCkbxs(Mother Birth, mothmo);
        %global mothmomax;
        %let mothmomax=13;
      %end;
    /* nat */
    %else %if &&var&i eq mothday %then
      %do;
        %BuildDayCkbxs(31, Mother Birth, mothday);
        %global mothdaymax;
        %let mothdaymax=31;
      %end;
    %else %if &&var&i eq mothyr %then
      %do;
        put ' <TR><TD><CENTER>Mother Year of Birth:<BR>';
        put "<INPUT TYPE=checkbox NAME=mothyr VALUE=all CHECKED>All";
        %global mothyrmax;
        %let mothyrmax=1;
      %end;
    %else %if &&var&i eq mothplc %then
      %do;
        %BuildStateCkbxs(Mother Birth, mothplc);
        %global mothplcmax;
        %let mothplcmax=6;
      %end;
    %else %if &&var&i eq fathmo %then
      %do;
        %BuildMonthCkbxs(Father Birth, fathmo);
        %global fathmomax;
        %let fathmomax=13;
      %end;
    %else %if &&var&i eq fathday %then
      %do;
        %BuildDayCkbxs(31, Father Birth, fathday);
        %global fathdaymax;
        %let fathdaymax=31;
      %end;
    %else %if &&var&i eq fathyr %then
      %do;
        put ' <TR><TD><CENTER>Father Year of Birth:<BR>';
        put "<INPUT TYPE=checkbox NAME=fathyr VALUE=all CHECKED>All";
        %global fathyrmax;
        %let fathyrmax=1;
      %end;
    %else %if &&var&i eq mrace %then
      %do;
        %BuildRaceCkbxs(Mother, m);
        %global mracemax;
        %let mracemax=16;
      %end;
    %else %if &&var&i eq frace %then
      %do;
        %BuildRaceCkbxs(Father, f);
        %global fracemax;
        %let fracemax=16;
      %end;
    %else %if &&var&i eq motheduc %then
      %do;
        %BuildEducCkbxs(Mother, moth);
        %global motheducmax;
        %let motheducmax=19;
      %end;
    %else %if &&var&i eq mensemo %then
      %do;
        %BuildMonthCkbxs(Mother Menses, mensemo);
        %global mensemomax;
        %let mensemomax=13;
      %end;
    %else %if &&var&i eq mensedy %then
      %do;
        %BuildDayCkbxs(31, Mother Menses, mensedy);
        %global mensedymax;
        %let mensedymax=31;
      %end;
    %else %if &&var&i eq mensyr %then
      %do;
        put ' <TR><TD><CENTER>Mother Menses Year:<BR>';
        put "<INPUT TYPE=checkbox NAME=mensyr VALUE=all CHECKED>All";
        %global mensyrmax;
        %let mensyrmax=1;
      %end;
    %else %if &&var&i eq cbegmo %then
      %do;
        %BuildMoPrenatalCkbxs;
        %global cbegmomax;
        %let cbegmomax=12;
      %end;
    %else %if &&var&i eq nbegmo %then
      %do;
        %BuildMonthCkbxs(N Mo Prenat Care Beg, nbegmo);
        %global nbegmomax;
        %let nbegmomax=13;
      %end;
    %else %if &&var&i eq plural %then
      %do;
        %BuildPluralCkbxs
        %global pluralmax;
        %let pluralmax=5;
      %end;
    %else %if &&var&i eq apgar %then
      %do;
        %BuildApgarCkbxs
        %global apgarmax;
        %let apgarmax=5;
      %end;
    %else %if &&var&i eq tob_use %then
      %do;
        %BuildUseCkbxs(Tobacco, tob_use)
        %global tob_usemax;
        %let tob_usemax=5;
      %end;
    %else %if &&var&i eq alc_use %then
      %do;
        %BuildUseCkbxs(Alcohol, alc_use)
        %global alc_usemax;
        %let alc_usemax=5;
      %end;
  %end;
  /* If you've added an element, don't forget to add the name (e.g. dyearmax)
   * to the hiddens below and the name (e.g. dyear) to %global in qry001.sas.
   */
%mend FreqCategoryItems;


 /* One huge datastep to produce an HTML form for either Simple List or
  * Two-Way.  For Simple, just provide confirmation of the shipment number and
  * extension for each year to be worked.  For Two-Way, do the same but also
  * provide widgets to further specify the 2 variables (e.g. for Sex, show
  * Male, Female... checkboxes).
  */
data _NULL_;
  file _WEBOUT;
  put '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">';
  put '<HTML>';
  put '<HEAD>';
  put "  <TITLE>Build Query Step 4 of 4 (&the_type &the_rptstyle)</TITLE>";
  /* When the user wants specific items, de-select the All button so that 
   * he does not have to. 
   */
  put '  <SCRIPT Language="JavaScript">';
  put '    function UnCkAllBox(f, c) {';
  put '      var tmp = c.name;';
  put '      var re = /\d+/;';
  put '      var base = tmp.replace(re, "");';
  put '      for ( var i=0; i<f.length; i++ ) {';
  put '        if ( f.elements[i].name == base ) {';
  put '          f.elements[i].checked = false;';
  put '        }';
  put '      }';
  put '    }';
  put '  </SCRIPT>';

  put '  <META NAME="author" CONTENT="Robert S. Heckel Jr. (BQH0)"> ';
  put '</HEAD> ';
  put '<BODY> ';
  put '  <BR>';
  put '  <TABLE WIDTH=90% ALIGN="center" BORDER=0 CELLSPACING=0 CELLPADDING=1>';
  put '  <TR><TD BGCOLOR=#999999>';
  put '  <TABLE WIDTH=100% BORDER=0 CELLSPACING=0 CELLPADDING=0>';
  put '  <TR><TD BACKGROUND="http://mainframe.cdc.gov/sasweb/nchs/intrnet/y.gif">';
  put '  <FONT SIZE=+1 COLOR=#333333><I><B>&nbsp;';
  put "  Complete your &the_type ";
  /* Eliminate the temp placeholders. */
  put %sysfunc(compress("&yearsrequest", 'X'));
  put "  &state &the_revstatus Query:";
  put '  </I></FONT></TABLE></TABLE>';
  put '  <TABLE BORDER=1 ALIGN="center" WIDTH="90%" BGCOLOR="#FFFFFF"';
  put '         CELLSPACING=0 CELLPADDING=5> ';
  put '    <FORM ACTION="http://mainframe.cdc.gov/sasweb/cgi-bin/broker"';
  /* To debug, set this from POST to GET then edit the URL in the browser. */
  /* And thanks to IE's inability to handle long URL nat queries REQUIRE that
   * POST be used instead. 
   */
  put '          METHOD="GET" NAME="the_form"> ';
  put '      <INPUT TYPE="hidden" NAME="_DEBUG" VALUE="0"> ';
  put '      <INPUT TYPE="hidden" NAME="_SERVICE" VALUE="default"> ';
  put '      <INPUT TYPE="hidden" NAME="_PROGRAM" VALUE="nchscode.Dqry001.sas"> ';
  /* Used later to see if user wants a different shipment than this default. */
  put "      <INPUT TYPE='hidden' NAME='ship1' VALUE=&ship1>";
  put "      <INPUT TYPE='hidden' NAME='ship2' VALUE=&ship2>";
  put "      <INPUT TYPE='hidden' NAME='ship3' VALUE=&ship3>";
  put "      <INPUT TYPE='hidden' NAME='ship4' VALUE=&ship4>";
  put "      <INPUT TYPE='hidden' NAME='ship5' VALUE=&ship5>";
  /* Info gathered from the pages prior to this one goes HIDDEN here to be
   * pushed forward. 
   */
  put "      <INPUT TYPE='hidden' NAME='the_yearsrequest' VALUE='&yearsrequest'> ";
  put "      <INPUT TYPE='hidden' NAME='the_state' VALUE=&state> ";
  put "      <INPUT TYPE='hidden' NAME='the_maxnyr' VALUE='&the_maxnyr'>";
  put "      <INPUT TYPE='hidden' NAME='the_type' VALUE=&the_type> ";
  put "      <INPUT TYPE='hidden' NAME='the_rptstyle' VALUE=&the_rptstyle> ";
  put "      <INPUT TYPE='hidden' NAME='the_cmax' VALUE=&the_cmax> ";
  put "      <INPUT TYPE='hidden' NAME='the_userid' VALUE=&the_userid> ";
  put "      <INPUT TYPE='hidden' NAME='the_revstatus' VALUE=&the_revstatus> ";
  put "      <INPUT TYPE='hidden' NAME='the_revreq' VALUE=&the_revreq> ";
  put ' <TR><TD><CENTER> ';

  /* Accepts:  2 letter state, 2 digit yr, shipment number, extension 
   *           (e.g. MORMER1), open or closed string for display purposes, yr
   *           num 1-5.
   * "Return"s:  nothing.
   */
  %macro BuildShipLine(st, yr, sn, fex, num);
    /* The linebreaks are important to the HTML display.  Do not adjust. */
    put "<TR><TD><FONT FACE='courier new'>BF19.&st.X&yr<INPUT ";
    put "TYPE=text NAME=shipment&num SIZE=1 VALUE=&sn>.<INPUT ";
    put "TYPE=text NAME=ext&num SIZE=10 VALUE=&fex></FONT>";
  %mend BuildShipLine;

  /* Build Shipment Number lines of the "Complete your ___MER..." confirmation
   * (and optional override).
   */
  %macro ShipmentNums;
    put '<BR><BR><TABLE>';
    /* TODO loop */
    %if &year1 ne  %then
      %do;
        %BuildShipLine(&state, &year1, &ship1, &ext1, 1);
      %end;
    %if &year2 ne  %then
      %do;
        %BuildShipLine(&state, &year2, &ship2, &ext2, 2);
      %end;
    %if &year3 ne  %then
      %do;
        %BuildShipLine(&state, &year3, &ship3, &ext3, 3);
      %end;
    %if &year4 ne  %then
      %do;
        %BuildShipLine(&state, &year4, &ship4, &ext4, 4);
      %end;
    %if &year5 ne  %then
      %do;
        %BuildShipLine(&state, &year5, &ship5, &ext5, 5);
      %end;
    put '</TABLE>';
    put '<BR><BR>Notes:<BR>';
    put 'Shipment Number and Extension reflect the most current ';
    put 'files.  They may be edited to select a different file.<BR>';
    put '(blank Shipment Number and Extension indicate no file found)<BR><BR>';
    put 'Older files may be migrated and require extra time (or ';
    put 'timeout altogether).  This usually requires running the query ';
    put 'twice.<BR><BR>';
    put "<BR><I>Last Updated: &SYSDATE9 4:30 a.m. Eastern time</I><BR><BR>";
  %mend ShipmentNums;
  %ShipmentNums

   /*   Accepts: nothing but uses globals &the_cmax and &the_rptstyle
    * "Returns": global stmt needed later e.g.  ...c2 c3 c4... t1 t2 t3...
    *
    * Have to create placeholders on potentially empty user input widgets to
    * avoid errors.
    */
  %macro MakeGlobals;
    %local i widgets;

    %if &the_rptstyle eq list %then
      %do;
        %do i=1 %to &the_cmax;
          %let widgets = &widgets c&i t&i;
        %end;
      %end;

    /* Have to create placeholders so that next page doesn't error when some
     * are found to be empty (which is normal if the user hasn't selected all
     * checkboxes).
     */
    %global &widgets;
  %mend MakeGlobals;
  %MakeGlobals

  /*   Accepts: nothing
   * "Returns": nothing, writes HTML to send user-selected widget data to next
   * page
   */
  %macro BuildInpHids;
    %local i;
    %do i=1 %to &the_cmax;
      %if &&c&i ne  %then
        %do;
          /* User has checked this checkbox. */
          put "<INPUT TYPE='hidden' NAME='the_c&i' VALUE=&&c&i>";
          put "<INPUT TYPE='hidden' NAME='the_op&i' VALUE=&&op&i>";
          put "<INPUT TYPE='hidden' NAME='the_t&i' VALUE=&&t&i>";
        %end;
    %end;
  %mend BuildInpHids;
  %BuildInpHids

  %macro ExcelBox;
    %if &the_rptstyle eq list %then
      %do;
        put '<BR><INPUT TYPE="checkbox" NAME="wantexcel">Output to MS Excel<BR>';
        put '<BR><INPUT NAME="the_submit" TYPE="submit" VALUE="List Records"> ';
      %end;
  %mend ExcelBox;
  %ExcelBox
  put '    </FORM> ';
  put '  </TABLE> ';
  put '  <BR><BR> ';
  put '  <BR><BR> ';
  %include "&STDFOOTR";
  put '</BODY> ';
  put '</HTML> ';
run;


%macro Debugging;
  ods html body=_WEBOUT style=minimal rs=none;
    proc print data=L.latebf19 (obs= 50); run;
  ods html close;
%mend Debugging;
 /* DEBUG toggle */
***%Debugging;
