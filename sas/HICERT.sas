options NOsource;
 /*---------------------------------------------------------------------
  *     Name: HICERT.sas
  *
  *  Summary: Find the highest certificate number for all single series
  *           states for years 2000-2002 per Chrissy.
  *
  *  Created: Thu 29 Jul 2004 16:23:00 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options source NOcenter;


 /* Part I, build the dataset of filenames. */
data tmp;
  input fn $ 1-21;
  cards;
BF20.OLS.VSCP.AK00MOR
BF20.OLS.VSCP.AL00MOR
BF20.OLS.VSCP.AR00MOR
BF20.OLS.VSCP.AS00MOR
BF20.OLS.VSCP.AZ00MOR
BF20.OLS.VSCP.CA00MOR
BF20.OLS.VSCP.CO00MOR
BF20.OLS.VSCP.CT00MOR
BF20.OLS.VSCP.DC00MOR
BF20.OLS.VSCP.DE00MOR
BF20.OLS.VSCP.FL00MOR
BF20.OLS.VSCP.GA00MOR
BF20.OLS.VSCP.GU00MOR
BF20.OLS.VSCP.HI00MOR
BF20.OLS.VSCP.IA00MOR
BF20.OLS.VSCP.ID00MOR
BF20.OLS.VSCP.KS00MOR
BF20.OLS.VSCP.KY00MOR
BF20.OLS.VSCP.LA00MOR
BF20.OLS.VSCP.MD00MOR
BF20.OLS.VSCP.ME00MOR
BF20.OLS.VSCP.MI00MOR
BF20.OLS.VSCP.MN00MOR
BF20.OLS.VSCP.MP00MOR
BF20.OLS.VSCP.MS00MOR
BF20.OLS.VSCP.MT00MOR
BF20.OLS.VSCP.NC00MOR
BF20.OLS.VSCP.ND00MOR
BF20.OLS.VSCP.NE00MOR
BF20.OLS.VSCP.NH00MOR
BF20.OLS.VSCP.NJ00MOR
BF20.OLS.VSCP.NM00MOR
BF20.OLS.VSCP.NV00MOR
BF20.OLS.VSCP.NY00MOR
BF20.OLS.VSCP.OH00MOR
BF20.OLS.VSCP.OK00MOR
BF20.OLS.VSCP.OR00MOR
BF20.OLS.VSCP.PA00MOR
BF20.OLS.VSCP.PR00MOR
BF20.OLS.VSCP.RI00MOR
BF20.OLS.VSCP.SC00MOR
BF20.OLS.VSCP.SD00MOR
BF20.OLS.VSCP.TN00MOR
BF20.OLS.VSCP.TX00MOR
BF20.OLS.VSCP.UT00MOR
BF20.OLS.VSCP.VA00MOR
BF20.OLS.VSCP.VT00MOR
BF20.OLS.VSCP.WA00MOR
BF20.OLS.VSCP.WI00MOR
BF20.OLS.VSCP.WV00MOR
BF20.OLS.VSCP.WY00MOR
BF20.OLS.VSCP.YC00MOR
BF20.OLS.VSCP.AK01MOR
BF20.OLS.VSCP.AL01MOR
BF20.OLS.VSCP.AR01MOR
BF20.OLS.VSCP.AS01MOR
BF20.OLS.VSCP.AZ01MOR
BF20.OLS.VSCP.CA01MOR
BF20.OLS.VSCP.CO01MOR
BF20.OLS.VSCP.CT01MOR
BF20.OLS.VSCP.DC01MOR
BF20.OLS.VSCP.DE01MOR
BF20.OLS.VSCP.FL01MOR
BF20.OLS.VSCP.GA01MOR
BF20.OLS.VSCP.GU01MOR
BF20.OLS.VSCP.HI01MOR
BF20.OLS.VSCP.IA01MOR
BF20.OLS.VSCP.ID01MOR
BF20.OLS.VSCP.KS01MOR
BF20.OLS.VSCP.KY01MOR
BF20.OLS.VSCP.LA01MOR
BF20.OLS.VSCP.MD01MOR
BF20.OLS.VSCP.ME01MOR
BF20.OLS.VSCP.MI01MOR
BF20.OLS.VSCP.MN01MOR
BF20.OLS.VSCP.MP01MOR
BF20.OLS.VSCP.MS01MOR
BF20.OLS.VSCP.MT01MOR
BF20.OLS.VSCP.NC01MOR
BF20.OLS.VSCP.ND01MOR
BF20.OLS.VSCP.NE01MOR
BF20.OLS.VSCP.NH01MOR
BF20.OLS.VSCP.NJ01MOR
BF20.OLS.VSCP.NM01MOR
BF20.OLS.VSCP.NV01MOR
BF20.OLS.VSCP.NY01MOR
BF20.OLS.VSCP.OH01MOR
BF20.OLS.VSCP.OK01MOR
BF20.OLS.VSCP.OR01MOR
BF20.OLS.VSCP.PA01MOR
BF20.OLS.VSCP.PR01MOR
BF20.OLS.VSCP.RI01MOR
BF20.OLS.VSCP.SC01MOR
BF20.OLS.VSCP.SD01MOR
BF20.OLS.VSCP.TN01MOR
BF20.OLS.VSCP.TX01MOR
BF20.OLS.VSCP.UT01MOR
BF20.OLS.VSCP.VA01MOR
BF20.OLS.VSCP.VT01MOR
BF20.OLS.VSCP.WA01MOR
BF20.OLS.VSCP.WI01MOR
BF20.OLS.VSCP.WV01MOR
BF20.OLS.VSCP.WY01MOR
BF20.OLS.VSCP.YC01MOR
BF20.OLS.VSCP.AK02MOR
BF20.OLS.VSCP.AL02MOR
BF20.OLS.VSCP.AR02MOR
BF20.OLS.VSCP.AS02MOR
BF20.OLS.VSCP.AZ02MOR
BF20.OLS.VSCP.CA02MOR
BF20.OLS.VSCP.CO02MOR
BF20.OLS.VSCP.CT02MOR
BF20.OLS.VSCP.DC02MOR
BF20.OLS.VSCP.DE02MOR
BF20.OLS.VSCP.FL02MOR
BF20.OLS.VSCP.GA02MOR
BF20.OLS.VSCP.GU02MOR
BF20.OLS.VSCP.HI02MOR
BF20.OLS.VSCP.IA02MOR
BF20.OLS.VSCP.ID02MOR
BF20.OLS.VSCP.KS02MOR
BF20.OLS.VSCP.KY02MOR
BF20.OLS.VSCP.LA02MOR
BF20.OLS.VSCP.MD02MOR
BF20.OLS.VSCP.ME02MOR
BF20.OLS.VSCP.MI02MOR
BF20.OLS.VSCP.MN02MOR
BF20.OLS.VSCP.MP02MOR
BF20.OLS.VSCP.MS02MOR
BF20.OLS.VSCP.MT02MOR
BF20.OLS.VSCP.NC02MOR
BF20.OLS.VSCP.ND02MOR
BF20.OLS.VSCP.NE02MOR
BF20.OLS.VSCP.NH02MOR
BF20.OLS.VSCP.NJ02MOR
BF20.OLS.VSCP.NM02MOR
BF20.OLS.VSCP.NV02MOR
BF20.OLS.VSCP.NY02MOR
BF20.OLS.VSCP.OH02MOR
BF20.OLS.VSCP.OK02MOR
BF20.OLS.VSCP.OR02MOR
BF20.OLS.VSCP.PA02MOR
BF20.OLS.VSCP.PR02MOR
BF20.OLS.VSCP.RI02MOR
BF20.OLS.VSCP.SC02MOR
BF20.OLS.VSCP.SD02MOR
BF20.OLS.VSCP.TN02MOR
BF20.OLS.VSCP.TX02MOR
BF20.OLS.VSCP.UT02MOR
BF20.OLS.VSCP.VA02MOR
BF20.OLS.VSCP.VT02MOR
BF20.OLS.VSCP.WA02MOR
BF20.OLS.VSCP.WI02MOR
BF20.OLS.VSCP.WV02MOR
BF20.OLS.VSCP.WY02MOR
BF20.OLS.VSCP.YC02MOR
  ;
run;
proc print; run;


 /* Part II, use the dataset to read each filename's data into tmp dataset. */
data tmp;
  set tmp;
  length currinfile $50;

 /* The INFILE statement closes the current file and opens a new one if
  * fn changes value when INFILE executes. FILEVAR must be same as var on the
  * ds that holds the filenames.
  */
  infile TMPIN FILEVAR=fn FILENAME=currinfile TRUNCOVER END=done; 

  do while ( not done );
    /* Read all input records from the currently opened input file, write to
     * work.tmp. 
     */
    input @11 st $CHAR2.  @14 yr $CHAR2.  @11 mergef $CHAR16.  
          @51 series $CHAR1.  @58 hirange $CHAR6.
          ;
    if series eq '1' and hirange ne: '9999' then 
      output;
  end;
run;

 /* Summary */
proc sql NOPRINT;
  create table final as
  select distinct yr as Year, st as State, hirange as HighestCertNo 
  from tmp
  group by yr, st
  having hirange=max(hirange)
  order by yr
  ;
quit;
%macro bobh;
 /* Detail */
proc sql NOPRINT;
  create table final as
  select st as State, yr as Year, mergef as File, hirange as HighestCertNo 
  from tmp
  group by yr, st
  having hirange=max(hirange)
  order by yr
  ;
quit;
%mend bobh;

%include 'BQH0.PGM.LIB(TABDELIM)';
proc print data=_LAST_ label; run;
%Tabdelim(work.final, 'BQH0.TMPTRAN1');
