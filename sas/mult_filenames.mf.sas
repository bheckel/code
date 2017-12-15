options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: mult_filenames.mf.sas
  *
  *  Summary: Use aggregated filename statement
  *
  *  Created: Tue 24 Jun 2003 09:47:05 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

%include "&HOME/code/sas/connect_setup.sas";
signon cdcjes2;
rsubmit;


***filename F 'BF19.AKX0305.MORMER' DISP=SHR;
***filename F 'BF19.AKX0215.MORMER' DISP=SHR;
filename F ('BF19.AKX0219.MORMER','BF19.AKX0309.MORMER') DISP=SHR;
***filename F ('BF19.AKX0305.MORMER','BF19.AKX0215.MORMER', 'BF19.AKX0119.MORMER','BF19.AKX0021.MORMER1', 'BF19.AKX9915.MORMER1') DISP=SHR ;

data tmp;
  infile F;
  /* Same as qry001.sas */
  input @5 certno $CHAR6.  @47 alias 1.  @48 sex $CHAR1.
        @49 dmonth $CHAR2.  @51 dday $CHAR2.  @64 ageunit $CHAR1.
        @65 age $CHAR2.  @67 bmonth $CHAR2.  @69 bday $CHAR2.
        @74 stbirth $CHAR2.  @76 typlac $CHAR1.  @77 stocc $CHAR2.
        @82 marstat $CHAR1.  @89 stres $CHAR2.  @94 hisp $CHAR1.
        @95 race $CHAR1.  @96 educ $CHAR2.  @117 injury $CHAR1.
        @135 yr $CHAR4.  @135 dyear $CHAR4.  @139 byear $CHAR4.
        ;
  if dday in ("1","2","3","4","5");
run;

proc print data=tmp N; run;


endrsubmit;
signoff cdcjes2;
