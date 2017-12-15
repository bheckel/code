options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: garbage_character_repair.sas
  *
  *  Summary: Remove junk chars from all char vars.
  *
  *  Adapted: Wed 12 May 2010 14:59:03 (Bob Heckel--SUGI 054-2010)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

/***options NOmprint NOmlogic;***/

data t;
  set sashelp.shoes(obs=60);
  if region eq 'Africa' then
    region = 'A	frica';  /* tab */
run;
proc print data=_LAST_ width=minimum; run;

data t2;
  set t;

  array chars[*] _CHARACTER_;

  %macro repair;
    %do i=1 %to 255;  /* iterate each char (assumes ASCII) */
      if indexc(byte(&i), " ,$_+!=0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'") eq 0 then do;
        if chars[i] ne compress(chars[i], byte(&i)) then do;
          put "WARNING: found a problem character - fixing " _all_;
          chars[i] = compress(chars[i], byte(&i));
        end;
      end;
     %end;
  %mend;

  do i=1 to dim(chars);  /* iterate each of the 3 char vars */
    /* Only i=1 will get (tab) fixed, 2 and 3 (Product & Subsidiary) are ok */
    put '!!!processing ' _all_;
    %repair;
  end;
run;
proc print data=_LAST_ width=minimum; run;
