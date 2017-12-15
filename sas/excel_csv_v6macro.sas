
 /* See excel_tabdelim.sas for shorter version. */

 /*******************************************************************/
 /***TIP00059.sas                                                 ***/
 /***  A set of SAS macros which will read an Excel CSV file      ***/
 /***    and create a SAS Dataset                                 ***/
 /***                                                             ***/
 /***  Currently all character data is read using a length of 40. ***/
 /***  It can be changed easily enough to handle varied lengths.  ***/
 /***                                                             ***/
 /***  Charles Patridge      Email: Charles_S_Patridge@prodigy.com***/
 /***  172 Monce Road        Phone: 860-673-9278                  ***/
 /***  Burlington, CT 06013                                       ***/
 /*******************************************************************/

 /*******************************************************************/
 /***Sample of what the CSV file should look like                 ***/
 /***5,,,,                          1st record                    ***/
 /***id,fname,lname,salary,age      2nd record                    ***/
 /***n,c,c,n,n                      3rd record                    ***/
 /***1,charles,patridge,100000,48   data record                   ***/
 /***2,michael,davis,200000,32      data record                   ***/
 /*******************************************************************/

 /*** create a libname to place the new SAS dataset created from Excel ***/
 libname kittlib "userdisk1:[patridge.kitt]"; run;
      /*** path name of directory holding the CSV file ***/
 %let path = pathworks:[actres_common.patridge.aaachuck.kitt];
      /*** name of actual CSV file ***/
 %let rawfile = vern.csv ;
      /*** name of SAS Dataset you wish to create ***/
 %let sasdsn  = kittlib.vern;

 /*******************************************************************/
 /*GLOBVARS.SAS                                                     */
 /*   A SAS MACRO TO PRODUCE A LIST OF MACRO VARIABLES AS PART OF   */
 /*   ANOTHER SAS STATEMENT OR COMMAND, SUCH AS %GLOBAL.            */
 /*                                                                 */
 /*******************************************************************/

 %MACRO GLOBVARS(PREFIX, NUMBER);
   %LOCAL J;
   %DO J=1 %TO &NUMBER;
       &PREFIX&J
   %END;
 %MEND GLOBVARS;
 /*** END OF SAS PROGRAM ***/

 /*** 1st record of Excel file needs to have number of SAS variables ***/

 data numvars;
  infile "&path.&rawfile" delimiter=",!" dsd missover firstobs=1 obs=1;
  input numvars;
  call symput('numvars', left(put( numvars, 3. )));
 run;

 /*** 2nd record of Excel file needs to have the names of SAS variables ***/

 data premvar(drop=i);
  length dat1-dat&numvars $ 8 ;
  array dat(&numvars) dat1-dat&numvars;
  infile "&path.&rawfile" delimiter=",!" dsd firstobs=2 obs=2;
  input dat1-dat&numvars;
  do i = 1 to dim(dat);
   dat(i) = left( compress( dat(i), "'") );
  end;
 run;

 /*** 3rd record of Excel needs to have an N or C for numeric or character ***/

 data numchar(drop=i);
  length dat1-dat&numvars $ 8 ;
  array dat(&numvars) dat1-dat&numvars;
  infile "&path.&rawfile" delimiter=",!" dsd firstobs=3 obs=3;
  input dat1-dat&numvars;
  do i = 1 to dim(dat);
   dat(i) = upcase ( left( compress( dat(i), "'") ));
  end;
 run;

 /*** 4th record and beyond is the data ***/

 data premdat(drop=i);
  length dat1-dat&numvars $ 40 ;
  array dat(&numvars) dat1-dat&numvars;
  infile "&path.&rawfile" delimiter=",!" dsd  firstobs=4      ;
  input dat1-dat&numvars;
  do i = 1 to dim(dat);
   dat(i) = upcase( left( compress( dat(i), "'") ));
  end;
 run;

 %global %globvars( dat, &numvars );

 %macro creatvar;
  /*** create SAS variable names ***/
  data _null_;
   set premvar;
  array dat(&numvars) dat1-dat&numvars;
  %do ii = 1 %to &numvars;
      call symput( "dat&ii" , dat(&ii) );
  %end;
 %mend creatvar;

 %creatvar;

 %global %globvars( ncv, &numvars );

 %macro numchar ;
  /*** get whether SAS variable is numeric or character ***/
  data _null_;
   set numchar;
  array dat(&numvars) dat1-dat&numvars;
  %do ii = 1 %to &numvars;
      call symput( "ncv&ii" , dat(&ii) );
  %end;
 %mend numchar ;

 %numchar ;

 %macro assnvalu;
  /*** create SAS dataset with all variables for all observations ***/
  data &sasdsn (drop=dat1-dat&numvars);
   set premdat;
  array dat(&numvars) dat1-dat&numvars;
   %do kk = 1 %to &numvars;
       %if &&ncv&kk = N %then &&dat&kk = dat(&kk) / 1;;;
       %if &&ncv&kk = C %then &&dat&kk = dat(&kk)    ;;;
   %end;
  run;
 %mend assnvalu;

 %assnvalu;

 proc datasets library=work; delete numvars premvar numchar premdat; quit;

 /*** end of program - tip00059 ***/

