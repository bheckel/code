/*----------------------------------------------------------------------------
 *     Name: ck_file_in_use.sas
 *
 *  Summary: Data step tries to open an external file with disp=mod 
 *           to allow the program to later append to the flat file. If any
 *           user is reading or using that file, we want to try several times
 *           to open the file. If after several tries the file cannot be
 *           opened, cancel this program with ‚abort™ and display a message
 *           in the log.  If there is someone in the file, the loop waits 15
 *           seconds before checking again. The loop repeats this cycle at
 *           least 5 times before proceeding.
 *
 *           TODO test to see if it works.
 *
 *  Adapted: Sun 07 Apr 2002 10:22:09 (Bob Heckel -- Missing Semicolon 
 *                                     April 2000)
 *----------------------------------------------------------------------------
 */
options linesize=82 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=5 nostimer number serror merror
        noreplace;

title; footnote;

data _null_;
  /* Main loop will process until file can be opened or 5 tries. */
  maxtries = 5;
  waitsecs = 15;

  do until(stop);
    count+1;
    /* If function returns zero, file is available with 
     * disp=mod ddname filename disp
     */
    rc=filename('output1', 'ben222.sas.beamt1', ,'mod');
    put 'trying to open file - return code =' rc=;
    /* See if filename function worked. */
    if rc = 0 then 
      stop = 1;
    else 
      do;
        /* If following loop tried to maxtries, abort job. */
        if count gt maxtries then 
          do;
            put 'job will not run - tried to open file several times';
            abort;
          end;
        /* Following does a 'timer' loop for 15 seconds. */
        stoptime = time() + waittime;
        do until(time() gt stoptime);
        end;
        /* Go back and try to open the file again. */
      end;
    * endif;
  end;
  /* Leave this next stop here for safe programming. */
  stop;
run;
