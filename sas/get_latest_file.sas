%macro get_latest_file(path=);
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


  options cmplib=work.myfuncs;
  data raw;
    length f $ 200;
    array files[2000] $ 256 _temporary_;
    dnum = 0;
    trunc = 0;
    call dir_entries("&path", files, dnum, trunc);
/***    call dir_entries("/Drugs/bheckel/tmp", files, dnum, trunc);***/
    if trunc then put 'ERROR: Not enough result array entries. Increase array size.';
/***    if dnum gt 1 then put 'ERROR: Only expecting 1 file, have received >1';***/
    do i=1 to dnum;
      f = files[i]; output;
    end;
  run;

  data parsed;
    set raw;
    if index(f, 'Archive') then delete;  /* remove subdir files */
    txt = scan(f, -1, '/');
    call symput('WCINCOMING', txt);
  run;
  proc print data=parsed(obs=max) width=minimum; run;
%mend get_latest_file; 
/***%get_latest_file(path=/Drugs/bheckel/tmp);***/
/***%let FROMWCD=%nrstr(/Drugs/Reports/Health Plans/WellCare Medicare/Files From WellCare);***/
/***%get_latest_file(path=&FROMWCD);***/
