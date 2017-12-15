options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: unnamed_pipe.win.sas
  *
  *  Summary: Demo of using an anonymous pipe (Unnamed Pipe Access Device on 
  *           Windows) to avoid temporary files 
  *
  *           Invoke a program outside the SAS System and redirect the
  *           program's input, output, and error messages to SAS.
  *
  *           One way communication.
  *
  *  Adapted: Thu 30 Mar 2006 14:42:07 (Bob Heckel --
  *                              file:///C:/Bookshelf_SAS/win/zunnamed.htm)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /*             STDERR is redirected to STDOUT      */
 /*                              ____               */
filename LISTING pipe 'dir *.txt 2>&1';

data ls;
  infile LISTING TRUNCOVER;
  input one $ two $ three $ four $;
  list;  /* for debugging */
run;

proc print data=_LAST_(obs=max); run;
