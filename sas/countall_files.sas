options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: countall_files.sas (formerly countall.sas)
  *
  *  Summary: Count number of records in several merge textfiles, both at a
  *           file level and a total level.
  *
  *           See also countall_datasets.sas
  *
  *  Created: Mon 21 Jul 2003 16:04:27 (Bob Heckel)
  * Modified: Mon 23 Aug 2004 13:48:59 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source fullstimer;


data tmp;
  infile cards;
  /* !!Make sure length statement below has same width!! */
  input @1 fn $CHAR19.;
  /* DEBUG */
  ***put "!!! " _INFILE_;
  cards;
BF19.AKX0216.MEDMER
BF19.ALX0249.MEDMER
BF19.ARX0240.MEDMER
BF19.ASX0202.MEDMER
BF19.AZX0235.MEDMER
BF19.CAX0235.MEDMER
BF19.COX0247.MEDMER
BF19.CTX0229.MEDMER
BF19.DCX0223.MEDMER
BF19.DEX0224.MEDMER
BF19.FLX0258.MEDMER
BF19.GAX0292.MEDMER
BF19.GUX0206.MEDMER
BF19.HIX0230.MEDMER
BF19.IAX0225.MEDMER
BF19.IDX0227.MEDMER
BF19.ILX0263.MEDMER
BF19.INX0275.MEDMER
BF19.KSX0294.MEDMER
BF19.KYX0239.MEDMER
BF19.LAX0223.MEDMER
BF19.MAX0232.MEDMER
BF19.MDX0225.MEDMER
BF19.MEX0237.MEDMER
BF19.MIX0246.MEDMER
BF19.MNX0233.MEDMER
BF19.MOX0259.MEDMER
BF19.MSX0220.MEDMER
BF19.MTX0214.MEDMER
BF19.NEX0229.MEDMER
BF19.NCX0228.MEDMER
BF19.NDX0218.MEDMER
BF19.NHX0222.MEDMER
BF19.NJX0261.MEDMER
BF19.NMX0224.MEDMER
BF19.NVX0223.MEDMER
BF19.NYX0254.MEDMER
BF19.OHX0252.MEDMER
BF19.OKX0234.MEDMER
BF19.ORX0252.MEDMER
BF19.PAX0238.MEDMER
BF19.PRX0223.MEDMER
BF19.RIX0229.MEDMER
BF19.SCX0219.MEDMER
BF19.SDX0226.MEDMER
BF19.TNX0262.MEDMER
BF19.TXX0255.MEDMER
BF19.UTX0227.MEDMER
BF19.VAX0252.MEDMER
BF19.VIX0202.MEDMER
BF19.VTX0233.MEDMER
BF19.WAX0224.MEDMER
BF19.WIX0229.MEDMER
BF19.WVX0226.MEDMER
BF19.WYX0241.MEDMER
BF19.YCX0256.MEDMER
BF19.MPX0203.MEDMER
  ;
run;

data tmp;
  set tmp;
  length currentinfile $19;

  infile TMPBOBH FILEVAR=fn FILENAME=currentinfile TRUNCOVER END=done;

  do while ( not done );
    input;
    cnt+1;
    tot+1;
    mergefile=fn;
    output;
  end;
  cnt=0;
  call symput('TOT', tot);
run;

%put !!! %sysfunc(putn(&TOT, COMMA10.));

proc sort data=tmp;
  by mergefile;
run;

proc sql;
  create table counts as
  select mergefile label='Filename', 
         max(cnt) as maxcnt label='Record Count' format=COMMA10.
  from tmp
  group by mergefile
  ;
quit;

proc print; run;
