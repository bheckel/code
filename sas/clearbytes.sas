options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: clearbytes.sas
  *
  *  Summary: Blank out confidential data from mainframe file.
  *
  *  Created: Thu 24 Jun 2004 15:23:15 (Bob Heckel)
  * Modified: Tue 10 May 2005 11:28:23 (Bob Heckel -- adapt for 2004)
  *---------------------------------------------------------------------------
  */
options source NOcenter;


filename INF "DWJ2.FLMOR04O.USRES" DISP=SHR UNIT=NCHS LRECL=500 BLKSIZE=5000 
                                   RECFM=FB;
 /* Toggle BQH0/DWJ2 to debug */
filename OUTF "DWJ2.FLMOR04O.USRES" DISP=OLD UNIT=NCHS LRECL=500 BLKSIZE=5000
                                    RECFM=FB;

 /* Read in desired blocks, ignoring the sensitive ones per dwj2's list. */
data tmp;
  infile INF TRUNCOVER PAD;
  /* "For OLD, please remove blank following positions:"
   *  1-4 receipt date
   *  11-46 names
   *  55-53 ssn   <---55-63
   *  83-88 o&i
   *  101-116 fathers surname  <---98-116
   *  123-134 linking information
   *  164-165 FIPS linking information
   */

  /* We're reading in the parts we *want* not the parts we don't want. */
  input @5 t1 $CHAR6.  @47 t2 $CHAR8.  @64 t3 $CHAR19.  @89 t4 $CHAR9.
        @117 t5 $CHAR6.  @135 t6 $CHAR29.  @166 t7 $CHAR311.
        ;

  o1 = put(t1, $CHAR.);
  len1 = length(trim(o1));

  o2 = put(t2, $CHAR.);
  len2 = length(trim(o2));

  o3 = put(t3, $CHAR.);
  len3 = length(trim(o3));

  o4 = put(t4, $CHAR.);
  len4 = length(trim(o4));

  o5 = put(t5, $CHAR.);
  len5 = length(trim(o5));

  o6 = put(t6, $CHAR.);
  len6 = length(trim(o6));

  o7 = put(t7, $CHAR.);
  len7 = length(trim(o7));
run;

 /* Write out only the desired blocks */
data _NULL_;
  set tmp;
  file OUTF PAD;
  put @5 t1 $VARYING. len1  
      @47 t2 $VARYING. len2 
      @64 t3 $VARYING. len3 
      @89 t4 $VARYING. len4 
      @117 t5 $VARYING. len5 
      @135 t6 $VARYING. len6 
      @166 t7 $VARYING. len7 
      ;
run;
