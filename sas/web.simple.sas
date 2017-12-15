options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: web.simple.sas
  *
  *  Summary: Simple dump of a dataset to HFS web page.
  *
  *  Created: Mon 09 May 2005 13:40:12 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;


 /* Write a Unix webpage using the results.  Could have used ODS. */
data _NULL_;
  set tmp END=e;

  /* http://mainframe.cdc.gov/sasweb/nchs/bob/t.html */
  file '/u/bqh0/public_html/bob/t.html';

  if _N_ eq 1 then
    put @1 '<B>2004 current MEDMER mergefiles -- Certifier<BR><BR></B>
            <TABLE><CODE>'
            ;

  put @1 '<TR><TD>'f'<TD>' certifier '<BR>';

  if e then
    put @1 '</CODE></TABLE>';
run;
