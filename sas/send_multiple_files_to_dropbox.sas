options mprint=yes mprintnest=yes mlogic=no symbolgen=yes sasautos=(SASAUTOS 'E:\Macros') validvarname=any emailsys=SMTP emailhost='smtp-01.mrk.ateb.com' emailport=25;
/********************************************************************************
*  SAVED AS:                send_multiple_files_to_dropbox.sas
*
*  CODED ON:                19-May-16 by Bob Heckel
*
*  DESCRIPTION:             Send several files to dropbox
*
*  PARAMETERS:              localdir - linux-style path where generated content for dropbox is produced
*                           dropbox - linux-style path where dropbox is located 
*                           erroremail - who to notify in case of failure
*
*                           Sample call:
*  %send_multiple_files_to_dropbox(localdir=/cygdrive/e/TMMEligibility/Rexall/WeeklyTargetPatientReport/20160517/Output,
*                                dropbox=/mnt/nfs/dropboxes/pmap_rpt_dropbox,
*                                erroremail=bob.heckel@ateb.com
*                                );
*
*  MACROS CALLED:           NONE
*
*  INPUT GLOBAL VARIABLES:  NONE
*
*  OUTPUT GLOBAL VARIABLES: NONE
*
*  LAST REVISED:
*   19-May-16   Initial version
********************************************************************************/
%macro send_multiple_files_to_dropbox(localdir=, dropbox=, erroremail=);
  data _null_;
    if "&SYSUSERID" eq 'efi.yu' then call symput('linuxuser', 'fyu');
    else if "&SYSUSERID" eq 'obb.heckel' then call symput('linuxuser', 'bheckel');
    else put "ERROR: unknown &=SYSUSERID";
  run;

  data _null_;
    /* On Cygwin.  Compress to avoid doing 400 scp calls. */
    rc1=system("tar cvfz &localdir/../tmp.tgz -C &localdir .");
    if rc1 eq 0 then do; put 'NOTE: tar successful'; end; else do; put 'ERROR: tar fail'; to="&erroremail"; file dummy email filevar=to subject="Error during %sysfunc(getoption(SYSIN))"; abort; end;

    /* On Cygwin.  scp tarball to dropbox. */
    rc2=system("scp &localdir/../tmp.tgz &linuxuser@dataproc.mrk.ateb.com:/&dropbox");
    if rc2 eq 0 then do; put 'NOTE: scp successful'; end; else do; put 'ERROR: scp fail'; to="&erroremail"; file dummy email filevar=to subject="Error during %sysfunc(getoption(SYSIN))"; abort; end;

    /* On dataproc.  Extract in dropbox, open permissions, remove temp tarball.  Hope PMAP doesn't fail. */
    rc3=system("ssh -l &linuxuser dataproc.mrk.ateb.com 'cd &dropbox ; tar xfz &dropbox/tmp.tgz ; chmod 777 -R &dropbox ; rm tmp.tgz'");
    if rc3 eq 0 then do; put 'NOTE: ssh successful'; end; else do; put 'ERROR: ssh fail'; to="&erroremail"; file dummy email filevar=to subject="Error during %sysfunc(getoption(SYSIN))"; abort; end;
  run;
%mend;
%send_multiple_files_to_dropbox(localdir=/cygdrive/e/MTMEligibility/eeklyTargetPatientReport/20160517/Output,
                                dropbox=/mnt/nfs/home/hbeckel/tmp/1463683504_19May16,
                                erroremail=bob.heckel@taeb.com
                                );

