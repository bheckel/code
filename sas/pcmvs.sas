 /* Modified: Thu 27 Feb 2003 16:06:41 (Bob Heckel) */
 /* Submit this from PC SAS to connect to mainframe. */
 /* ===> signoff to exit */

 /* May need for local HOSTS file to include this cdcjes2 */
%let cdcjes2=158.111.2.21;
filename rlink 'Signon.tcp';
options comamid=TCP remote=cdcjes2;
%let userid = %sysget(USER);

data _null_ ; 
  length userid $ 4  passwd $ 8 ;
  userid = symget('userid');
  window passwd icolumn=10 columns=50 irow=10 rows=10
         #2 @10 'USERID: ' userid
         #4 @10 'Enter Remote Password: ' passwd  display=no;
  display passwd;
  call symput('userid',userid);
  call symput('passwd',passwd);
  stop;
run;

signon;
run;
