/* See ~/code/misccode/cygwin_scp_to_linux.bat */
%macro send_to_dropbox(cygpath=, fn=, server=, droppath=);
  /* This code replaces Linux functionality on Canadian sas02 to send a Windows file to dropbox */

  data _null_;
    if "&sysuserid" eq 'fei.yu' then call symput('linuxuser', 'fyu');
    else if "&sysuserid" eq 'bob.heckel' then call symput('linuxuser', 'bheckel');
    else if "&sysuserid" eq 'hannah.walters' then call symput('linuxuser', 'hwalters');
    else if "&sysuserid" eq 'mounika.jonnakuti' then call symput('linuxuser', 'mjonnaku');
    else if "&sysuserid" eq 'minggang.cui' then call symput('linuxuser', 'mcui');
  run;

  data _null_;
    /*                 Windows path                      Cygwin path                                Cygwin scp syntax                                                          */
    /*  rc=system("c:\Analytics\send_to_dropbox.bat /cygdrive/c/Analytics/ test.fdw &linuxuser dataproc.mrk.taeb.com://mnt/nfs/home/janitor/dataproc/tmm/eligibility/pending");*/
    rc=system("e:\Macros\send_to_dropbox.bat &cygpath &fn &linuxuser &server:/&droppath");
    if rc ne 0 then put 'ERROR: failed to transfer';
  run;
%mend;
/***%send_to_dropbox(cygpath=/cygdrive/e/TMMEligibility/taebdemo/Imports/, fn=test5.txt, server=dataproc.mrk.taeb.com, droppath=/mnt/nfs/home/bheckel);***/
