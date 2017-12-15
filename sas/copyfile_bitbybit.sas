options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: copyfile_bitbybit.sas
  *
  *  Summary: Copy any file anywhere SAS can read/write
  *
  *  Adapted: Mon 20 Jun 2011 14:54:52 (http://blogs.sas.com/sasdummy/index.php?/archives/261-How-to-use-SAS-DATA-step-to-copy-a-file-from-anywhere.html&utm_source=feedburner&utm_medium=feed&utm_campaign=Feed:+ASasBlogForTheRestOfUs+%28The+SAS+Dummy%29&utm_content=Google+Reader)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

/* these IN and OUT filerefs can point to anything */
/***filename in "c:\dataIn\input.xlsx";***/
/***filename out "c:\dataOut\output.xlsx";***/
filename IN 'junk';
filename OUT 'junkout';

/* copy the file byte-for-byte  */
data _null_;
  length filein 8 fileid 8;
  filein = fopen('IN','I',1,'B');
  fileid = fopen('OUT','O',1,'B');
  rec = '20'x;
  do while(fread(filein)=0);
     rc = fget(filein,rec,1);
     rc = fput(fileid, rec);
     rc =fwrite(fileid);
  end;
  rc = fclose(filein);
  rc = fclose(fileid);
run;

filename IN clear;
filename OUT clear;
