 /*---------------------------------------------------------------------------
  *     Name: BQH0.SAS.INTRNET.PDS(WIZ)
  *
  *  Summary: Authenticate user, then generate a dynamic page from which 
  *           user can further refine the query parameters via a wizard-like
  *           interface.
  *
  *  Created: Fri 21 Mar 2003 10:01:13 (Bob Heckel)
  *      RCS:
  *           $Log: wiz.sas,v $
  *           Revision 1.8  2003/12/19 15:50:11  bqh0
  *           Added natality non-reviser and reviser query capability.
  *           Added output to MS Excel option to avoid IE URL length limitation.
  *           Improved interface.
  *
  *           Revision 1.7  2003/09/19 19:57:08  bqh0
  *           Fix two-way display of >1 year in output.  Add century to revisers.
  *           Fix educ edit dropdown example.  Cleanup age fields on non-rev and revisers.
  *           Changes based on Brenda's review.
  *
  *           Revision 1.6  2003/08/27 19:05:34  bqh0
  *           Allow partial reviser Multirace info to display if user queries
  *           a Multirace state on race.  Also allow provide checkboxes for
  *           users who know the state has adopted Multirace.
  *
  *           Revision 1.5  2003/08/18 21:06:39  bqh0
  *           Added variables to two-way, fixed bugs in two-way, improved interface,
  *           added multirace checkboxes to bottom of reviser page.
  *
  *           Revision 1.4  2003/08/08 21:09:54  bqh0
  *           Created separate pages for reviser states.
  *
  *           Revision 1.3  2003/07/09 19:36:16  bqh0
  *           Improve error trap on requested files that don't exist.  Provide query
  *           details in the output.
  *
  *           Revision 1.2  2003/07/09 14:11:10  bqh0
  *           Initial mods for dev version.
  *
  *---------------------------------------------------------------------------
  */
options NOsource NOmlogic NOsymbolgen NOs99nomig;

%global STDFOOTR;
%let STDFOOTR=BQH0.SAS.INTRNET.PDS(STDFOOTR);

 /* "Returns" the xxxx in the "Select Your xxxx Query Type" line and an
  * indicator that user wants an Revisor state query. 
  */
%macro SelectType;
  /* Uppercase indicates that we, not form widgets, created the macrovar. */
  %global FULLTYPE REVREQ;

  /* An HTML form will pass the value of its widgets forward as macrovariables
   * for each widget holding a value. 
   */

  /* It's a non-reviser request. */
  %if &type eq natmer %then
    %let FULLTYPE = Natality;
  %else %if &type eq mormer %then
    %let FULLTYPE = Mortality;

  /* It's a revisor request. */
  %if %index(&type, r) eq 1 %then
    %do;
      /* Return to normal '&type' relied on by the other wizards. */
      %let type=%substr(&type, 2);
      %let REVREQ = 1;
    %end;
  %else
    %let REVREQ = 0;
%mend SelectType;
%SelectType


 /* Authorize user before proceeding. */
proc format;
  invalue $pw
      'alm5','ALM5' = 'adrienne5'
      'bhb6','BHB6' = 'brenda6'
      'bqh0','BQH0' = 'bob0'
      'bxj9','BXJ9' = 'brenda9'
      'ces0','CES0' = 'chuck0'
      'dwj2','DWJ2' = 'david2'
      'ekm2','EKM2' = 'erica2'
      'fdw0','FDW0' = 'francine0'
      'hdg7','HDG7' = 'heather7'
      'kjk4','KJK4' = 'kryn4'
      'rev2','REV2' = 'rajesh2'
      'tbe2','TBE2' = 'teresa2'
      'vdj2','VDJ2' = 'jenny2'
      'vpm1','VPM1' = 'van1'
              OTHER = .
              ;
run;


 /* One huge datastep just to produce an HTML form. */
data _NULL_;
  file _WEBOUT;

  /* value              key            */
  passwd_val = input("&userid", $pw.);

  put '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">';
  put '<HTML>';
  put '<HEAD>';
  if "&passwd" ne passwd_val then
    do;
      put "  <TITLE>Authentication Failure</TITLE>";
      put '</HEAD> ';
      put '<BODY> ';
      put '  <H3><FONT COLOR=red>Authentication Failure.  ';
      put "  <H4>Your IP address (&_RMTADDR) has been logged. ";
      put "  Either userid: &userid or password: &passwd is incorrect.<BR><BR>";
      put '  Please click Back to try again or contact LMITHELP for assistance.</H3></FONT>';
    end;
  else
    do;
      /* Want consistent display. */
      %let T=%upcase(&type);
      put "  <TITLE>Build Query Step 2 of 4 (&T)</TITLE>";
      put '  <META NAME="author" CONTENT="Robert S. Heckel Jr. (BQH0)"> ';
      put '</HEAD> ';
      put '<BODY> ';
      put '  <BR><BR><BR>';
      put '  <TABLE WIDTH=90% ALIGN="center" BORDER=0 CELLSPACING=0 CELLPADDING=1>';
      put '  <TR><TD BGCOLOR=#999999>';
      put '  <TABLE WIDTH=100% BORDER=0 CELLSPACING=0 CELLPADDING=0>';
      put '  <TR><TD BACKGROUND="http://mainframe.cdc.gov/sasweb/nchs/intrnet/y.gif">';
      put '  <FONT SIZE=+1 COLOR=#333333><I><B>&nbsp;';
      put "  Select Your &FULLTYPE Query Type:</B></I></FONT></TABLE></TABLE>";
      put '  <TABLE BORDER=1 ALIGN="center" WIDTH=90% BGCOLOR=#FFFFFF';
      put '         CELLSPACING=0 CELLPADDING=5><TD>';
      put '    <FORM ACTION="http://mainframe.cdc.gov/sasweb/cgi-bin/broker"';
      put '          METHOD="GET" NAME="the_form"> ';
      put '      <INPUT TYPE="hidden" NAME="_DEBUG" VALUE="0"> ';
      put '      <INPUT TYPE="hidden" NAME="_SERVICE" VALUE="default"> ';
      put '      <INPUT TYPE="hidden" NAME="_PROGRAM" VALUE="nchscode.Dwiz2.sas"> ';
      /* Macrovariables created on this or prior page to be passed to the next
       * page.  They must be declared as globals in wiz2.  The 'the_' suffix
       * convention indicates creation on a page other than the current.  E.g.
       * &userid is immediately available on this page but will be called
       * &the_userid on the next page.
       */
      put "      <INPUT TYPE='hidden' NAME='the_type' VALUE=&type> ";
      put "      <INPUT TYPE='hidden' NAME='the_userid' VALUE=&userid> ";
      put "      <INPUT TYPE='hidden' NAME='the_fulltype' VALUE=&fulltype> ";
      put "      <INPUT TYPE='hidden' NAME='the_revreq' VALUE=&REVREQ> ";
      put '      <CENTER> ';
      put '      <INPUT TYPE="radio" NAME="rptstyle" VALUE="list" ';
      put '       CHECKED>Simple List';
      if &REVREQ eq 1 then
        do;
          put '  <INPUT TYPE="radio" NAME="rptstyle" DISABLED VALUE="freq">';
          put '  Two-Way Table (under development)';
        end;
      else
        put '      <INPUT TYPE="radio" NAME="rptstyle" VALUE="freq">Two-Way Table';
      put '      <BR><BR>';
      put '      <INPUT TYPE="submit" VALUE="Next >">';
      put '    </FORM>';
      put '  </TABLE><BR><BR><BR><BR>';
      %include "&STDFOOTR";
  end;
  put '</BODY> ';
  put '</HTML>';
run;
