options NOsource NOsource2;
 /*---------------------------------------------------------------------
  *     Name: BQH0.SAS.INTRNET.PDS(QRY001) nchscode.qry001.sas
  *
  *  Summary: SAS Intrnet query which produces a report based on the 
  *           requested parameters gathered by the preceding HTML forms.
  *
  *           At this point, all data has been collected from the user.
  *           This is the endpoint.
  *
  *  Created: Tue 04 Feb 2003 13:37:42 (Bob Heckel)
  *
  *      RCS:
  *  $Log: qry001.sas,v $
  *  Revision 1.21  2003/12/19 15:50:11  bqh0
  *  Added natality non-reviser and reviser query capability.
  *  Added output to MS Excel option to avoid IE URL length limitation.
  *  Improved interface.
  *
  *  Revision 1.20  2003/10/27 21:25:44  bqh0
  *  Added Racebox String and Hispanic String to the reviser
  *  choices per Adrienne Rouse.
  *
  *  Revision 1.19  2003/10/15 14:50:20  bqh0
  *  Add 'country of birth' widget to reviser state query choices.
  *
  *  Revision 1.18  2003/09/24 14:39:03  bqh0
  *  Added "No Records Found" with query display for freq style queries.
  *
  *  Revision 1.17  2003/09/23 21:24:14  bqh0
  *  Changed representation of century, per request.  Improved No Records Found
  *  error message.
  *
  *  Revision 1.16  2003/09/19 19:57:08  bqh0
  *  Fix two-way display of >1 year in output.  Add century to revisers.
  *  Fix educ edit dropdown example.  Cleanup age fields on non-rev and revisers.
  *  Changes based on Brenda's review.
  *
  *  Revision 1.15  2003/08/27 19:05:34  bqh0
  *  Allow partial reviser Multirace info to display if user queries
  *  a Multirace state on race.  Also allow provide checkboxes for
  *  users who know the state has adopted Multirace.
  *
  *  Revision 1.14  2003/08/26 18:17:06  bqh0
  *  Allow partial reviser FIPS info to display if user queries a FIPS state.
  *  Also allow user to enter FIPS strings where numerics are normally used.
  *
  *  Revision 1.13  2003/08/18 21:06:39  bqh0
  *  Added variables to two-way, fixed bugs in two-way, improved interface,
  *  added multirace checkboxes to bottom of reviser page.
  *
  *  Revision 1.12  2003/08/15 19:25:09  bqh0
  *  Fixed DC DE transposition error.  Added County of Occ.
  *
  *  Revision 1.11  2003/08/08 21:09:54  bqh0
  *  Created separate pages for reviser states.
  *
  *  Revision 1.10  2003/07/16 19:53:53  bqh0
  *  Allow querying of full reviser states (where possible since the new
  *  merged file has to fit into the old merge file's web interface).
  *
  *  Revision 1.9  2003/07/15 20:12:43  bqh0
  *  Make FIPS detection rule more strict to handle bad input merge files.
  *
  *  Revision 1.8  2003/07/15 16:10:41  bqh0
  *  Removed proc format.  Relying on a permanent format library now.
  *
  *  Revision 1.7  2003/07/14 20:02:08  bqh0
  *  Detect and convert FIPS reviser's birth, occurrence and residence states.
  *  Also improve title warnings.
  *
  *  Revision 1.6  2003/07/11 20:24:35  bqh0
  *  Detect FIPS & multirace states and warn user, clean up and
  *  standardize titles.
  *
  *  Revision 1.5  2003/07/11 13:41:21  bqh0
  *  Added Mexico to proc format stmt.
  *
  *  Revision 1.4  2003/07/10 19:11:19  bqh0
  *  Change 'file not found' error message to user-friendly output.
  *
  *  Revision 1.3  2003/07/09 19:34:32  bqh0
  *  Improve error trap on requested files that don't exist.  
  *  Provide query details in the output.
  *
  *  Revision 1.2  2003/07/09 14:13:42  bqh0
  *  Initial mods for dev version.
  *
  *---------------------------------------------------------------------
  */

 /*<<<<<<<<<<{ Start Initialization >>>>>>>>>>*/
options NOsource NOsource2 mprint mlogic symbolgen NOfullstimer 
        NOerrorabend NOs99nomig fmtsearch=(LFMT)
        ;

 /* For non-MVDS requests we'll use this to build a dataset, for MVDS
  * requests, we'll use it to subset the MVDS.
  */
libname TMPINTRN "&the_userid..TMPINTRN" UNIT=SYSDA DISP=(NEW,DELETE)        
        SPACE=(TRK,(4000,500))
        ; 
libname LFMT "DWJ2.%substr(&the_type,1,3)03.FORMAT.LIBRARY" DISP=SHR WAIT=30;

proc template;
  define style styles.bob;
    parent=styles.minimal;
    /* Insert JavaScript into SAS' function startup() */
    replace StartupFunction / tagattr="window.status='NCHS Confidential Data'";
  end;
run;

 /*<<<<<<<<<<} End Initialization >>>>>>>>>>*/


 /*<<<<<<<<<<{ Start Globals >>>>>>>>>>*/
 /* Parameters provided by the previous webpages: */
%global yearsrequest the_state the_type the_rptstyle 
        shipment1 shipment2 shipment3 shipment4 shipment5 
        ext1 ext2 ext3 ext4 ext5   
        the_cmax
        ;

%global OVERFLOWOBS FIPSDETECT MULTIDETECT FULLREVDETECT FULLREVNOTE STUMBLEMULT;
 /* Avoid overloading user's browser on a 'Simple List' query. */
%let OVERFLOWOBS=100;
 /* If needed, for detecting presence of FIPS, multirace or full revisers in a
  * non-full-reviser run.
  */
%let FIPSDETECT=0;
%let MULTIDETECT=0;
%let FULLREVDETECT=0;
%let FULLREVNOTE=0;

 /*   Accepts: nothing but uses globals
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
        %let widgets = &widgets the_c&i the_t&i;
      %end;
    %end;

  %global &widgets;
%mend MakeGlobals;
%MakeGlobals

 /* Other globals are declared below at the point of creation, inside
  * macros. 
  */
 /*<<<<<<<<<<} End Globals >>>>>>>>>>*/



 /*<<<<<<<<<<{ Start Utilities >>>>>>>>>>*/
 /*   Accepts: nothing but uses automatic variable SYSCC
  * "Returns": nothing but modifies automatic variable SYSCC
  */
%macro NullifyErr;
  %if &SYSCC ne 0 %then 
    %do;
      %put debug: the value of SYSCC was &SYSCC;
      /* Turn off automatic error msg (for security). */
      %let SYSCC = 0;
    %end;
%mend NullifyErr;


 /*   Accepts: the IF statement built by the user's selections and a global
  * "Returns": nothing, just spews a warning to the unlucky user
  */
%macro NoRecordsRet(builtif);
  %if &numobs eq 0 %then
    %do;
      data _NULL_;
        file _WEBOUT;
        put "<BR>Sorry, no matching records were found for this query:<BR><BR>";
        put &builtif;
        put "<BR><BR>Please email LMITHELP ";
        put "if the criteria is valid and you are certain that ";
        put "data should have been returned.";
        put "<BR><BR>&SYSDATE &SYSTIME";
      run;
    %end;
%mend NoRecordsRet;


 /*   Accepts: the user-built filename
  * "Returns": nothing, just spews a warning to user
  */
%macro NoSuchFile(f);
  /* Ignore the All States pseudo merged files. */
  %if &the_state ne XX %then
    %do;
      data _NULL_;
        file _WEBOUT;
        put "Sorry, file &f does not exist on the mainframe.";
        put "&SYSDATE &SYSTIME";
      run;
    %end;
%mend NoSuchFile;

 /*   Accepts: a string (e.g. 01-15 or A-D) and the delimiter char to use on 
  *            the parsed string
  * "Returns": &expand, the delimited individual elements of the requested
  *            char or num range. 
  */
%macro GenerateRange(rng, delim);
  %global expand;
  %local i j lo hi width pad isnumlo isnumhi;

  %let lo=%upcase(%qscan(&rng, 1, '-'));
  %let hi=%upcase(%qscan(&rng, 2, '-'));
  /* For now, have to assume user entered proper representation, e.g. 02 for
   * day of death. 
   */
  %let width=%length(&lo);

  %let isnumlo = %verify(&lo, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
  %let isnumhi = %verify(&hi, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');

  %if &isnumlo ne &isnumhi %then
    %do;
      %put !!! ERROR: bad range: LO &isnumlo  HI &isnumhi;
      %sysfunc(this is an intentional syntax error to force an abort);
    %end;

  /* Convert chars to their ASCII representation in order to loop. */
  %if &isnumlo eq 0 %then
    %do;
      %let lo=%sysfunc(rank(&lo));
      %let hi=%sysfunc(rank(&hi));
    %end;

  %do i=&lo %to &hi;
    /* First iteration... */
    %if &i eq &lo %then
      /* We're working with ASCII values which have to convert back to 
       * chars. 
       */
      %if &isnumlo eq 0 %then
        %let expand = %sysfunc(byte(&i));
      /* We're working with simple number ranges. */
      %else
        %do;
          %let pad=%eval(&width-%length(&i));
          /* Left zero padding required. */
          %if &pad ne 0 %then
            %if &pad eq 1 %then
              %let expand = 0&i;
            %if &pad eq 2 %then
              %let expand = 00&i;
            %if &pad eq 3 %then
              %let expand = 000&i;
            %if &pad eq 4 %then
              %let expand = 0000&i;
            %if &pad eq 5 %then
              %let expand = 00000&i;
          %else
            %let expand = &lo;
        %end;
    /* ...subsequent iterations */
    %else
      %if &isnumlo eq 0 %then
        %do;
          /* Convert back to char. */
          %let j = %sysfunc(byte(&i));
          %if (&width eq 2) and (&i lt 10) %then
            %let expand = 0&expand.&delim.&j;
          %else
            %let expand = &expand.&delim.&j;
        %end;
      /* Working with simple number ranges. */
      %else
        %do;
          %let pad=%eval(&width-%length(&i));
          /* Handle zero padding between the user's endpoints. */
          %if &pad ne 0 %then
            %do;
              %if &pad eq 1 %then
                %let expand = &expand.&delim.0&i;
              %else %if &pad eq 2 %then
                %let expand = &expand.&delim.00&i;
              %else %if &pad eq 3 %then
                %let expand = &expand.&delim.000&i;
              %else %if &pad eq 4 %then
                %let expand = &expand.&delim.0000&i;
              %else %if &pad eq 5 %then
                %let expand = &expand.&delim.00000&i;
            %end;
          %else
            %let expand = &expand.&delim.&i;
        %end;
  %end;
%mend GenerateRange;


 /*   Accepts: a string, a delimiter
  * "Returns": &numchunks, a count of delimiters, and macrovariable strings
  *            &chunk1-N holding each delimited piece
  */
%macro Splitter(s, d);
  %global numchunks;
  %local i sl snodelm snodelml numdelims;

  %let sl=%length(&s);

  %let snodelm=%sysfunc(compress(&s, %str(&d)));
  %let snodelml=%length(&snodelm);

  %let numdelims=%eval(&sl-&snodelml);
  %let numchunks=%eval(&numdelims+1);

  %do i=1 %to &numchunks;
    %global chunk&i;
    %let chunk&i = %scan(%str(&s), &i, %str(&d)); 
  %end;
%mend Splitter;


 /*   Accepts: a string, the input delimiter to split on, the output 
  *            delimiter to be inserted
  * "Returns": &parsed, a delimited string
  *
  *            If &outdelim is "" it automatically comma-delimits the 
  *            returned parsed string.  Used by at least the criteria range 
  *            dropdown
  */
%macro Delimit(str, indelim, outdelim);
  %global parsed;
  %local i j isalpha;

  /* Provides numchunks and chunk1-N */
  %Splitter(&str, &indelim)

  %do i=1 %to &numchunks;
    %if &outdelim eq %str("") %then
      /* Avoid leading comma. */
      %if &i eq 1 %then
        %let parsed = "&&chunk&i";
      %else
        %let parsed = &parsed,"&&chunk&i";
    %else
      %if &i eq 1 %then
        %let parsed = &&chunk&j;
      %else
        %let parsed = &parsed,&&chunk&j;
  %end;
%mend Delimit;


 /*   Accepts:  the checked values (e.g. race1=1, race3=3...)
  * "Returns":  a macrovariable (e.g. &racerequested) holding a pipe-delimited
  *             string of the checkbox VALUES.  Assumes the checkbox NAMEs are
  *             numbered sequentially e.g. race1 to raceN and a macrovariable
  *             indicating the highest N in the series (e.g. racemax) exists.
  */
%macro VarRequested(t);
  %global &t.request;

  %let &t.request=;

  %do i=1 %to &&the_&t.max;
    /* Protect against undefined macrovars. */
    %global &t.&i;
    /* Create pipe delimited string by concatenation. */
    %let &&t.request=&&&t.request|&&&t.&i;
  %end;
%mend VarRequested;


 /*   Accepts:  pipe-delimited string:  
  *             e.g. '|||03|04|05||||||||||||||||||||||||||'
  * "Returns":  &spaces_added which holds a pipe-delimited list of values 
  *             of the checkbox(es) the user checked but this time
  *             representing missing checks as a space instead of consequtive
  *             pipes.  Important when parsing pipes in SAS.
  *
  *             Only used by two-way freq-style queries.
  */
%macro CreateCheckboxStr(pipereq);
  %local pipereq;
   /* Force spaces on consecutive pipes since %scan can't handle
    * consecutive delimiters. 
    */
  data _NULL_;
    %global spaces_added;
    /* Nested tranwrd() required to handle multiple runs of empty pipes. */
    like_dsd = tranwrd(tranwrd("&pipereq",'||','| |'), '||','| |');
    call symput('spaces_added', like_dsd);
  run;
%mend CreateCheckboxStr;


 /*   Accepts: the temp SAS dataset built by this application
  * "Returns": the count of observations
  */
%macro CountObs(the_ds);
  %global numobs;

  %let dsid=%sysfunc(open(&the_ds));
  %let numobs=%sysfunc(attrn(&dsid, nobs));
  %let rc=%sysfunc(close(&dsid));
  %if &rc ne 0 %then
    %put ERROR: &rc in CountObs macro;
%mend CountObs;


 /*   Accepts: global &wantexcel
  * "Returns": nothing, just changes CGI headers
  */
%macro OutputToExcel;
  /* If a checkbox is unchecked it does not appear as a macrovar on the next
   * page so we have to set a global to avoid potential resolution errors.
   */
  %global wantexcel;

  %if (&wantexcel eq on) and (&the_rptstyle eq list) %then
    %do;
       /* IE only. */
       %let RV=%sysfunc(appsrv_header(Content-type, application/vnd.ms-excel));
       %let RV=%sysfunc(appsrv_header(Content-disposition, 
                        %str(attachment; filename=SAS_IntrNet_Output.xls)));
    %end;
%mend OutputToExcel;
%OutputToExcel


%macro Diagnostics;
  data _NULL_;
    ***if _N_ = 1 then prx = prxparse("/bob+|heck/i");
    filename _ALL_ list;
    %put debug: ifstmt: %str(&ifstmt);
    put "debug: SYSCC (operating environment condition code): &SYSCC";
    put 'debug: SYSCC of 4 is a warning';
    put "debug: FIPSDETECT: &FIPSDETECT";
    put "debug: MULTIDETECT: &MULTIDETECT";
    put "debug: FULLREVDETECT: &FULLREVDETECT";
    put "debug: FULLREVNOTE: &FULLREVNOTE";
  run;
  /***   proc print data=TMPINTRN.statemergedC (obs= 8); run; ***/
%mend Diagnostics;

 /*<<<<<<<<<<} End Utilities >>>>>>>>>>*/



 /*   Accepts: nothing but uses globals
  * "Returns": global indicating if user wants a merge file shipment number
  *            other than the most recent
  */
%macro UseMVDSorMergeFile;
  %global USEMVDS;
  %local i b year1 year2 year3 year4 year5 evt3;

  /* Parse the 2 digit year(s) from e.g. "X X X X 04" */
  %do i=1 %to &the_maxnyr;
    %let year&i=%scan(&the_yearsrequest, &i, ' ');
  %end;

  /******* Set coded bit *******/
  %let b=0;

  %if &year1 ne X %then
    %let b=%eval(&b+1);

  %if &year2 ne X %then
    %let b=%eval(&b+2);

  %if &year3 ne X %then
    %let b=%eval(&b+4);

  %if &year4 ne X %then
    %let b=%eval(&b+8);

  %if &year5 ne X %then
    %let b=%eval(&b+16);
  /****************************/

  %let evt3=%substr(&the_type, 1, 3);

  /* If user has edited the inputbox's shipment number on previous page or
   * user wants All State and we're working on 2003 or 2004 data.  
   * Must be changed yearly.
   */
  %if (&b eq 8) %then
    %do;
      %let USEMVDS=1;
      libname L "DWJ2.&evt3.20&year4..MVDS.LIBRARY.NEW" DISP=SHR WAIT=30;
    %end;
  %else %if (&b eq 16) %then
    %do;
      %let USEMVDS=1;
      libname L "DWJ2.&evt3.20&year5..MVDS.LIBRARY.NEW" DISP=SHR WAIT=30;
    %end;
  %else %if (&b ge 24) %then
    %do;
      /* >24 would be a mixed year request (file and mvds ds) in '04 */
      %let USEMVDS=1;
      libname L ("DWJ2.&evt3.20&year4..MVDS.LIBRARY.NEW" 
                 "DWJ2.&evt3.20&year5..MVDS.LIBRARY.NEW") DISP=SHR WAIT=30;
    %end;
  %else
    %let USEMVDS=0;
%mend UseMVDSorMergeFile;
%UseMVDSorMergeFile;


 /*   Accepts: nothing but uses globals
  * "Returns": filename statements and BF19 file names
  *
  * Build filename statements for each year, then create a dataset based 
  * on the year checkbox(es) checked by the user. 
  *
  * Called only if MVDS is not available for this year!
  */
%macro BuildMergeFilenames;
  %global mergefs1 mergefs2 mergefs3 mergefs4 mergefs5;
  %local fnprefix i yr1 yr2 yr3 yr4 yr5;

  /* Default merge file mainframe directory prefix. */
  %let fnprefix=BF19;

  %do i=1 %to &the_maxnyr;
    %let yr&i=%scan(&the_yearsrequest, &i, ' ');
    /* X is a flag for 'year not requested by user' */
    %if &&yr&i ne X %then
      %do;
        /* E.g. BF19.AKX0405.NATMER */
        %let mergefs&i=&fnprefix..&the_state.X&&yr&i.&&ship&i...&&ext&i;
        %if not %sysfunc(fileexist(&&mergefs&i)) %then
          %do;
            %NoSuchFile(&&mergefs&i);
          %end;
        filename IN&i "&&mergefs&i" DISP=SHR WAIT=100;
      %end;
  %end;
%mend BuildMergeFilenames;


 /*   Accepts: a numeric code to determine year (e.g. 1 is 2000 in '04)
  * "Returns": nothing
  *
  * Called once for each year requested, building a temp dataset each time.
  * For non-MVDS year queries only!
  */
%macro BuildDataset(yrnum);
  data TMPINTRN.statemerged&yrnum;
    infile IN&yrnum MISSOVER;

    %if &the_type eq NATMER %then 
      %do;
        /* Variable names must be same as FORM VALUE= names. */
        %if &the_revreq ne 1 %then
          %do;
            /* '89 Revision (from NAT03NEW): */
            input shipno $ 1-2 certno $3-8
                  month $ 9-10  day $ 11-12 year $ 224-227
                  sex $ 15 state $ 16-17 county $18-20
                  birthplc $ 21 attend $ 22 mothmo $ 23-24 mothday $ 25-26
                  mothyr $ 228-231 mothplc $ 29-30 stres $ 31-32
                  cntyres $ 33-35
                  fathmo $ 36-37  fathday $ 38-39 fathyr $ 232-235 mothhisp $ 42
                  fathhisp $ 43 mrace $ 44 frace $ 45
                  motheduc $ 46-47 fatheduc $ 48-49 nowlive $ 50-51
                  nowdead $ 52-53 othterm $ 54-55 lbirthmo $ 56-57
                  lbirthyr $ 58-59 marstat $ 60 mensemo $ 61-62
                  mensedy $ 63-64 mensyr $ 236-239 cbegmo $ 66
                  nbegmo $ 67-68 totvists $ 69-70 wgt_unit $ 71-75
                  gest_wks $ 76-77 plural $ 78 apgar1 $ 79-80 apgar5 $ 81-82
                  no_risk  $ 83 anemia  $ 84 cardiac  $ 85
                  lung  $ 86 diabetes  $ 87 herpes  $ 88 hydram  $ 89
                  hemoglob  $ 90 hyperten  $ 91 pregasc  $ 92 eclamps  $ 93
                  cervix  $ 94 infgram  $ 95 infpret  $ 96 renal  $ 97
                  rhsensit $ 98 uterine $ 99 oth_risk $ 100
                  tob_day $ 117-119 alc_day $ 120-122 wgt_gain $ 123-124
                  no_obst $ 125 amnio $ 126 elec_fet $ 127 ind_lab $ 128
                  stim_lab $ 129 toco $ 130 ultra $ 131 oth_obs $ 132
                  no_compl $ 139 febril $ 140 meconium $ 141 membrane $ 142
                  abruptio $ 143 previa $ 144 bleed $ 145 seiz $ 146
                  prec_lab $ 147 prol_lab $ 148 dysfunc $ 149
                  breech $ 150 cephal $ 151 cord $ 152 anesthe $ 153
                  fetaldis $ 154 oth_comp $ 155 no_deliv $ 171
                  vagina $ 172 afterc $ 173 primc $ 174 repeatc $ 175
                  forceps $ 176 vacuum $ 177 no_abnor $ 183 anemia2 $ 184
                  injury $ 185 alco_syn $ 186 mem_dis $ 187
                  meconiu2 $ 188 lt30min $ 189
                  gt30min $ 190 ab_seiz $ 191 othabnor $ 192
                  no_cong $ 201 anencep $ 202 mening $ 203 hydroc $ 204
                  microcec $ 205 cennerv $ 206 heart $ 207 resp $ 208
                  stenosis $ 209 atresia $ 210 gastros $ 211 oth_gas $ 212
                  malgenit $ 213 agenes $ 214 oth_urog $ 215 cleft $ 216
                  polydac $ 217 club $ 218 hernia $ 219 oth_musc $ 220
                  downs $ 221 othchrom $ 222 oth_cong $ 223
                  receipt_mo $ 241 receipt_dy $ 242-243 receipt_yr $ 244
                  mothage $ 245-246 fathage $ 247-248
                  @256 statocc $2. @258 cntyocc $3. @261 mctrybth $2.
                  @263 mstatbth $2. @265 mctryres $2. @267 mstatres $2.
                  @269 mcntyres $3. @272 mplacres $5. @277 mrace_box1 $1.
                  @278 mrace_box2 $1. @279 mrace_box3 $1. @280 mrace_box4 $1.
                  @281 mrace_box5 $1. @281 mrace_box6 $1. @282 mrace_box7 $1.
                  @283 mrace_box8 $1. @284 mrace_box9 $1. @285 mrace_box10 $1.
                  @286 mrace_box11 $1. @287 mrace_box12 $1. @288 mrace_box12 $1.
                  @289 mrace_box13 $1. @290 mrace_box14 $1. @291 mrace_box15 $1.
                  @292 mrace_lit1 $30. @322 mrace_lit2 $30.
                  @352 mrace_lit3 $30. @382 mrace_lit4 $30.
                  @412 mrace_lit5 $30. @442 mrace_lit6 $30.
                  @472 mrace_lit7 $30. @502 mrace_lit8 $30.
                  @532 frace_box2 $1. @533 frace_box3 $1. @534 frace_box4 $1.
                  @535 frace_box5 $1. @536 frace_box6 $1. @537 frace_box7 $1.
                  @538 frace_box8 $1. @539 frace_box9 $1. @540 frace_box10 $1.
                  @541 frace_box11 $1. @542 frace_box12 $1. @543 frace_box12 $1.
                  @544 frace_box13 $1. @545 frace_box14 $1. @546 frace_box15 $1.
                  @547 frace_lit1 $30. @577 frace_lit2 $30.
                  @607 frace_lit3 $30. @637 frace_lit4 $30.
                  @667 frace_lit5 $30. @697 frace_lit6 $30.
                  @727 frace_lit7 $30. @757 frace_lit8 $30.
                  mhispmex $ 787 mhisppr $ 788 mhispcub $ 789
                  mhispoth $ 790 mhisp_lit1 $ 791-810
                  fhispmex $ 811 fhisppr $ 812 fhispcub $ 813
                  fhispoth $ 814 fhisp_lit1 $ 815-833
                  /* NCHS-appended data on full reviser layout used as flag,
                   * not for data.
                   */
                  @912 xfullblock $CHAR88.
                  ;
          %end; /* natmer old style */
        %else
          %do;
            /* Nat 2003+ Full Revision (from NATNEW03):*/
            input idob_yr $ 1-4 bstate $ 5-6 fileno $ 7-12 void $ 13
                  auxno $ 14-25 tb $ 26-29 isex $ 30 idob_mo $ 31-32
                  idob_dy $ 33-34 cntyo $ 35-37 bplace $ 38
                  fnpi $ 39-50 sfn $ 51-54 mdob_yr $ 55-58 mdob_mo $ 59-60
                  mdob_dy $ 61-62 mage_bypass $ 63 bplacec_st_ter $ 64-65
                  bplacec_cnt $ 66-67 cityc $ 68-72
                  countyc $ 73-75 statec $ 76-77 countryc $ 78-79 limits $ 80
                  fdob_yr $ 81-84 fdob_mo $ 85-86 fdob_dy $ 87-88
                  fage_bypass $ 89 mare $ 90 marn $ 91 ackn $ 92
                  meduc $ 93 meduc_bypass $ 94 methnic1 $ 95
                  hckboxes $ 95-98 rckboxes $119-133 fhckbxes $ 424-427
                  frckbxes $ 448-462
                  methnic2 $ 96 methnic3 $ 97 methnic4 $ 98 methnic5 $ 99-118
                  mrace1 $ 119  mrace2 $ 120 mrace3 $ 121 mrace4 $ 122
                  mrace5 $ 123 mrace6 $ 124 mrace7 $ 125 mrace8 $ 126
                  mrace9 $ 127 mrace10 $ 128 mrace11 $ 129 mrace12 $ 130
                  mrace13 $ 131 mrace14 $ 132 mrace15 $ 133
                  mrace16 $ 134-163 mrace17 $ 164-193 mrace18 $ 194-223
                  mrace19 $ 224-253 mrace20 $ 254-283 mrace21 $ 284-313
                  mrace22 $ 314-343 mrace23 $ 344-373
                  mrace1e $ 374-376 mrace2e $ 377-379 mrace3e $ 380-382
                  mrace4e $ 383-385 mrace5e $ 386-388 mrace6e $ 389-391
                  mrace7e $ 392-394 mrace8e $ 395-397
                  mrace16c $ 398-400 mrace17c $ 401-403 mrace18c $ 404-406
                  mrace19c $ 407-409 mrace20c $ 410-412 mrace21c $ 413-415
                  mrace22c $ 416-418 mrace23c $ 419-421
                  feduc $ 422 feduc_bypass $ 423
                  fethnic1 $ 424 fethnic2 $ 425 fethnic3 $ 426 fethnic4 $ 427
                  fethnic5 $ 428-447
                  frace1 $ 448  frace2 $ 449 frace3 $ 450 frace4 $ 451
                  frace5 $ 452 frace6 $ 453 frace7 $ 454 frace8 $ 455
                  frace9 $ 456 frace10 $ 457 frace11 $ 458 frace12 $ 459
                  frace13 $ 460 frace14 $ 461 frace15 $ 462
                  frace16 $ 463-492 frace17 $ 493-522 frace18 $ 523-552
                  frace19 $ 553-582 frace20 $ 583-612 frace21 $ 613-642
                  frace22 $ 643-672 frace23 $ 673-702
                  frace1e $ 703-705 frace2e $ 706-708 frace3e $ 709-711
                  frace4e $ 712-714 frace5e $ 715-717 frace6e $ 718-720
                  frace7e $ 721-723 frace8e $ 724-726
                  frace16c  $ 727-729 frace17c $ 730-732 frace18c $ 733-735
                  frace19c  $ 736-738 frace20c $ 739-741 frace21c $ 742-744
                  frace22c  $ 745-747 frace23c $ 748-750
                  attend $ 751 tran $ 752 dofp_mo $ 753-754
                  dofp_dy $ 755-756 dofp_yr $ 757-760
                  dolp_mo $ 761-762 dolp_dy $ 763-764 dolp_yr $ 765-768
                  nprev $ 769-770 nprev_bypass $ 771 hft $ 772 hin $ 773-774
                  hgt_bypass $ 775 pwgt $ 776-778 pwgt_bypass $ 779
                  dwgt $ 780-782 dwgt_bypass $ 783 wic $ 784
                  plbl $ 785-786 plbd $ 787-788 popo $ 789-790 mllb $ 791-792
                  yllb $ 793-796 mopo $ 797-798 yopo $ 799-802
                  cigpn $ 803-804 cigfn $ 805-806 cigsn $ 807-808 cigln $ 809-810
                  pay $ 811 dlmp_yr $ 812-815 dlmp_mo $ 816-817 dlmp_dy $ 818-819
                  pdiab $ 820 gdiab $ 821 phype $ 822 ghype $ 823 ppb $ 824
                  ppo $ 825 vb $ 826 inft $ 827 pces $ 828 npces $ 829-830
                  npces_bypass $ 831 gon $ 832 syph $ 833 hsv $ 834 cham $ 835
                  hepb $ 836 hepc $ 837 cerv $ 838 toc $ 839 ecvs $ 840
                  ecvf $ 841 prom $ 842 pric $ 843 prol $ 844 indl $ 845
                  augl $ 846 nvpr $ 847 ster $ 848 antb $ 849 chor $ 850
                  mecs $ 851 fint $ 852 esan $ 853 attf $ 854 attv $ 855
                  pres $ 856 rout $ 857 tlab $ 858
                  mtr  $ 859 plac $ 860 rut $ 861 uhys $ 862
                  aint $ 863 uopr $ 864 bwg $ 865-868 bw_bypass $ 869
                  owgest $ 870-871 owgest_bypass $ 872 apgar5 $ 873-874
                  apgar10 $ 875-876 plur $ 877-878 sord $ 879-880
                  liveb $ 881-882 match $ 883-888 plur_bypass $ 889
                  aven1 $ 890 aven6 $ 891 nicu $ 892 surf $ 893
                  anti $ 894 seiz $ 895 binj $ 896 anen $ 897
                  mnsb $ 898 cchd $ 899 cdh $ 900 omph $ 901
                  gast $ 902 limb $ 903 cl $ 904 cp $ 905
                  dowt $ 906 cdit $ 907 hypo $ 908 itran $ 909
                  iliv $ 910 bfed $ 911 r_yr $ 912-915
                  r_mo $ 916-917 r_dy $ 918-919 mager $ 920-921
                  fager $ 922-923
                  ;
          %end;  /* nat full reviser */
      %end;  /* natmer either */
    %else %if &the_type eq MORMER %then
      %do;
        %if &the_revreq eq 0 %then
          %do;
            /* Mort '89 Revision (from MOR03NEW): */
            input receipt_mo $ 1 receipt_dy $ 2-3 receipt_yr $ 4
                  certno $ 5-10 lname $ 11-30 fname $ 31-45 middle $ 46
                  alias $ 47 sex $ 48 month $ 49-50 day $ 51-52 year $ 135-138
                  age $ 64-66 birthmo $ 67-68 birthdy $ 69-70 birthyr $ 139-142
                  birthplc $ 74-75 typ_plac $ 76 state $ 77-78 county $ 79-81
                  marital $ 82 industry $ 83-85 occup $ 86-88
                  stres $ 89-90 cntyres $ 91-93
                  hispanic $ 94 race $ 95 educ $ 96-97 fathname $ 98-116
                  injury $ 117 autopsy $ 122 lcertno $ 123-128 byear $ 129-132
                  stbirth $ 133-134
                  cntrybth $ 143-144 statbthp $ 145-146 statocc $ 147-148
                  cntyocc $ 149-151 ctryres $ 152-153 statres $ 154-155
                  cntyres $ 156-158 placres $159-163 statlink $ 164
                  @166 race_box2 $1. @167 race_box3 $1. @168 race_box4 $1.
                  @169 race_box5 $1. @170 race_box6 $1. @171 race_box7 $1.
                  @172 race_box8 $1. @173 race_box9 $1. @174 race_box10 $1.
                  @175 race_box11 $1. @176 race_box12 $1. @177 race_box12 $1.
                  @178 race_box13 $1. @179 race_box14 $1. @180 race_box15 $1.
                  @181 race_lit1 $30. @211 race_lit2 $30.
                  @241 race_lit3 $30. @271 race_lit4 $30.
                  @301 race_lit5 $30. @331 race_lit6 $30.
                  @361 race_lit7 $30. @391 race_lit8 $30.
                  /* NCHS-appended data on full reviser layout used as flag,
                   * not for data. 
                   */
                  @673 xfullblock $CHAR28.
                  ;
                  /* If make changes here, must also change the %RerunInput
                   * input stmt.
                   */
          %end; /* mormer old style */
        %else
          %do;
            /* Mort 2003+ Full Revision (from MORNEW03): */
            input dod_yr $ 1-4 dstate $ 5-6 fileno $ 7-12
                  void $ 13 auxno $ 14-25 mfiled $ 26 gname $ 27-76
                  mname $ 77 lname $ 78-127 suff $ 128-137
                  alias $ 138 flname $ 139-188 sex $ 189
                  sex_bypass $ 190 ssn $ 191-199 agetype $ 200
                  age $ 201-203 age_bypass $ 204 dob_yr $ 205-208
                  dob_mo $ 209-210 dob_dy $ 211-212
                  bplace_cnt $ 213-214 bplace_st $ 215-216
                  cityc $ 217-221 countyc $ 222-224 statec $ 225-226
                  countryc $ 227-228 limits $ 229 marital $ 230
                  marital_bypass $ 231 dplace $ 232 cod $ 233-235
                  disp $ 236 dod_mo $ 237-238 dod_dy $ 239-240
                  tod $ 241-244 deduc $ 245
                  deduc_bypass $ 246 dethnic1 $ 247 dethnic2 $ 248
                  hckboxes $ 247-250 rckboxes $ 271-285
                  dethnic3 $ 249 dethnic4 $ 250 dethnic5 $ 251-270
                  race1 $ 271 race2 $ 272 race3 $ 273
                  race4 $ 274 race5 $ 275 race6 $ 276 race7 $ 277
                  race8 $ 278 race9 $ 279 race10 $ 280 race11 $ 281
                  race12 $ 282 race13 $ 283 race14 $ 284
                  race15 $ 285 race16 $ 286-315 race17 $ 316-345
                  race18 $ 346-375 race19 $ 376-405 race20 $ 406-435
                  race21 $ 436-465 race22 $ 466-495 race23 $ 496-525
                  race1e $ 526-528 race2e $ 529-531
                  race3e $ 532-534 race4e $ 535-537 race5e $ 538-540
                  race6e 541-543 race7e $ 544-546 race8e $ 547-549
                  race16c $ 550-552 race17c $ 553-555
                  race18c $ 556-558 race19c $ 559-561 race20c $ 562-564
                  race21c $ 565-567 race22c $ 568-570
                  race23c $ 571-573 race_mvr $ 574 occup $ 575-614
                  occupc $ 615-617 indust $ 618-657 industc $ 658-660
                  bcno $ 661-666 idob_yr $ 667-670 bstate $ 671-672
                  r_yr $ 673-676 r_mo $ 677-678 r_dy $ 679-680
                  ;
          %end;  /* mormer full reviser */
      %end;  /* mormer either */


      /* In some cases, this section applies to one or both events to avoid
       * more if-then looping.  We're assuming that calculations not belonging
       * to the proper event will be harmless and ignored, which may be too
       * risky.
       */

      /* Mortality */
      if alias eq 1 then delete;
      /* Mortality or Natality */
      if void eq 1 then delete;
      /* FIPS indicators. */
      %if (&the_type eq NATMER) and (&the_revreq eq 0) %then
        %do;
          /* Weak test, may want to test moth bplc and st occ also. */
          if stres eq '' and mstatres ne '' then
            do;
              call symput('FIPSDETECT', 1);
              /* Use the new FIPS fields instead of the old NCHS codes. */
              stres = mstatres;
              mothplc = mstatbth;
              state = statocc;
              cntyres = mcntyres;
              county = cntyocc;
            end;
        %end;
      %else %if (&the_type eq MORMER) and (&the_revreq eq 0) %then
        %do;
          if state eq '' and statocc ne '' then
            do;
              call symput('FIPSDETECT', 1);
              state = statocc;
              stres = statres;
              county = cntyocc;
              /* TODO probably an MVDS typo, ask bhb6 */
              cntyres = cntyres;

              %macro COMMENTEDOUT;
                /* ======== Logic is same as B20/20 code ======== */
                /* Remap to NCHS state code for partial revisers. */ 
                /* Birthplace. */
                select ( substr(xfipsbplc,1,2) );
                  /*                            see BQH0.SAS.INTRNET.PDS(MKFMT) */
                  when ( 'CA' ) stbirth = put(substr(xfipsbplc,3,2), $f_fip.);
                  when ( 'CU' ) stbirth = '56';
                  when ( 'MX' ) stbirth = '57';
                  when ( 'US' ) stbirth = put(substr(xfipsbplc,3,2), $f_fip.);
                  when ( 'ZZ' ) stbirth = '99';
                  otherwise stbirth = '59';
                end;
                /* Canada unknown. */
                if xfipsbplc = 'CAXX' then
                  stbirth = '94';

                /* Residence. */
                select ( substr(xfipsres,1,2) );
                  when ( 'CA' ) stres = put(substr(xfipsres,3,2), $f_fip.);
                  when ( 'CU' ) stres = '56';
                  when ( 'MX' ) stres = '57';
                  when ( 'US' ) stres = put(substr(xfipsres,3,2), $f_fip.);
                  when ( 'ZZ' ) stres = '99';
                  otherwise stres = '59';
                end;
                if xfipsres = 'CAXX' then
                  stres = '94';

                /* Occurrence. */
                stocc = put(substr(xfipsstcoocc,1,2), $f_fip.);
                /* ======== Logic is same as B20/20 code ======== */

                /* TODO use stored $COUNTYX. when get to that point, for now, no
                 * county info is avail to user except for this raw data displayed
                 * to keep the field from being empty
                 */
                cntyocc = substr(xfipsstcoocc,3,3);
              %mend COMMENTEDOUT;
            end;  /* FIPS indicator */
        %end;

        %if &the_type eq NATMER %then 
          %do;
            /* Start logic from NAT03: */
            /* Compute the date of birth, bdate: */
            bday = day;
            if day = '99' and month ne '99' then 
              bday='01';

            if month='02' and day='29' then 
              bday='28';

            if year ne '9999' or year ne '' then
              do;
                if month ge '01' and month le '12' then
                  do;
                    if bday ge '01' and bday le '31' then
                      do;
                        /* TODO use buildyr to build 2003 */
                        if year le 2003 then
                          do;
                            bdat = month||bday||year;
                            bdate = input(bdat, MMDDYY10.);
                          end;
                      end;
                  end;
              end;

            /* Begin computed age of mother, compmyr. */
            mday = mothday;
            if mothday eq '99' and mothmo ne '99' then
              mday = '01';

            /* Leap year keying error protection. */
            if mothmo eq '02' and mothday eq '29' then 
              mday = '28';

            if year eq '9999' or year eq '' then
              compyrm = 99;

            if mothyr eq '9999' or mothyr eq '' or mothyr eq year then
              compyrm = 99;

            if compyrm ne 99 then
              do;
                if mothmo ge '01' and mothmo le '12' then
                  do;
                    if mday ge '01' and mday le '31' then
                      do;
                        if mothyr lt year then
                          do;
                            mdat = mothmo||mday||mothyr;
                            mdate = input(mdat, MMDDYY10.);
                            compyrm =int(intck('MONTH', mdate, bdate)/12);
                            if month(mdate) eq month(bdate) then
                              compyrm = compyrm - (day(mdate)>day(bdate));
                          end;
                      end;
                  end;
                  if mdate eq . or compyrm eq . then
                    compyrm = year-mothyr;
              end;

            compmyr = compyrm;

            /* Begin computed age of father, compfyr.  */
            fday = fathday;
            if fathday eq '99' and fathmo ne '99' then
              fday = '01';

            if fathmo eq '02' and fathday eq '29' then 
              fday = '28';

            if year eq '9999' or year eq '' then
              compyrf = 99;

            if fathyr eq '9999' or fathyr eq '' or fathyr eq year then
              compyrf = 99;

            if compyrf ne 99 then
              do;
                if fathmo ge '01' and fathmo le '12' then
                  do;
                    if fday ge '01' and fday le '31' then
                      do;
                        if fathyr lt year then
                          do;
                            fdat = fathmo||fday||fathyr;
                            fdate = input(fdat, MMDDYY10.);
                            compyrf =int(intck('MONTH', fdate, bdate)/12);
                            if month(fdate) eq month(bdate) then
                              compyrf = compyrf - (day(fdate)>day(bdate));
                          end;
                      end;
                  end;
                  if fdate eq . or compyrf eq . then
                    compyrf = year-fathyr;
              end;

            compfyr = compyrf;

            mensday = mensedy;                                                            
            if mensedy = '99' then                                                        
            do;                                                                           
              if mensemo ne '99' then mensday = '01';                                     
            end;                                                                          

            if mensemo = '02' and mensedy = '29' then mensday = '28';                     

            /* Begin generation of computed gest, compgest. */

            if mensyr = '9999' or mensyr = '' then
              compgest = 99;

            if year = '9999' or year = '' then 
              compgest = 99;

            if mensyr gt year then 
              compgest = 99;

            if mensyr lt (year-1) then 
              compgest = 99;

            /* Compute the date of menses, mndate: */
            if compgest ne 99 then
              do;
                if mensemo ge '01' and mensemo le '12' then
                  do;
                    if mensday ge '01' and mensday le '31' then
                      do;
                        if mensyr le year then
                          do;
                            /* TODO use buildyr to build 2003 */
                            if year le 2003 then
                              do;
                                mndat = mensemo||mensday||mensyr;
                                mndate = input(mndat, MMDDYY10.);
                              end;
                          end;
                      end;
                  end;
             end;

            /* Compute the gestation interval. */
            if mndate = . or bdate = . then
              compgest = 99;
            else
              compgest = intck('MONTH', mndate, bdate);

            /* End logic from NAT03. */
          %end;


        /* Multi-race indicator (if the state is implementing per DAEB
         * specifications). 
         */
        %if &the_type eq NATMER and &the_revreq ne 1 %then
          %do;
            if mrace eq 'X' or frace eq 'X' then
              call symput('MULTIDETECT', 1);
          %end;
        %if &the_type eq MORMER and &the_revreq ne 1 %then
          %do;
            if race eq 'X' then
              call symput('MULTIDETECT', 1);
          %end;

        /* Full reviser indicator.  For use only when user STUMBLES on a full
         * revisor, not when specifically looking for one.
         */
        %if &the_revreq ne 1 %then
          %do;
            if xfullblock ne '' then
              call symput('FULLREVDETECT', 1);
          %end;

        /* Full reviser indicator.  For use only when user SPECIFICALLY wants
         * a revisor, not when stumbling on one.
         */
        if "&the_revreq" eq 1 then
          call symput('FULLREVNOTE', 1);
  run;

  %if &the_rptstyle eq freq %then
    %do;
      proc sort data=TMPINTRN.statemerged&yrnum;
        by &the_var1;
      run;
    %end;
%mend BuildDataset;


 /*   Accepts: nothing but uses globals
  * "Returns": nothing, potentially runs other macro(s) to create dataset(s).
  */
%macro PrepInputData;
  %local i yr1 yr2 yr3 yr4 yr5;

  %if &the_revreq ne 1 %then
    %do;
      %BuildMergeFilenames;
    %end;

  %do i=1 %to &the_maxnyr;
    /* Build 4 digit year between 2000-2999 */
    %let yr&i=20%scan(&the_yearsrequest, &i, ' ');

    %if &&yr&i ne 20X %then
      %do;
        %if (&&yr&i lt 2003) %then
          %do;
            %BuildDataset(&i);
          %end;
        %else
          %do;
            /* use MVDS */
          %end;
      %end;
  %end;
%mend PrepInputData;
%PrepInputData


  /* TODO implement again */
 /*   Accepts: an alpha code A-E to determine year (e.g. A is 2000), 
  *            string based on detected condition (FULLREV or FIPS).
  * "Returns": nothing
  *
  * A full reviser, or a FIPS state has been detected so re-create the dataset
  * for that year, looking for data in the new byte positions
  *
  * This is bad for maintenance purposes but was required to implement
  * the request for polymorphic abilities based on user's input
  */
%macro RerunInput(buildyr, detectedtyp);
  data TMPINTRN.statemerged&buildyr;
    %if &detectedtyp eq FULLREV %then
      %do;
        infile IN&buildyr MISSOVER;
        %if &the_type eq NATMER %then 
          %do;
            /* Variable names must be same as FORM value names. */
            /* TODO */
          %end;
        %else %if &the_type eq MORMER %then
          %do;
            /* Only handling simple, comparable-to-prior-year elements.  */
            /***
            input @7 certno $CHAR6.  @138 alias 1.  @189 sex $CHAR1.   
                  @237 dmonth $CHAR2.  @239 dday $CHAR2. 
                  @209 bmonth $CHAR2.  @211 bday $CHAR2.  
                  @213 ctrybrth $CHAR2.  @215 stbirth $CHAR2.  
                  @232 typlac $CHAR1.  @233 cntyocc $CHAR3.  @5 stocc $CHAR2.
                  @230 marstat $CHAR1.  @225 stres $CHAR2.
                  @1 yr $CHAR4.  @1 dyear $CHAR4.  @205 century $CHAR4.
                  ;
            ***/
            /* Hacked for now.  Either they no longer exist in the 2003 New
             * Revision or they map to new codes (e.g. typlace).
             */
            ageunit = ''; age = ''; race = ''; educ = ''; injury = ''; 
            hisp = ''; typlac = '';

            if alias eq 1 then delete;
          %end;
      %end;
    %else %if &detectedtyp eq FIPS %then
      %do;
        infile IN&buildyr MISSOVER;
        %if &the_type eq NATMER %then 
          %do;
            /* TODO */
          %end;
        %else %if &the_type eq MORMER %then
          %do;
            /* We're on the non-reviser page so we're assuming a user has
             * keyed in a FIPS-like string (e.g.  ct) in a state-oriented
             * widget to trigger this macro in the first place.  Only thing
             * that differs is stbirth, stocc, stres byte position. 
             */
            /***
            input @5 certno $CHAR6.  @47 alias 1.  @48 sex $CHAR1.   
                  @49 dmonth $CHAR2.  @51 dday $CHAR2.  @64 ageunit $CHAR1. 
                  @65 age $CHAR2.  @67 bmonth $CHAR2.  @69 bday $CHAR2.  
                  @145 stbirth $CHAR2.  @76 typlac $CHAR1.  @147 stocc $CHAR2. 
                  @79 cntyocc $CHAR3.  @82 marstat $CHAR1.  @154 stres $CHAR2.  
                  @94 hisp $CHAR1.  @95 race $CHAR1.  @96 educ $CHAR2.  
                  @117 injury $CHAR1.  @135 yr $CHAR4.  @135 dyear $CHAR4.  
                  @139 century $CHAR4.  

                  @143 xfipsbplc $CHAR4.  @147 xfipsstcoocc $CHAR5.  
                  @152 xfipsres $CHAR4.  
                  ;
            ***/
          %end;
      %end;
    %else
      %put !!!ERROR: unknown DETECTEDTYP;
  run;
%mend RerunInput;


 /*   Accepts:  a numeric code 1-5 to determine year (e.g. 1 is 2000 in '04),
  *             a 2 digit year
  * "Returns":  &settxt, the part of the SET statement after the 'set'
  *             keyword based on year(s) requested
  *
  * Used for MVDS and non-MVDS data.  May be called up to 5 times, once for
  * each of the 5 selectable years.
  */
%macro BuildSetStmt(yrnum, yy);
  %global settxt;
  %local Y4 LIB;

  /* Convert to 4 digit year. */
  %if %sysfunc(indexw(" 90 91 92 93 94 95 96 97 98 99 ", &yy)) %then
    %let Y4=%eval(1900+&yy);
  %else %if %sysfunc(indexw(" 00 01 02 03 04 05 06 07 08 09 ", &yy)) %then
    %let Y4=%eval(2000+&yy);
  %else
    %put !!!ERROR: unknown yy;

  /* MVDS datasets are named e.g. AKOLD or AKNEW */
  %if &the_revreq eq 0 %then
    %let LIB=OLD;
  %else 
    %let LIB=NEW;

  /* XX indicates user selected 'All States' which must use MVDS. */
  %if &the_state eq XX %then
    %do;
      %let settxt=%str(&settxt L.AK&LIB L.AL&LIB L.AR&LIB L.AS&LIB 
                        L.AZ&LIB L.CA&LIB L.CO&LIB L.CT&LIB L.DC&LIB
                        L.DE&LIB L.FL&LIB L.GA&LIB L.GU&LIB L.HI&LIB
                        L.IA&LIB L.ID&LIB L.IL&LIB L.IN&LIB L.KS&LIB
                        L.KY&LIB L.LA&LIB L.MA&LIB L.MD&LIB L.ME&LIB
                        L.MI&LIB L.MN&LIB L.MO&LIB L.MP&LIB L.MS&LIB
                        L.MT&LIB L.NC&LIB L.ND&LIB L.NE&LIB L.NH&LIB
                        L.NJ&LIB L.NM&LIB L.NV&LIB L.NY&LIB L.OH&LIB
                        L.OK&LIB L.OR&LIB L.PA&LIB L.PR&LIB L.RI&LIB
                        L.SC&LIB L.SD&LIB L.TN&LIB L.TX&LIB L.UT&LIB
                        L.VA&LIB L.VI&LIB L.VT&LIB L.WA&LIB L.WI&LIB
                        L.WV&LIB L.WY&LIB L.YC&LIB)
                        ;
    %end;

  %if &Y4 lt 2003 %then 
    %do;
      /* Read mergefiles to obtain pre-2003 data. */
      %let settxt=&settxt TMPINTRN.statemerged&yrnum;
    %end;
  /* 2003 is first year of MVDS datasets. */
  %else %if &Y4 ge 2003 %then
    %do;
      /* Use MVDS for the current year's current mergefile only. */
      /*                       e.g. L.IA2003   */
      %let settxt=&settxt L.&the_state.&LIB;
    %end;
%mend BuildSetStmt;


 /*   Accepts: nothing but uses globals
  * "Returns": nothing, potentially runs other macro(s) to create SAS 'set'
  *            statment(s).
  */
%macro PrepBuildSetStmt;
  %local i yr1 yr2 yr3 yr4 yr5;

  %do i=1 %to &the_maxnyr;
    %let yr&i=%scan(&the_yearsrequest, &i, ' ');

    %if &&yr&i ne X %then
      %do;
        %BuildSetStmt(&i, &&yr&i);
      %end;
  %end;
%mend PrepBuildSetStmt;
%PrepBuildSetStmt


 /*   Accepts:  type of report string (list or freq) and way too many globals
  * "Returns":  a title string for the final report
  */
%macro BuildTitleStmt(typ);
  %global titlestmt;
  %local i tmp a b c d e f theif;

  %if &typ eq freq %then
    %let theif = &ifstatementc;
  %else
    %let theif = &ifstmt;

  /* Harmless SAS warnings are generated here. */
  %do i=1 %to &the_maxnyr;
    %let tmp = &tmp &mergefs&&i;
  %end;

  /* Build the title pieces in macrovars a thru f: */

  %let a=File(s): &tmp;

  %if %bquote(&theif) ne   %then
    %let b=Criteria: %upcase([&theif]);
  %else
    %let b=Criteria: [none];

  %let c=Generated: &SYSDATE9 &SYSTIME by &the_userid;

  %if &FIPSDETECT %then
    %do;
      %let d=%str(Caution: &the_state has adopted FIPS! );
      %let d=&d %str(State-related fields may have been remapped to NCHS-style );
      %let d=&d %str(but County-related fields have not. );
    %end;
  %if &MULTIDETECT %then
    %do;
      %let e=%str(Caution: &the_state has adopted Multi-race! );
      %let e=&e %str(Race data cannot be compared to prior years. );
      %let e=&e %str(Multirace checkboxes will be displayed if race );
      %let e=&e %str(is selected. );
    %end;
  %if &FULLREVDETECT %then
    %do;
      /* User's desire to query a full reviser state cannot be met. */
      %let f=%str(Caution: &the_state is a full reviser in 2003!  Certain );
      %let f=&f %str(data elements cannot be displayed or compared to prior );
      %let f=&f %str(years. You may want to go back and select the 2003 );
      %let f=&f %str(reviser button to view full reviser state detail. );
    %end;
  %if &FULLREVNOTE %then
    %do;
      /* Confirmation of user's desire to query a full reviser. */
      %let f=%str(Note: &the_state is a full reviser in 2003. );
    %end;
  %if &the_state eq XX %then
    %do;
      %let f=%str(Caution: full reviser state data is NOT included. );
    %end;

  %let titlestmt= %bquote(%str(&a &b &c &d &e &f));
%mend BuildTitleStmt;


 /*   Accepts: nothing but uses globals
  * "Returns": nothing, optionally runs another macro
  */
%macro PrepVarRequested;
  %if &the_rptstyle eq list %then
    %do;
      /* nothing */
    %end;
  %else %if &the_rptstyle eq freq %then
    %do;
      /* TODO raise error if 1 (no boxes ckd) */
      /* E.g.        Race by... */
      %VarRequested(&the_var1)
       /*           ...Sex       */
      %VarRequested(&the_var2)
    %end;
%mend PrepVarRequested;
%PrepVarRequested


 /*   Accepts:  a pipe delim string of the checkboxes from the user (e.g.
  *             |1|2| ), the number of possible checkboxes "between the pipes"
  *             (e.g. for sex, legal values are 1, 2 or 9 so it's 3) and the
  *             name of the variable (e.g. sex)
  * "Returns":  &ifstmt
  *
  *             Builds the string following the IF keyword for freq style
  *             queries
  */
%macro BuildIfStmtFreq(checked, elems, myvar);
  %global ifstmt;
  %local i checked elems myvar firstpart field;

  %do i = 1 %to &elems;
    %let field = %scan(&checked, &i, '|');
    /* If the element is checked. */
    %if &field ne  %then
      %do;
        /* Avoid a trailing comma in the list of elements.
        /* If the previous element exists (avoid leading comma).  The values
         * of &field must be quoted for the IN stmt. 
         */
        %if &ifstmt ne   %then
          %let field = , "&field";
        %else
          %let field = "&field";
      %end;
    %let ifstmt = &ifstmt &field;
  %end;
  %let ifstmt = &myvar in(&ifstmt) ;
%mend BuildIfStmtFreq;


 /*   Accepts:  the maximum number of variables displayed global
  * "Returns":  &ifstmt used in the data step
  *
  *             Builds the string following the IF keyword for list style
  *             queries
  */
%macro BuildIfStmtList(elems);
  %global ifstmt;
  %local elems rightofIF has_constraint isbetwqry tmp;

  %let rightofIF = ;
  %let has_constraint = 0;

  /* Look in each of the checkbox widgets. */
  %do i=1 %to &elems;
    /* If the element is checked.  E.g. c1 is the HTML NAME= of the Sex
     * checkbox so the_c1 would equal the string sex...
     */
    %if &&the_c&i ne  %then
      %do;
        /* ...and we have a constraint in this textbox.  E.g. 2 */
        %if %quote(&&the_t&i) ne  %then
          %do;
            %let has_constraint = 1;

            /* Parse IN queries by wrapping criteria (e.g. 1,2,3) in parens.
             * The 'in' or 'not in' strings come from the criteria dropdown
             * widget (and are case-sensitive).
             */ 
            %if %str(&&the_op&i) eq %str(in) or 
                %str(&&the_op&i) eq %str(not in) %then
              %do;
                /* Always turn the user's param into char(s). */
                %Delimit(%bquote(&&the_t&i), %str(,), %str(""));
                %let the_t&i = (&parsed);
              %end;
            /* Parse BETWEEN queries by mutating into an IN().  E.g. user's
             * the_op10 is 'between' and the_t10 is '02-45' 
             */
            %else %if %str(&&the_op&i) eq %str(between) %then
              %do;
                /* Provides &expand.  E.g. user's 1-3 expands to 1,2,3 */
                %GenerateRange(&&the_t&i, %str(,));
                %let the_op&i = %str(IN);
                /* Turn the expanded range into a quoted, comma-delim string. */
                %Delimit(%bquote(&expand), %str(,), %str(""));
                %let the_t&i = (&parsed);
              %end;
            %else
              %do;
                /* Always turn the user's param into char(s). */
                %let the_t&i = "&&the_t&i";
              %end;
            
              %let rightofIF = &rightofIF AND &&the_c&i &&the_op&i &&the_t&i;
          %end;
      %end;
  %end;
  %if &has_constraint ne 0 %then
    %do;
      /* Cut off leading AND. */
      %let tmp = %substr(&rightofIF, 4);
      %let ifstmt = %str(IF &tmp);
    %end;
  %else
    %let ifstmt =  ;
%mend BuildIfStmtList;


 /*   Accepts:  nothing but uses globals
  * "Returns":  &lbltxt
  *
  *             Relies on permanent format library (defined elsewhere).
  *
  *             Build the parts following the LABEL keyword for list style
  *             query.  If left blank, the user will see the SAS variable name
  *             in the output  
  */
%macro BuildLabelStmtList;
  %local i fmtd;
  %global lbltxt;

  /* Want to build e.g. certno = "Certificate" day = "Day*of*Birth"... */
  %do i=1 %to &the_cmax;
    %if &&the_c&i ne  %then
      %do;
        %let fmtd=%sysfunc(putc(%left(%trim(%upcase(&&the_c&i))), $VARLABA.));
        %let lbltxt=&lbltxt &the_c&i = &fmtd;
    %end;
  %end;
%mend BuildLabelStmtList;


 /*   Accepts: nothing but uses globals
  * "Returns": most of the var statement to be used in the final proc print
  */
%macro MakeListVarStmt;
  %local i;
  %global varstmt;

  %if &the_rptstyle eq list %then
    %do;
      %do i=1 %to &the_cmax;
        %let varstmt = &varstmt &&the_c&i;
      %end;
    %end;
%mend MakeListVarStmt;
%MakeListVarStmt;


 /* Produce SAS output in HTML and send the beast to the browser. */
 /*****************************************************************/
ODS HTML body=_WEBOUT style=styles.bob rs=none;
  %macro RunFreqRpt;
    /* Hold place in case value doesn't come in as expected from the previous
     * page, otherwise we get a SAS macro error.  Nat and Mor are included
     * with the assumption that the other's variables will be ignored.  
     * TODO this is a maintenance problem 
     */
    %global month day sex birthplc attend mothmo mothday mothyr mothplc fathmo
            fathday fathyr marstat mothhisp fathhisp mrace frace motheduc
            mensemo mensedy mensyr cbegmo nbegmo plural apgar tob_use alc_use
            wgt_gain stres 

            sex race dmonth dday year birthmo birthdy typ_plac marital hispanic
            educ dstres ageunit state
            ;

    %local ifstatementA ifstatementB flagAall flagBall;
    /* Needed to check for 'No Records Found' so must be global. */
    %global ifstatementC;

    /* &the_var1 (A) comes from dropdown to the left of the word 'by',
     * &the_var2 (B) from the right-hand dropdown.
     */

    /********************************************************/
    /* Collect the user's checkboxes, if any.
    /* E.g. Sex by...  'all' is provided as the defaulted checkbox value. */
    %if &&&the_var1 ne all %then
      %do;
        %CreateCheckboxStr(&&&the_var1.request)
        /*                              e.g. &the_sexmax (3) */
        %BuildIfStmtFreq(&spaces_added, &&the_&the_var1.max, &the_var1)
        /* E.g. sex in(... */
        %let ifstatementA=%str(&ifstmt);
        /* 'all' was not requested if flag is set. */
        %let flagAall=;
      %end;
    %else
      %do;
        %let ifstatementA=;
        %let ifstatementC=;
        %let flagAall=1;
      %end;
    /* Reset for &the_var2 */
    %let ifstmt=;

    /* E.g. ...Race   The Log would have this in the Symbols Passed section:
     * "race" = "all"
     */
    %if &&&the_var2 ne all %then
      %do;
        %CreateCheckboxStr(&&&the_var2.request)
        %BuildIfStmtFreq(&spaces_added, &&the_&the_var2.max, &the_var2)
        /* E.g. ...and race in(... */
        %let ifstatementB=%str(&ifstmt);
        %let flagBall=;
      %end;
    %else
      %do;
        %let ifstatementB=;
        %let ifstatementC=;
        %let flagBall=1;
      %end;

    /* Both restricted. */
    %if &flagAall ne 1 %then 
      %do;
        %if &flagBall ne 1 %then 
          %do;
            %let ifstatementC=%str(if &ifstatementA and &ifstatementB ; );
          %end;
      %end;

    /* Only A restricted. */
    %if &flagAall ne 1 %then 
      %do;
        %if &flagBall eq 1 %then 
          %do;
            %let ifstatementC=%str(if &ifstatementA ; );
          %end;
      %end;

    /* Only B restricted. */
    %if &flagBall ne 1 %then 
      %do;
        %if &flagAall eq 1 %then 
          %do;
            %let ifstatementC=%str(if &ifstatementB ; );
          %end;
      %end;
    /********************************************************/

    /*                                           elim the temp placeholders. */
    title "&the_submit Query -- &the_type &the_state " %sysfunc(compress("&the_yearsrequest", 'X'));
    %BuildTitleStmt(freq)
    title "&titlestmt"; 

    /* We're assuming incoming datasets have been sorted previously. */
    /* ------------------------------------------------------------- */
    /* Remap whatever the year is being called to 'yr' for the procs below and
     * remap the conflicting variable names month and day (see wiz3.sas)
     */
    /* TODO? mor */
    %if &the_type eq NATMER and &the_revreq eq 1 and &USEMVDS eq 1 %then
      data TMPINTRN.allyrs (rename= idob_yr=yr)%str(;);
    %else %if &the_type eq NATMER and &the_revreq eq 0 and &USEMVDS eq 1 %then
      data TMPINTRN.allyrs (rename= year=yr)%str(;);
    %else %if &the_type eq MORMER and &the_revreq eq 1 and &USEMVDS eq 1 %then
      data TMPINTRN.allyrs (rename= dod_yr=yr)%str(;);
    %else %if &the_type eq MORMER and &the_revreq eq 0 and &USEMVDS eq 1 %then
      data TMPINTRN.allyrs (rename= (year=yr month=dmonth day=dday))%str(;);
    %else
      data TMPINTRN.allyrs%str(;);
      set &settxt;
      &ifstatementC
    run;
    libname L clear;
    /* ------------------------------------------------------------- */

    %if &the_submit = Perform Tabulate %then
      %do;
       /* Must use the variable's name in the format but the max fmt length of
        * 8 chars (including the '$') means some will have to be shortened by
        * SAS, which is OK.
        */
        proc tabulate data=TMPINTRN.allyrs;
          /* TODO put back after adding nat fmts */
          ***format &the_var1 $f_&the_var1..  &the_var2 $f_&the_var2..;
          class &the_var1 &the_var2 yr;
          table &the_var1, &the_var2*yr;
        run;
        /* Required for freq reports to detect No Records Found. */
        %CountObs(TMPINTRN.allyrs)
      %end;
    %else %if &the_submit = Perform Frequency %then
      %do;
        proc freq data=TMPINTRN.allyrs;
          /* TODO put back after adding nat fmts */
          ***format &the_var1 $f_&the_var1..  &the_var2 $f_&the_var2..;
          table &the_var1 &the_var1*&the_var2*yr / NOCUM;
        run;
        /* Required for freq reports to detect No Records Found. */
        %CountObs(TMPINTRN.allyrs)
      %end;
    %else
       %do;
         %put !!! ERROR in RunFreqRpt macro;
         %put Unknown button.  Cannot determine which query to run.;
       %end;
    title;
  %mend RunFreqRpt;

  %macro RunListRpt;
    /*              button label from calling form */
    /*                ____________                 */
    %if &the_submit = List Records %then 
      %do;
        %BuildLabelStmtList
        %BuildIfStmtList(&the_cmax)
        /* Incoming datasets have been sorted previously. */
        data TMPINTRN.allyrs;
          label &lbltxt;
          set &settxt;

          %if (&the_type eq NATMER) and (&the_revreq eq 1) %then
            %do;
              /* Handle partial reviser FIPS states. */
              if stres eq '' and mstatres ne '' then
                do;
                  call symput('FIPSDETECT', 1);
                  /* Use the new FIPS fields instead of the old NCHS codes. */
                  stres = mstatres;
                  mothplc = mstatbth;
                  state = statocc;
                  cntyres = mcntyres;
                  county = cntyocc;
                end;
              certno = fileno;
            %end;
          %else %if (&the_type eq MORMER) and (&the_revreq eq 1) %then
            %do;
              if state eq '' and statocc ne '' then
                do;
                  call symput('FIPSDETECT', 1);
                  state = statocc;
                  stres = statres;
                  county = cntyocc;
                  cntyres = cntyres;
                end;
              certno = fileno;
            %end;

          /* Nat, mort ignores */
          if alc_day ne '' then
            alc_use = substr(alc_day, 1, 1);

          if tob_day ne '' then
            tob_use = substr(tob_day, 1, 1);

          /* Mort, nat ignores */
          if age ne '' then
            ageunit = substr(age, 1, 1);

          /* Provided by %BuildIfStmtList */
          %upcase(&ifstmt);
        run;
        libname L clear;
        /* Required for list reports to limit overloading the user's browser. */
        %CountObs(TMPINTRN.allyrs)
        /* Only for 'Simple List' queries. */
        options obs=&OVERFLOWOBS;
        %BuildTitleStmt(list)
        title "&titlestmt";
        %if &numobs gt &OVERFLOWOBS %then 
          %do;
            title2 "NOTE: Your request will produce over &OVERFLOWOBS records.";
            title3 "Displaying only the first &OVERFLOWOBS of &numobs records.";
            title4 'This will avoid overloading your browser.';
            title5 'Please email LMITHELP for assistance on large queries.';
          %end;
        /* TMPINTRN.allyrs is holding only the formatted obs of interest. */
        /* TODO use LABELS if possible so that output doesn't show internal
         * names like certno or typlac 
         */
        proc print data=TMPINTRN.allyrs LABEL split='*';
          var &varstmt &STUMBLEMULT;
        run;
        title1;
      %end;
  %mend RunListRpt;

  /*   Accepts: nothing, but relies on globals
   * "Returns": nothing, just runs other macros
   */
  %macro PrepRptRun;
    %local q;

    %if &the_rptstyle eq list %then
      %do;
        %RunListRpt
        /* Protect against queries (e.g. weight) where there are massive IN()
         * ranges on which SAS fails when passing as a parameter to a macro
         * function.
         */
        %if %length(&ifstmt) > 512 %then
          %let q=[query string not available due to excessive length];
        %else
          %let q=&ifstmt;

        /* The abomination inside the parens must be used to handle embedded
         * doublequotes, etc.  in the user's IF statement.  TODO %bquote??
         */
        %NoRecordsRet(%unquote(%str(%') &q %str(%')));
      %end;
    %else %if &the_rptstyle eq freq %then
      %do;
        %RunFreqRpt
        %NoRecordsRet(%unquote(%str(%')&ifstatementC%str(%')));
      %end;
  %mend PrepRptRun;
  %PrepRptRun

  /* DEBUG toggle */
  %Diagnostics;

  /* Keep user from seeing the security risk 'Set _DEBUG=131...' message.
   * Unfortunately hides 'This request completed with errors' message too.
   * 2003-09-03 bqh0 was asked to disable this and let the errors display to
   * user.
   */
 /***   %NullifyErr; ***/
 /*****************************************************************/
ODS HTML close;
