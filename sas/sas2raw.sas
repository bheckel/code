options NOsource;
 /*---------------------------------------------------------------------------
  *     Name:
  *
  *  Summary:
  *
  *  Created:
  *---------------------------------------------------------------------------
  */
options source NOcenter;


 /* sas2raw.sas
*
* Convert a SAS data set to a RAW or flat text file.  Include 
* SAS statements on the flat file as documentation.
*/

* LIB  LIBREF OF THE DATA BASE (data base name) e.g. BENTHIC;
*      This argument can be used to control the path.
* MEM  NAME OF DATA SET AND RAW FILE (member name) 
*      e.g. FULLBEN;
* The raw file will have the same name as the data set.
*;
%MACRO SAS2RAW(lib, mem);

* The libref for incoming data is &lib ;
libname &lib   "d:\training\sas\&lib";
* New text file written to the fileref ddout;
filename ddout "d:\junk\&mem..raw ";

*  DETERMINE LENGTHS AND FORMATS OF THE VARIABLES;
PROC CONTENTS DATA=&lib..&mem 
              OUT=A1 NOPRINT;
   RUN;

PROC SORT DATA=A1; BY NPOS;
   RUN;

* MANY NUMERIC VARIABLES DO NOT HAVE FORMATS AND THE RAW FILE;
* WILL BE TOO WIDE IF WE JUST USE A LENGTH OF 8;
* Count the number of numeric variables;
DATA _NULL_; SET A1 END=EOF;
   IF TYPE=1 THEN NNUM + 1;
   IF EOF THEN CALL SYMPUT('NNUM',LEFT(PUT(NNUM,3.)));
   RUN;


%if &nnum > 0 %then %do;
* DETERMINE HOW MANY DIGITS ARE NEEDED FOR EACH NUMERIC VARIABLE;
* D STORES THE MAXIMUM NUMBER OF DIGITS NEEDED FOR EACH;
DATA M2; SET &lib..&mem (KEEP=_NUMERIC_) END=EOF;
ARRAY _D  DIGIT1 - DIGIT&NNUM;
ARRAY _N  NUMERIC_;
KEEP DIGIT1 - DIGIT&NNUM;
RETAIN DIGIT1 - DIGIT&NNUM;
IF _N_ = 1 THEN  DO OVER _D; _D=1; END;
DO OVER _D;
     _NUMBER = _N;
     _D1 = LENGTH(LEFT(PUT(_NUMBER,BEST16.)));
     _D2 = _D;
      * NUMBER OF DIGITS NEEDED;
     _D = MAX(_D1, _D2);
END;
IF EOF THEN OUTPUT;
RUN;
%end;


*** THIS SECTION DOES NOT WRITE DATA, ONLY THE PUT STATEMENT;
* MAKE THE PUT STATEMENT AND SET IT ASIDE.;
* It will serve as documentation as well as the PUT statement;
DATA _NULL_; SET A1 END=EOF;
RETAIN _TOT 0 _COL 1;
FILE DDOUT NOPRINT lrecl=250;
IF _N_ = 1 THEN DO;
     %if &nnum > 0 %then SET M2;;
     TOT = NPOS;
END;
%if &nnum > 0 %then %do;
ARRAY _D (NNUM) DIGIT1 - DIGIT&NNUM; 
* TYPE=1 FOR NUMERIC VARS;
IF TYPE=1 THEN DO;
     NNUM + 1;
     DIGIT = _D;
     * TAKE THE FORMATTED LENGTH INTO CONSIDERATION;
     LENGTH = MAX(FORMATL, FORMATD, DIGIT);
END;
%end;
TOT = _TOT + LENGTH + 1;
CHAR = '               ';
* SPECIAL HANDLING IS REQUIRED WHEN FORMATS ARE USED.
* CHAR IS USED TO STORE THE FORMAT;
IF FORMAT ^= ' ' | FORMATL>0 | FORMATD >0 THEN DO;
    * BUILD THE FORMAT FOR THIS VARIABLE;
    CHAR = TRIM(FORMAT);
    IF FORMATL>0 THEN CHAR=TRIM(CHAR)||TRIM(LEFT(PUT(FORMATL,3.)));
    CHAR= TRIM(CHAR)||'.';
    IF FORMATD>0 THEN CHAR=TRIM(CHAR)||TRIM(LEFT(PUT(FORMATD,3.)));
END;
IF TYPE = 2 & FORMAT = ' ' THEN CHAR = '$';
* _COL IS THE STARTING COLUMN;
IF _N_ = 1 THEN _COL = 1;
IF _N_ = 1 THEN PUT '/* *** */ PUT	@' _COL NAME CHAR;
ELSE            PUT '/* *** */    @' _COL NAME CHAR;
COL = _COL + LENGTH + 1;
IF EOF THEN DO;
     PUT '/* *** */ ;' ;
     CALL SYMPUT('LRECL',_TOT);
END;
RUN;

* Write out the flat file using the PUT statement in DDOUT;
DATA _NULL_; SET &dsn..&mem;
FILE DDOUT NOPRINT MOD lrecl=250; 
%INCLUDE DDOUT; 
run;
%MEND sas2raw;

****************************************************;

 %SAS2RAW(sasclass,ca88air)    run; 
**********************;
