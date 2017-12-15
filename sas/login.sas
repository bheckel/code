options nosource;
 /*---------------------------------------------------------------------------
  *     Name: .../cgi-sas/login.sas
  *
  *  Summary: Authenticate a user.
  *
  *           Call via:
  *           http://localhost/cgi-sas/broker?_SERVICE=default&_PROGRAM=intrcode.login.sas&type=42&_DEBUG=131 
  *           or login.html
  *
  *  Created: Tue 05 Nov 2002 16:04:47 (Bob Heckel)
  * Modified: Tue 05 Nov 2002 16:12:06 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data work.passwd;
  infile cards;
  /* User id, password, private code. */
  length uid $4  pw $10  u $10;
  input uid $  pw $  u $;
  if uid = "&the_uid";
  if pw = "&the_pw";
  if uid = "&the_uid";
  call symput('uval', u);
  cards;
bqh0 x jdsieeljds
abc1 y jdowvnljds
def1 z jdsdflkjds
  ;
run;


ods html body=_WEBOUT (dynamic title='Authentication') style=brick rs=none;
  %macro checkusr;
    %let dsid=%sysfunc(open(work.passwd));
    %let numobs=%sysfunc(attrn(&dsid, nobs));
    %let rc=%sysfunc(close(&dsid));
    %put DEBUG: Number of observations: &numobs;

    %if &numobs = 1 %then
      %do;
        /* DEBUG */
        proc print; run;
        data _NULL_;
          file _WEBOUT;
          %let url1=%nrstr(<A HREF=http://localhost/cgi-sas/broker?_SERVICE=default&_PROGRAM=intrcode.runrpts.sas&_DEBUG=131);
          %let url2=%str(&&foo=&uval>ok</A>);
          put "&url1&url2";
        run;
        /* Avoid fall-thru to next put statement.  TODO but why does fall-thru? */
        %goto the_exit;
      %end;
    %else;
      %do;
        data _NULL_;
          file _WEBOUT;
          put '<BR><B><FONT SIZE="+1">
               <A HREF="http://localhost/intrnet/login.html">Sorry, 
               user is not in database.  Please try again.</A></FONT></B>';
        run;
      %end;
    %the_exit:
  %mend checkusr;
  %checkusr
ods html close;
