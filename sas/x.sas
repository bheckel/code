options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: x.sas (s/b symlinked as system.sas and sysexec.sas)
  *
  *  Summary: X statement, %SYSEXEC and SYSTEM() function
  *
  *  Created: Wed 21 May 2003 15:50:26 (Bob Heckel)
  * Modified: Wed 02 Mar 2016 13:50:38 (Bob Heckel)
  *---------------------------------------------------------------------------
  */

 /* Windows-specific - don't have to type 'exit' at DOS shell to close it plus
  * allows further system calls to run if necessary.
  *
  * If XSYNC is in effect, you cannot return to your SAS session until you
  * close the Notepad. But if NOXSYNC is in effect, you can switch back and
  * forth between your SAS session and the Notepad. The NOXSYNC option breaks
  * any ties between your SAS session and the other application. You can even
  * end your SAS session; the other application stays open until you close it.
  *   From file:///C:/Bookshelf_SAS/win/zxittemp.htm#xsync
  * 
  *            _______                                                    */
options source NOxwait;

data _NULL_;
  ***x 'del c:/temp/junk';
  /* 0 on success, 1 on failure */
  rc=system('dir c:\temp\');
  put _all_;
run;


data _NULL_;
  x "start lelimssumres01a&nm..sas7bdat";
  /* 0 for success */
  %put Windows status is &SYSRC;
run;


 /* These run in open code:*/
%sysexec notepad;
%put &sysrc;
 /* Windows */
%sysexec(DIR &fn >LELimsGist.txt);


 /* Sometimes SYSTEM() is better b/c it can be called conditionally: */
data _NULL_;
  /* Not sure how CALL SYSTEM would be useful. */
  if "&sysday"="Friday" then 
    rc=system("notepad");
  else 
    rc=system("mspaint");

  put rc=;
run;



 /* Conditional but without needing macro */
data _null_;
  rc1=system("chmod -R 777 /Drugs/Scorecards/2016/20160211_Run1/Cards/Storeid_06/ 2>/Drugs/Scorecards/2016/scorecard_chmod.err");
  rc2=system("find /Drugs/Scorecards/2016/20160211_Run1/Cards/Storeid_0/ -name '*.pdf*' -exec cp -p {} ~bheckel/mnt/nfs/dropboxes/scorecards/ \; 2>/Drugs/Scorecards/2016/scorecard_cp.err");
  put rc1= rc2=;

  if (rc1 ne 0) or (rc2 ne 0) then do;
    put 'ERROR: system failure during execution of scorecard code';

/***    to='bob.heckel@ateb.com';***/
    to="('fei.yu@taeb.com' 'bob.heckel@taeb.com')";
    file dummy EMAIL filevar=to subject='TESTING PLEASE IGNORE Error in scorecard code';

    stop;
  end;
run;
