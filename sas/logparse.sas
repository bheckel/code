%macro readme;
http://support.sas.com/kb/34/301.html
-----------------------
-----------------------

Readme for logparse.zip

-----------------------
-----------------------


This ZIP archive contains the SAS files logparse.sas, and passinfo.sas,
for SAS 9.3 and later releases.  See the section
"Using the Files in this Archive" below for information about how
to use these files.  See the section "Syntax of %LOGPARSE()"
below for descriptions of the arguments to the %LOGPARSE() macro.

The logparse.sas file defines the %LOGPARSE() macro.

   The %LOGPARSE() macro reads performance statistics from a SAS log
   and stores them in a SAS data file.  To create those performance
   statistics, specify the FULLSTIMER option when you execute the
   program whose performance you want to report or analyze.

   Steps in a SAS program following the %LOGPARSE() macro invocation
   can be used to subset, summarize, analyze, and report on the
   performance statistics that were extracted by %LOGPARSE().

The passinfo.sas file defines the %PASSINFO() macro.

   Use of %PASSINFO() is optional, but it includes information in the
   SAS log that vastly improves the output of %LOGPARSE().


-------------------------------
Using the Files in this Archive
-------------------------------

In the following instructions, myprogram.sas is the program whose
performance statistics you want to measure.

1. Save logparse.sas, and passinfo.sas to a directory
   on your computer.

2. Specify the FULLSTIMER option in an OPTIONS statement at the
   beginning of myprogram.sas, or on the command line.

3. Add these statements to define and invoke %PASSINFO() at the
   beginning of myprogram.sas :

   %include passinfo;
   %passinfo;

4. Create a new SAS program ("readlog.sas" in this example) that calls
   the %LOGPARSE() macro.

   For example, the following code could be contained in a readlog.sas
   program that runs in batch under Windows to report performance data
   from myprogram.log file that was created on a UNIX system:

   %include logparse;
   %logparse( myprogram.log, myperfdata, OTH );
   proc print data=myperfdata;
   run;
   /* Add subsetting, analysis, and reporting here. */

5. Run myprogram.sas and save the log in the file myprogram.log.

6. Run readlog.sas to collect and print the performance statistics.


----------------------
Syntax of %LOGPARSE()
----------------------

   %logparse(saslog, outds, system, pdsloc, append=no)

where:

   saslog  = SAS log file (for MVS, see "pdsloc" below).
   outds   = output SAS data set for results (optional):
             - if not specified, WORK.DATAn is created, where n is
               the smallest integer that makes the name unique (same
               behavior as "data; x = 1; run;").
             - if specified, names the data set created by
               this invocation of %logparse().
             - if specified and append=yes is specified, see
               documentation of the append= parameter, below.
   system  = 3-character operating system code. This parameter is
             optional; the default value is the sysem on which
             %logparse() is run. Valid codes are:
              z/OS, OS/390, or MVS    = MVS or OS
              OpenVMS Alpha           = ALP
              OpenVMS VAX             = VMS
              All other OSs           = OTH
             For more information, see "SYSSCP and SYSSCPL Automatic
             Macro Variables" in SAS Macro Language: Reference:
             Macro Language Dictionary in the SAS online documentation.
   pdsloc  = When %logparse() is executed on an MVS system and the SAS
             log file to be analyzed is stored in a partitioned data
             set (PDS), "pdsloc" partially names the PDS and "saslog"
             names the member.  The PDS name is generated with a
             leading period (making your userid the first level of the
             name) and the lowest level LOGS.
             Example:  SAS log is MYACCT.PRJ5.GRP24.LOGS(TEST47)
                       %logparse(test47, , , prj5.grp24);
   append  = create or append to the output data set (see the
             "outds" parameter, above).  This parameter is optional;
             the default value is NO.  Valid values are YES and NO:
             NO  = %logparse() creates a new SAS file according to the
                   rules for the outds parameter, above.
             YES = %logparse() appends its output to the file named by
                   the outds parameter (the file is created if it does
                   not already exist).
             Example:  %logparse(mypgm.log, lpout, VMS, append=yes);


----------
References
----------

For more information about FULLSTIMER, see "Optimizing System
Performance" in SAS Language Reference: Concepts: SAS System Concepts
in the SAS online documentation.


----------
Disclaimer
----------

THIS DOCUMENTATION IS PROVIDED "AS IS" WITHOUT WARRANTY
OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE, OR NON-INFRINGEMENT. The Institute shall not be
liable whatsoever for any damages arising out of the use of this
documentation, including any direct, indirect, or consequential
damages. The Institute reserves the right to alter or abandon use of
this documentation at any time. In addition, the Institute will
provide no support for the materials contained herein.


Copyright (c) 2008, SAS Institute Inc., Cary, NC, USA. All rights reserved.

RESTRICTED RIGHTS LEGEND  
Use, duplication, or disclosure by the U.S. Government is subject to
restrictions as set forth in subparagraph (c)(1)(ii) of the Rights in
Technical Data and Computer Software clause at DFARS 252.227-7013.
SAS INSTITUTE INC., SAS CAMPUS DRIVE, CARY, NORTH CAROLINA USA 27513
%mend readme;


/******************************************************************
*
* The %LOGPARSE() macro extracts performance statistics from a
* SAS log file.
* 
* See the README file for instructions and syntax.
*
*******************************************************************/

%macro logparse(saslog, outds, system, pdsloc, append=NO );

   /***************************************************************
   * If no system was specified, set it to the ID of the system
   * under which this proram is running, on the assumption that
   * one kind of computer is being used for both generating and
   * analyzing the logs.
   ****************************************************************/
   %if ( &system = )  %then  %let system = &sysscp;

   /***************************************************************
   * Normalize the value of the APPEND= keyword parameter.
   ****************************************************************/
   %let append = %upcase( &append );
   %if ( &append = Y  ) %then %do;  %let append = YES;  %end;
   %if ( &append = YE ) %then %do;  %let append = YES;  %end;
   %if ( &append = N  ) %then %do;  %let append = NO;   %end;

   /***************************************************************
   * Make sure APPEND= is now YES or NO.
   ****************************************************************/
   %if ( &append ne YES ) and ( &append ne NO )  %then %do;
      %put ERROR: The value of the APPEND= parameter must be YES or NO.;
      %goto exit;
   %end;

   /***************************************************************
   * If they asked for this invocation to append its output, make
   * sure a file name was supplied.
   ****************************************************************/
   %if ( &append = YES )  %then %do;
      %if ( &outds = )  %then %do;
         %put ERROR: When append=yes is specified, an output file name;
         %put        (second parameter) must also be specified.;
         %goto exit;
      %end;
   %end;

   /***************************************************************
   * Create requested data set using performance statistics found
   * in the LOG.
   ****************************************************************/
   %if ( &append = YES )  %then %do;
      data _sas_logparse_temp_1_;
   %end;
   %else %do;
      data &outds;
   %end;

      length logfile $ 200 stepname $ 20
             line $200 upcase_Line $ 200 prevline $ 200
             portdate $ 25 keyword $ 20
             platform scp $ 50 /* UNIX needs this length */
             prevblanks blanks coloncnt reprocess
             realtime usertime systime cputime
             pageflt pagercl pageswp osvconsw osiconsw
             excsemap shrsemap consemap
             blkinput bkoutput buffio dirio
             vatime vutime rsmtime excpcnt
             tskmemd tskmemp totmemd totmemp belowmem abovemem
             obsin obsout varsout
             threads events locks pools poolsx 8;

      format realtime time12.3 usertime time12.3
             systime time12.3
             datetime datetime.
             cputime time12.3;

      label  bkoutput = 'Block Output Operations'
             blkinput = 'Block Input Operations'
             buffio = 'Buffered IO'
             consemap = 'Contended Semaphores'
             cputime = 'CPU Time'
             datetime = 'Run Date/Time'
             dirio = 'Direct IO'
             events = 'Events'
             excpcnt = 'I/O count'
             excsemap = 'Exclusive Semaphores'
             host = 'System Name'
             locks = 'Locks'
             logfile = 'Log file name'
             memused = 'Memory Used'
             osmem = 'OS Memory Used'
             obsin = 'Observations Read'
             obsout = 'Observations Written'
             osiconsw = 'Involuntary Context Switches'
             osvconsw = 'Voluntary Context Switches'
             pageflt = 'Page Faults'
             pagercl = 'Page Reclaims'
             pageswp = 'Page Swaps'
             platform = 'Platform'
             pools = 'Memory Pools Created'
             poolsx = 'Memory Pools Destroyed'
             portdate = 'SAS Port Date'
             realtime = 'Elapsed Time'
             rsmtime = 'RSM Hiperspace'
             scp = 'Operating System'
             shrsemap = 'Shared Semaphores'
             stepcnt = 'Step Number'
             stepname = 'Step Name'
             systime = 'System Time'
             threads = 'Threads'
             totmemd = 'Total Memory - data'
             totmemp = 'Total Memory - program'
             tskmemd = 'Task Memory - data'
             tskmemp = 'Task Memory - program'
             belowmem = 'Total Memory - below line'
             abovemem = 'Total Memory - above line'
             usertime = 'User Time'
             varsout = 'Variables Written'
             vatime = 'Vector Affinity'
             vutime = 'Vector Usage'
             ;

      retain line upcase_Line prevline blanks prevblanks logfile
             obsin obsout varsout;
      retain stepcnt 0
             hdrfnd 0         /* 0=no hdr yet, 1=hdr fnd, 2=hdr finish*/
             portdate
             scp
             datetime
             platform         /* defined in RELNAME routine           */
             host
             ;

      /*****************************************************************
      * Moved the DROP list down here instead of an option on the DATA
      * statement to avoid generating a syntax error if no output data
      * set name is specified on the macro invocation.
      *****************************************************************/
      drop   line prevline reprocess coloncnt inbuf pos upcase_Line
             prevblanks blanks indxFld indxLen hdrfnd keyword _I_ len;


      %let ar_bnd = 3;        /* change value when array is changed   */
      array ar_hdr (&ar_bnd) $20  _temporary_ ('PASS HEADER'
                                               'APR HEADER'
                                               'WTEST HEADER');

      %if ("&sysscp" = "OS") %then %do;
         %if (%sysfunc(fileexist(".&saslog..logs"))) %then %do;
           infile ".&saslog..logs" end=lastrec pad truncover;
         %end;
         %else %do;
           infile ".&pdsloc..logs(&saslog)" end=lastrec pad truncover;
         %end;
      %end;

      %else %do;
         infile "&saslog" lrecl=250 end=lastrec pad truncover;
      %end;

      logfile="&saslog";


      /************************************************************
      * GETLINE:
      * Read in a line from the LOG file, skipping over blank
      * lines as well as page breaks.  Page breaks can be denoted
      * by "THE SAS SYSTEM" title line, but this string can also
      * appear in a NOTE: statement, so skip the former but keep
      * the latter.  Also skip lines which begin with a number,
      * like a right-justified datetime stamp.  Ordinarily such
      * lines appear on the same line as "THE SAS SYSTEM", but if
      * the user has set the LINESIZE option to a small number,
      * they are sometimes placed on the next line.
      * Stop if we hit the end of the file.
      * Remove any carriage returns (presumably from PC runs).
      * Save off the previous and current amount of indentation
      * to detect whether we're still in a FULLSTIMER block.
      *************************************************************/
      %macro getline;
         if (lastrec = 0) then do;
            prevline = line;
            do until ( (lastrec = 1) or
                       (upcase_Line =: 'NOTE:') or
                       ((compress(line) ne '') and
                        (substr(line,1,1) ne '0c'x) and
                        (compress(scan(upcase_line,1,' '),
                                  ':0123456789') ne '') and
                        (index(upcase_Line, 'THE SAS SYSTEM') le 0)) );
               input line $char200.;
               upcase_Line = upcase(line);
            end;

            line = compress(line, '0d'x);

            prevblanks = blanks;
            blanks = length(line) - length(left(line));
         end;
         else do;
            stop;
         end;
      %mend getline;


      /************************************************************
      * Read in the very first line of the LOG.
      * All subsequent lines are read in at the bottom of the loop.
      * The algorithm is written in this way to get around a
      * problem by which SAS detects a false looping condition if
      * no INPUT statement is executed in a given DATA STEP
      * iteration.
      *************************************************************/
      if (_n_ = 1) then do;
         %getline;
      end;


      /************************************************************
      * Certain steps are preceded with NOTEs containing
      * the number of observations read and/or the number of
      * observations and variables written.  Accumulate these
      * values to be written with the next observation.
      *************************************************************/
      if (index(upcase_Line,'NOTE: THERE WERE ') and
          index(upcase_Line,' OBSERVATIONS READ FROM THE DATA SET')) then do;
         obsin + input(scan(line,4,' '), 20.);
      end;
      else if (index(upcase_Line, 'NOTE: THE DATA SET ') and
               index(upcase_Line, ' OBSERVATIONS AND ') and
               index(upcase_Line, ' VARIABLES.')) then do;
         obsout + input(scan(line,7,' '), 20.);
         varsout + input(scan(line,10,' '), 20.);
      end;


      /************************************************************
      * Process PASS HEADER information
      * Look for PASS HEADER keywords
      * Each line can contain only one keyword,
      * so quit looking when a keyword is found
      *************************************************************/
      if (line = ' ' and hdrfnd = 1) then
         hdrfnd = 2;                                /* header finished */
      if (hdrfnd = 0 and (portdate = ' ' or
                          platform = ' ' or
                          scp = ' ')) then do;
         link RELNAME;
      end;

      if (hdrfnd = 0 or hdrfnd = 1) then do;       /* check for header info */
         do _I_ = 1 to &ar_bnd;
            keyword = ar_hdr(_I_);
            /* search keyword, trim needed */
            pos = index(upcase_Line, trim(keyword));
            if pos > 0 then do;                    /* keyword found */
               len = length(keyword);
               _I_ = &ar_bnd + 1;                  /* stop looking */
            end;
         end;
         keyword = ' ';                            /* clear last search lit */
         if (pos ge 1 and pos le 5) then do;       /* must be in line begining*/
            hdrfnd = 1;
            upcase_Line = substr(upcase_Line, pos + len);
            keyword = left(scan(upcase_Line,1,'='));/* find var indicator */
            select;                                /* scan out var value */
               when (keyword = 'OS')
                  scp = scan(upcase_Line,2,"=");
               when (keyword = 'HOST')
                  host = scan(upcase_Line,2,"=");
               when (keyword = 'VER')
                  portdate = scan(upcase_Line,2,"=");
               when (keyword = 'DATE') do;
                  datetime = input(scan(upcase_Line,2,"="),datetime.);
               end;
               /* add additional variable value scans here */
               otherwise;
            end;  /* select */
         end;  /* if (pos ge 1 and pos le 5) */
      end;  /* if (hdrfnd = 0 or hdrfnd = 1) */


      /************************************************************
      * Handle MVS as a special case.
      *************************************************************/
      %if ("&system" = "MVS" or "&system" = "OS") %then %do;

         /*********************************************************
         * As soon as we detect the first statistic in the current
         * block, start reading them all in.  This is done by
         * looking for the "CPU" string in the current line.  If
         * we're dealing with MVS JCL job output, there may be
         * additional lines preceding the actual SAS log which
         * contain "CPU".  Such lines are ignored if we can't
         * parse the cputime statistic from the line using known
         * SAS log syntax.
         * If we detect the SESSION-ending CPU line, output and
         * stop.
         **********************************************************/
         if (index(line, 'CPU') gt 0) then do;
            if (index(upcase_Line,
                      "INITIALIZATION PHASE USED ") > 0) then do;
               cputime=input(scan(line,6,' '), 20.) ;
               stepname=scan(line, 3, ' ') ;
               memused=input(scan(line,10,' (K'), 20.) ;


               /***************************************************
               * Check to see if the next line contains the
               * above/below line address space NOTE.  If it
               * doesn't, make sure we reprocess the line.
               ****************************************************/
               %getline;
               %macro memline;
                  if (index(upcase_Line, 'NOTE: THE ADDRESS SPACE HAS ' ||
                                         'USED A MAXIMUM OF') gt 0) then do;
                     belowmem = input(scan(line,10,' K'), 20.);
                     abovemem = input(scan(line,15,' K'), 20.);
                  end;
                  else do;
                     reprocess = 1;
                  end;
               %mend memline;
               %memline;
            end;

            else if (index(upcase_Line, "SAS SESSION USED") > 0) then do;
               cputime=input(scan(line,6,' '), 20.) ;
               stepname=scan(line,3,' ') ;
               memused=input(scan(line,10,' (K'), 20.) ;


               /***************************************************
               * Check to see if the next line contains the
               * above/below line address space NOTE.
               * Output and stop.
               ****************************************************/
               %getline;
               %memline;

               output;
               stop;
            end;

            else if (index(upcase_Line, "CPU     TIME -") > 0) then do;
               if (index(prevline, "DATA ") > 0) then
                  stepname=scan(prevline, 3, ' ');
               else
                  stepname=scan(prevline, 4, ' ');

               inbuf = scan(line, 4, ' ');
               cputime=input(inbuf, time12.3);


               /***************************************************
               * Read in the remaining FULLSTIMER lines.  We keep
               * reading as long as the line is indented the same
               * number of characters (as FULLSTIMER blocks are).
               ****************************************************/
               %getline;
               do while (blanks = prevblanks);

                  /************************************************
                  * Parse individual statistics.
                  *************************************************/
                  if (index(upcase_Line,"ELAPSED TIME -") > 0) then do;
                     inbuf = scan(line, 4, ' ');
                     realtime = input(inbuf, time12.3);
                  end;
                  else if (index(upcase_Line,
                                 "VECTOR AFFINITY TIME -") > 0) then do;
                     inbuf = scan(line, 5, ' ');
                     vatime = input(inbuf, time12.3);
                  end;
                  else if (index(upcase_Line,
                                 "VECTOR USAGE    TIME -") > 0) then do;
                     inbuf = scan(line, 5, ' ');
                     vutime = input(inbuf, time12.3);
                  end;
                  else if (index(upcase_Line,
                                 "RSM HIPERSPACE  TIME -") > 0) then do;
                     inbuf = scan(line, 5, ' ');
                     rsmtime = input(inbuf, time12.3);
                  end;
                  else if (index(upcase_Line,"EXCP COUNT") > 0) then do;
                     excpcnt = input(scan(line,4,' '), 20.);
                  end;
                  else if (index(upcase_Line,"TASK  MEMORY -") > 0) then do;
                     memused = input(scan(line,4,' K'), 20.);
                     tskmemd = input(scan(line,5,' (K'), 20.);
                     tskmemp = input(scan(line,7,' K'), 20.);
                  end;
                  else if (index(upcase_Line,"TOTAL MEMORY -") > 0) then do;
                     totmemd = input(scan(line,5,' (K'), 20.);
                     totmemp = input(scan(line,7,' K'), 20.);
                  end;

                  %getline;
               end;  /* do while (blanks = prevblanks) */


               /***************************************************
               * Check to see if the next line contains the
               * above/below line address space NOTE.  If it
               * doesn't, make sure we reprocess the line.
               ****************************************************/
               %memline;

            end;  /* else if (index(upcase_Line, "CPU     TIME -") > 0) */


            /******************************************************
            * If we at least found the CPU statistic...
            *  Output an observation corresponding to the current
            *  block of statistics.
            *  Clear out the retained variables which contain info
            *  from prior NOTE lines.
            *******************************************************/
            if (cputime ne .) then do;
               output;
               stepcnt+1;
               obsin = .;
               obsout = .;
               varsout = .;
            end;

         end;  /* if ( index(line, "CPU") > 0 ) */
      %end;  /* %if ("&system" = "MVS") */


      /************************************************************
      * All other systems share the same basic FULLSTIMER format.
      *************************************************************/
      %else %do;

         /*********************************************************
         * If we detect a line beginning "Total Elapsed Time", we
         * must be parsing a Java Test Client Application that is
         * exercising an OMR server.  If so, simply read this line
         * in as the sole statistic to be captured for this test.
         * We are currently ignoring "Elapsed Time" lines in these
         * files since there were too many of them and they were
         * making the qatrack PERFREL data sets too large.
         **********************************************************/
         if (index(line, "Total Elapsed Time:") = 1) then do;
            realtime = input(scan(line, 4, ' '), 20.);
            stepname = 'Total';
            output;
            stepcnt+1;
         end;


         /*********************************************************
         * As soon as we detect the first statistic in the current
         * block, start reading them all in.
         **********************************************************/
         else if (index(line, "real time ") > 0) then do;
            if (index(prevline, 'DATA ') > 0) then
               stepname=scan(prevline, 2, ' ');
            else
               stepname=scan(prevline, 3, ' ');


            /******************************************************
            * TIMESTAT:
            * Parses statistics that could be in time format
            * (i.e., HH:MM:SS.dd).
            * Use it to parse realtime.
            *******************************************************/
            %macro timestat(var, statword);
               inbuf = scan(line, &statword, ' ');
               coloncnt = length(inbuf) -
                          length(compress(inbuf,':'));

               if (coloncnt = 0) then
                  inbuf = '0:0:' || trim(inbuf);
               else if (coloncnt = 1) then
                  inbuf = '0:' || trim(inbuf);

               &var = input(inbuf, time12.3);
            %mend timestat;

            %timestat(realtime, 3);


            /******************************************************
            * Read in the remaining FULLSTIMER lines.  We stop
            * reading either when a line is found that isn't
            * indented (ignoring page breaks) or we reach the end
            * of the LOG.
            *******************************************************/
            %getline;
            do while (blanks = prevblanks);
               if (index(line,"user cpu time") > 0) then do;
                  %if (("&system" = "ALP") or
                       ("&system" = "VMS_AXP") or
                       ("&system" = "VMS")) %then %do;
                     %timestat(cputime, 4);
                  %end;
                  %else %do;
                     %timestat(usertime, 4);
                  %end;
               end;

               else if (index(line,"system cpu time") > 0) then do;
                  %timestat(systime, 4);
               end;

               else if (index(line,"cpu time") > 0) then do;
                     %timestat(cputime, 3);
               end;

               else if (index(line,"Semaphores") > 0) then do;
                  excsemap=input(scan(line,3," "), 20.);
                  shrsemap=input(scan(line,5," "), 20.);
                  consemap=input(scan(line,7," "), 20.);
               end;


               /***************************************************
               * GETSTAT:
               * Retrieves an integer statistic and places it in
               * the passed variable.
               ****************************************************/
               %macro getstat(text, var);
                  else if (index(line, "&text") gt 0) then do;
                     &var = input(scan(line,-1,': '), 20.);
                  end      /* do NOT put a semi-colon on this line */
               %mend getstat;

               %getstat(Page Faults, pageflt);
               %getstat(Page Reclaims, pagercl);
               %getstat(Page Swaps, pageswp);
               %getstat(Voluntary Context Switches, osvconsw);
               %getstat(Involuntary Context Switches, osiconsw);
               %getstat(Block Input Operations, blkinput);
               %getstat(Block Output Operations, bkoutput);
               %getstat(Buffered IO, buffio);
               %getstat(Direct IO, dirio);
               %getstat(Threads, threads);
               %getstat(Events, events);
               %getstat(Locks, locks);
               %getstat(Memory Pools  Created, pools);
               %getstat(Memory Pools  Destroyed, poolsx);

               else if (index(line,"OS Memory ") > 0) then do;
                  osmem = input(compress(scan(line,3,' '),'k'), 20.);
               end;

               else if (index(line,"Memory ") > 0) then do;
                  memused = input(compress(scan(line,2,' '),'k'), 20.);
               end;

               %getline;
            end;  /* do while (blanks = prevblanks) */


            /******************************************************
            * Make sure we reprocess the last line read in since
            * it is not part of the FULLSTIMER block.
            *******************************************************/
            reprocess = 1;


            /******************************************************
            * Output an observation corresponding to the current
            * block of statistics.
            * Clear out the retained variables which contain info
            * from prior NOTE lines.
            *******************************************************/
            output;
            stepcnt+1;
            obsin = .;
            obsout = .;
            varsout = .;
         end; /* else if ( index(line, "real time ") > 0 ) */
      %end;  /* %else (this is a non-MVS system) */


      /************************************************************
      * If we haven't already, read in the next line.
      *************************************************************/
      if (reprocess ne 1) then do;
         %getline;
      end;

      return;


      /************************************************************
      * Identify the port date and platform.
      *************************************************************/
      RELNAME:
         length indxFld $255;
         indxFld = "PROPRIETARY SOFTWARE PRE-PRODUCTION VERSION";
         pos = indexw(upcase_Line, indxFld);
         if (pos = 0) then do;
            indxFld = "PROPRIETARY SOFTWARE RELEASE";
            pos = indexw(upcase_Line,indxFld);
         end;
         if (pos = 0) then do;
            indxFld = "PROPRIETARY SOFTWARE VERSION";
            pos = indexw(upcase_Line,indxFld);
         end;
         if (pos > 0) then do;
            /* drop initial part of line */
            indxLen = length(trim(indxFld));
            upcase_Line = substr(upcase_Line,pos + indxLen + 1);
            portdate = compress(scan(upcase_Line,-2,' ') || ' ' ||
                                scan(upcase_Line,-1,' '), '()');
         end;
         indxFld = 'THIS SESSION IS EXECUTING ON THE';
         pos = indexw(upcase_Line, indxFld);
         if (pos > 0) then do;
            /* drop initial part of line */
            indxLen = length(trim(indxFld));
            upcase_Line = substr(upcase_Line,pos + indxLen + 1);
            line = substr(line,pos + indxLen + 1);
            /* find end of platform name */
            pos = index(upcase_Line, "PLATFORM");
            if pos > 1 then do;
               /* save original case of platform name */
               platform = substr(line, 1, pos - 1);
            end;
         end;
         indxFld = 'RUNNING ON';
         pos = indexw(upcase_Line, indxFld);
         if (pos > 0) then do;
            /* drop initial part of line */
            indxLen = length(trim(indxFld));
            upcase_Line = substr(upcase_Line,pos + indxLen + 1);
            line = substr(line,pos + indxLen + 1);
            /* find end of platform name */
            pos = index(upcase_Line, ".   ");
            if (pos le 1) then
               pos = length(trim(upcase_Line)) + 1;
            /* save original case of operating system name */
            scp = substr(line, 1, pos - 1);
         end;
      return;  /* RELNAME: */
   run;

   /***************************************************************
   * If they asked for this invocation to append its output:
   * ==> Append the file produced above to the specified file.
   * ==> Delete the temporary file
   ****************************************************************/
   %if ( &append = YES )  %then %do;
      proc datasets  lib=work  nolist;
         append  base=&outds  data=_sas_logparse_temp_1_;
         delete _sas_logparse_temp_1_;
      quit;
   %end;

%exit:  %mend logparse;
