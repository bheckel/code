 /********************************************************************************
  *  SAVED AS:                write_metadata_files.sas
  *                                                                         
  *  CODED ON:                15-May-15 by Bob Heckel
  *                                                                         
  *  DESCRIPTION:             Write a metadata file for each Scorecard PDF
  *                                                                           
  *  PARAMETERS:              N/A 
  *
  *  MACROS CALLED:           %write_metadata_files
  *                                                                         
  *  INPUT GLOBAL VARIABLES:  See below
  *                                                                         
  *  OUTPUT GLOBAL VARIABLES: NONE  
  *                                                                         
  *  LAST REVISED:                                                          
  *   ddmonyyyy (initials) (description of change)
  * 
  ********************************************************************************/

 /*************** INPUT INPUT INPUT *************************/
%global toplvlpath clientid startdt enddt dispname;
/***%let toplvlpath=/Drugs/bheckel/AN-785_createmetadata/Drugs;***/
/***%let toplvlpath=%nrstr(/Drugs/bheckel/AN-785_createmetadata/Drugs/Clients/Balls/ScoreCard/5 - May 2015);***/
%let toplvlpath=%nrstr(/Drugs/Clients/Balls/ScoreCard/5 - May 2015);
%let clientid=227;
%let startdt=05/14/14;
%let enddt=05/14/15;
%let deldt=07/14/15;
%let dispname=Overall Adherence - May 2015;
 /***********************************************************/


proc fcmp outlib=work.myfuncs.dir;
  function diropen(dir $);
    length dir $ 256 fref $ 8;
    rc = filename(fref, dir);
    if rc = 0 then do;
      did = dopen(fref);
      rc = filename(fref);
    end;
    else do;
      msg = sysmsg();
      put msg '(DIROPEN(' dir= ')';
      did = .;
    end;
    return(did);
  endsub;  /* diropen() */

  subroutine dirclose(did);
    outargs did;
    rc = dclose(did);
    did = .;
  endsub;  /* dirclose() */

  subroutine dir_entries(dir $, files[*] $, n, trunc);
    outargs files, n, trunc;
    length dir entry $ 256;

put '!!! ' dir=;
    if trunc then return;

    did = diropen(dir);

    if did <= 0 then return;

    dnum = dnum(did);

    do i=1 to dnum;
      entry = dread(did, i);
      fid = mopen(did, entry);
      entry = trim(dir) || '/' || entry;
      if fid > 0 then do;
        rc = fclose(fid);
        if n < dim(files) then do;
          trunc = 0;
          n = n + 1;
          files[n] = entry;
      end;
      else do;
        trunc = 1;
        call dirclose(did);
        return;
      end;
    end;
    else
      call dir_entries(entry, files, n, trunc);  /* recurse */
    end;

    call dirclose(did);
    return;
  endsub;  /* dir_entries() */
run;


%macro write_metadata_files(fpath=, fn=, storeid=, aid=);
  libname l "&fpath";

  data _null_;
    file "&fpath/&fn..meta.txt";
    put "&startdt.|&enddt.|&deldt.|&dispname|&clientid.|&storeid.|&aid.||||";
  run;
%mend;


 /* 1- Determine available files */
options cmplib=work.myfuncs;
data raw_filenames;
  length f $ 200;
  array files[2000] $ 256 _temporary_;
  dnum = 0;
  trunc = 0;
  call dir_entries("&toplvlpath", files, dnum, trunc);
  if trunc then put 'ERROR: Not enough result array entries. Increase array size.';
  do i = 1 to dnum;
    f = files[i]; output;
  end;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

/* E.g. /Drugs/bheckel/AN-785_createmetadata/Drugs/Clients/Balls/ScoreCard/5 - May 2015/Storeid_06/Score_Balls_44440786_20150514.pdf */
data parsed_filenames;
  set raw_filenames;

  /* Skip non-PDF files */
  if reverse(upcase(left(trim(f)))) eq: 'FDP';

  /* 2- Parse filenames */

  /* Remove filename */
  rx=prxparse('s:(.*/).*:$1:');
  rc=prxchange(rx, -1, f);

  fpath = rc;
  pdfname = scan(f, -1, '/');
  aid = scan(pdfname, 3, '_');
  storeidname = scan(f, -2, '/');
  storeid = scan(storeidname, -1, '_');

  /* 3- Write meta */
  call execute( '%write_metadata_files(fpath=' || fpath || ', fn=' || pdfname || ', storeid=' || storeid || ', aid=' || aid || ')' ); 
run;
 /* DEBUG */
proc print data=_LAST_(obs=max) width=minimum; run;

%put SYSCC is &SYSCC;
