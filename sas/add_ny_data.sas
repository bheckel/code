options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: ADDNY
  *
  *  Summary: Rebuild an existing file, replacing bad data with good.
  *           Must make sure to unmap pseudo certificates to real ones to get
  *           the good data from the new file (then re-dummy the cert no).
  *
  *           Runs via Connect.
  *
  *  Created: Thu 08 Jul 2004 15:37:27 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

filename CERTMAP 'DWJ2.FLMOR03.USMED';
filename OLDALL 'DWJ2.FLMOR03R.USRES';
filename NEWNY 'BF19.NYX0351.MORMERZ';
filename OUTF 'DWJ2.FLMOR03R.USRES2' LRECL=700 DISP=OLD;

 /*******************************/
 /***************/
data map (drop= dstate);
  infile CERTMAP;
  input dstate $ real $ fake $CHAR6.;
  if dstate eq 'NY';
run;

data oldny (drop= stod);
  infile OLDALL TRUNCOVER PAD;
  input @5 stod $CHAR2.  @7 dumcert $CHAR6.  
        @217 fipnines $CHAR8.  @225 fipst $CHAR2.
        ;
  if stod eq 'NY';
run;

proc sql;
  create table decoded as
    select a.real, a.fake,
           b.dumcert, b.fipnines
    from map as a LEFT JOIN oldny as b on a.fake=b.dumcert
    ;
quit;
 /***************/


data newfipfl;
  infile NEWNY TRUNCOVER PAD;
  input @5 stod $CHAR2.  @7 cert $CHAR6.  @217 fipnew $CHAR8.  
        @225 fipst $CHAR2.
        ;
  if fipst eq 'FL';
run;

proc sql;
  create table finalfl as
    select a.real, a.fake,
           b.cert, b.fipnew
    from decoded as a LEFT JOIN newfipfl as b on a.real=b.cert
    ;
quit;
 /*******************************/


 /*******************************/
data oldall;
  infile OLDALL TRUNCOVER PAD;
  input @1 b1 $CHAR6.  @5 st $CHAR2.  @7 dcno $CHAR6.  @13 b2 $CHAR204.
        @217 fipres $CHAR8.  @225 b3 $CHAR476.
        ;
run;

proc sql;
  create table final as
    select a.b1, a.st, a.dcno, a.b2, a.fipres, a.b3,
           b.real, b.fake, b.fipnew
    from oldall as a LEFT JOIN finalfl as b on a.dcno=b.fake
    ;
quit;
 /*******************************/

data final (drop= st fake);
  set final;
  /* Make sure blanks are not skipped during output to file. */
  lb1 = length(trim(put(b1, $CHAR.)));
  lb2 = length(trim(put(b2, $CHAR.)));
  lb3 = length(trim(put(b3, $CHAR.)));
  if st eq 'NY' then
    fipcitycounty = fipnew;
  else
    fipcitycounty = fipres;
run;

data _NULL_;
  set final;
  ***file OUTF PAD LRECL=700;
  file OUTF;
  put @1 b1 $VARYING. lb1
      @7 dcno $CHAR6.
      @13 b2 $VARYING. lb2
      @217 fipcitycounty $CHAR8.
      @225 b3 $VARYING. lb3
      ;
run;
