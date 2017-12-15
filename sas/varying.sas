options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: varying.sas
  *
  *  Summary: Demo of using $VARYINGnn. to handle measured strings.
  *
  *           See also clearbytes.sas
  *
  *  Adapted: Wed 14 May 2003 13:34:02 (Bob Heckel -- Rick Aster Shortcuts p.
  *                                     84)
  * Modified: Mon 02 Jan 2006 16:03:58 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

%macro bobh; /* {{{ */
data work.measuredstring;
  /* The digit at datalines' col 6 specifies the width of the codename
   * variable. 
   */
  input abbrev $CHAR4.  
        namelen F2.  
        codename $VARYING32. namelen
        codenum F4.
        ;
  datalines;
FILE 4file1234
EDIT 4edit5678
FRMT 6format9012
  ;
run;
proc print; run;


 /* or */


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
  file 'DWJ2.FLMOR03R.USRES2' PAD LRECL=700 NEW;
  put @1 b1 $VARYING. lb1
      @7 dcno $CHAR6.
      @13 b2 $VARYING. lb2
      @217 fipcitycounty $CHAR8.
      @225 b3 $VARYING. lb3
      ;
run;
%mend bobh; /* }}} */



 /* Won't demo properly using CARDS */
data a;
  infile MYFILE length=linelen; 
  input firstvar 1-10 @;  /* assign LINELEN   */
  varlen=linelen-10;      /* Calculate VARLEN */
  input @11 secondvar $varying500. varlen;
run;
