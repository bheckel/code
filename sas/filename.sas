options nosource;
 /*---------------------------------------------------------------------------
  *     Name: filename.sas
  *
  *  Summary: Demo of the filename statement and the contorted FILENAME option
  *           of the INFILE statement which will provide you the name of the
  *           file for use in a macrovar or as part of the new dataset.
  *
  *           General filename statement rule -- don't define filenames for
  *           these predefineds:
  *           DATALINES CARDS LOG PRINT
  *
  *           INFILE statement *can* be used with a direct path instead of a
  *           tag.  E.g. infile 'c:/temp/foo';
  *
  *           NOTE: filename tag max len is 8 for v8.2
  *
  *  Created: Thu 06 Feb 2003 14:21:17 (Bob Heckel)
  * Modified: Tue 20 Nov 2007 13:33:01 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

%global fname;

 /* Note: using Windows, you'll get the whole c:/... so $35 might not be big
  * enough.
  */
filename IN 'junk';
 /* Same b/c DISK is the default FILENAME engine */
***filename IN DISK 'junk';

data tmp;
  length name $ 35;  /* assume your file names are 35 or fewer characters */
  /* lvalue FILENAME assigns into rvalue 'name' !! */
  infile IN FILENAME=name MISSOVER;
  input a $  alias $  TRUNCOVER;
  if alias = '1' then delete;
  call symput('FNAME', name);
run;

data _NULL_;
  put "!!! I am file &FNAME";
  title "Using &FNAME";
run;


 /* Or simply add the filename to the dataset (good when using wildcards in
  * the FILENAME statement).  Like most things, it doesn't work on the MF.
  */
filename INWILD 'ju*k';

data work.tmp;
  length fname $ 35  myname $ 35;
  infile INWILD FILENAME=fname;
  input @3 certno $char6.;
  if certno eq '000022';
  myname=fname;
run;


 /* Multiple FILENAMEs.  Also see infile.sas for a more complex approach. */
filename INMULT ('junk1', 'junk2', 'junk3');

data work.tmp;
  length fname $ 35  myname $ 35;
  infile INMULT FILENAME=fname;
  /* fname is not automatically added to the ds, so do this to save it. */
  fsource = fname;
  input @1 certno $;
run;
proc print; run;


 /* Use the DUMMY black hole device to debug if the file is not yet 
  * available. 
	*/
filename NOTREADY DUMMY;

data work.tmp;
  length fname $ 35  myname $ 35;
  infile NOTREADY;
  input @1 certno $;
run;
proc print; run;


 /* Temporary file, TEMP is keyword */
filename wrk TEMP ;

data _null_ ;
  file wrk ;
  put 'test' ;
run ;

data _null_ ;
  infile wrk ;
  input ;
  put _infile_ ;
run ;


 /* Send output directly to default printer */
filename p PRINTER ;

data _null_ ;
  file p ;
  set sashelp.class ;
  put _all_ ;
run ;


 /* Read & write to clipboard */
filename clip CLIPBRD ;

data _null_ ;
  file clip ;
  put 'Some text to paste into somewhere.' ;
run ;


 /* Send emails */

FILENAME report EMAIL 'phil@woodstreet.org.uk' subject='test mail' 
         attach='c:\test.txt' ;

data _null_ ;
  file report ;
  put 'Hi. Here is my test email' ;
run ;

 
 /* Read or write to FTP sites */

filename host ftp 'README.txt' host='ftp.sas.com' cd='/techsup/download' 
         user='anonymous' debug ;
data _null_ ;
  infile host ;
  input ;
  put _infile_ ;
run ;

 
 /* Read from a web site */

filename x URL 'http://www.sas.com' ;

data _null_ ;
  infile x ;
  input ;
  put _infile_ ;
run ;



filename _ALL_ list;
