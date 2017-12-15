options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: loopdir_listfiles_proc_fcmp.sas
  *
  *  Summary: A recursive ls or dir for SAS to capture files (only) in an array
  *
  *           See non-recursive loopdir_readfiles_dopen.sas
  *
  *  Created: Thu 07 Nov 2013 13:03:43 (Bob Heckel)
  * Modified: Wed 23 Sep 2015 10:48:39 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

/***proc fcmp outlib=sasuser.myfuncs.dir;***/
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
  endsub;  /* dirclose */


  subroutine dir_entries(dir $, files[*] $, n, trunc);
    outargs files, n, trunc;
    length dir entry $ 256;

    if trunc then return;

    did = diropen(dir);

    if did <= 0 then return;

    dnum = dnum(did);

    do i=1 to dnum;
      entry = dread(did, i);
      /* If this entry is a file, then add to array else entry is a directory, recurse. */
      fid = mopen(did, entry);

      if symget('SYSSCP')='WIN' then do;
        entry = trim(dir) || '\' || entry;
      end;
      else if symget('SYSSCP')='HP 64' or symget('SYSSCP')="LIN X64" or symget('SYSSCP')='LINUX' or symget('SYSSCP')='AIX 64' or symget('SYSSCP')='SUN 64' then do;
        entry = trim(dir) || '/' || entry;
      end;
      else do;
        put "ERROR: unsupported OS detected &SYSSCP";
      end;
/*TODO capture directories in a separate array*/
/***array directories[1000] $ 256 _temporary_;***/
/***directories[n]=dir;***/
/***put '!!!' directories[n];***/

      if fid > 0 then do;
        rc = fclose(fid);
        if n < dim(files) then do;
          trunc = 0;
          n = n+1;
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
data _null_;
  array files[1000] $ 256 _temporary_;
  dnum = 0;
  trunc = 0;
/***  call dir_entries("c:\temp", files, dnum, trunc);***/
  call dir_entries("~/tmp", files, dnum, trunc);
  if trunc then put 'ERROR: Not enough result array entries. Increase array size.';
  do i = 1 to dnum;
    put files[i]=;
  end;
run;
