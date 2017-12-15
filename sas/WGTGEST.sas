options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: WGTGEST.sas
  *
  *  Summary: Adhoc from Chrissy Jarman
  *           "I need to know the number of fetal deaths that meet the
  *           contract requirement - where the weight is greater than 349
  *           grams or gestational age (computed or estimated) is at least 20
  *           weeks (excludes records where all three fields are not stated)."
  *
  *  Created: Tue 01 Feb 2005 12:56:04 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter NOreplace mlogic mprint sgen;

%include 'BQH0.PGM.LIB(TABDELIM)';

libname L '/u/dwj2/mvds/FET/2003/';

data tmp (keep=certno state wgt_unit compgest);
  set 
      L.AKOLD
      L.ALOLD/*{{{*/
      L.AROLD
      L.ASOLD
      L.AZOLD
      L.CAOLD
      L.COOLD
      L.CTOLD
      L.DCOLD
      L.DEOLD
      L.FLOLD
      L.GAOLD
      L.GUOLD
      L.HIOLD
      L.IAOLD
      L.IDOLD
      L.ILOLD
      L.INOLD
      L.KSOLD
      L.KYOLD
      L.LAOLD
      L.MAOLD
      L.MDOLD
      L.MEOLD
      L.MIOLD
      L.MNOLD
      L.MOOLD
      L.MPOLD
      L.MSOLD
      L.MTOLD
      L.NCOLD
      L.NDOLD
      L.NEOLD
      L.NHOLD
      L.NJOLD
      L.NMOLD
      L.NVOLD
      L.NYOLD
      L.OHOLD
      L.OKOLD
      L.OROLD
      L.PAOLD
      L.PROLD
      L.RIOLD
      L.SCOLD
      L.SDOLD
      L.TNOLD
      L.TXOLD
      L.UTOLD
      L.VAOLD
      L.VIOLD
      L.VTOLD
      L.WAOLD
      L.WIOLD
      L.WVOLD
      L.WYOLD/*}}}*/
      L.YCOLD
      ;
run;

data tmp2;
  set tmp;
  length unit pound ounce pounce gram 8;

  if (wgt_unit eq '') and (compgest eq '' or compgest eq '99') then
    delete;

  unit=substr(wgt_unit,1,1);

  if unit eq 1 then
    gram=substr(wgt_unit,2,4);
  else if unit eq 2 then
    do;
      /* Skip garbage.  1 (i.e. true) if contains 0-9. */
      if (NOT verify(wgt_unit, '0123456789')) then
        do;
          pound=substr(wgt_unit,2,2);
          ounce=substr(wgt_unit,4,2);
          /*            __ oz in a lb */
          pounce=(pound*16)+ounce;
          /*          _______ grams in an ounce */
          gram=pounce*28.3495;
        end;
    end;
  else
    delete;
run;

data tmp3 (keep= certno state gram compgest);
  set tmp2;
  if (gram ge 349) or (compgest ge 20);
run;
proc print data=_LAST_(obs=max); run;

%Tabdelim(work.tmp3, 'BQH0.TMPTRAN2');


  /* vim: foldmethod=marker: */ 
