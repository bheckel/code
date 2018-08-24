" Vim syntax file
" Language:	SAS v8
" Original Maintainer:	James Kidd <james.kidd@covance.com>
" Modified: Tue 24 Oct 2017 10:35:16 (Bob Heckel)
"
" 29-Jul-13 Windows gvim must have this file manually copied to c:\Program Files\Vim\vim73\syntax
"
" TODO ignore hilight inside quoted strings
"
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn case ignore

syn region sasString  start=+'+  skip=+\\\\\'+  end=+'\|;+
" When using %str, quotes can be 'marked' with a percent symbol which ruins
" the rest of the Log.
"""syn region sasWeirdString  start=+%str(%+ end=+;+

syn match sasNumber  "-\=\<\d*\.\=[0-9_]\>"

" Fix endless comment due to wildcard problem e.g. %if %sysfunc(fileexist("&path./&cl_foldername./ExternalFile/PE/*.csv")) %then %do;
" When using this:  syn region sasComment  start="/\*"  end="\*/" contains=sasTodo
syn region sasComment  start="^/\*"  end="\*/" contains=sasTodo
syn region sasComment  start="\s/\*"  end="\*/" contains=sasTodo

" Allow highlighting of embedded TODOs
syn match sasComment  "^\s*\*.*;" contains=sasTodo
" Allow highlighting of embedded TODOs
syn match sasComment  ";\s*\*.*;"hs=s+1 contains=sasTodo
" Macro comments
syn match sasComment  "^\s*%*\*.*;" contains=sasTodo
" JCL
syn match sasComment  "^\/\/.*\S" contains=sasTodo

" Macro calls can end optionally with ';'
syn region sasMacroCall  start="%\w\+" skip="[_%]" end=";\|$"he=e-1
" E.g. %str( )
syn region sasMacroCall  start="%\w\+" skip="[_%]" end=")\|$"
syn region sasMacroVar   start="&\+\w" skip="[_&]" end="\n\|\W"he=e-1
syn region sasMacroVar   start="&=\+\w" skip="[_&]" end="\n\|\W"he=e-1

syn match sasMacroBlock  "^\s*%MACRO\s\+" contains=sasEnd
syn match sasMacroBlock  "^\s*%MEND\s\?" contains=sasEnd

" Want region from 'cards;' to ';'
syn region sasCards  start="^\s*CARDS;" end=";\{1,}" contains=sasTodo
syn region sasCards  start="^\s*DATALINES.*;" end=";\{1,}" contains=sasTodo
" Don't want SAS Log to go 'blue', avoid by detecting line numbers in .log
syn region sasEnd  start="^endsas;" skip="." end="." contains=sasTodo
" My 'comment-out-this-region' indicator is %macro bobh1234; ... %mend bobh1234; ...
syn region sasEnd  start="%macro bobh\d*;" end="%mend bobh\d*" contains=sasTodo

"""syn region sasSteps    start="data"  end="run;" contains=sasSteps
syn match sasSteps  "^\s*DATA\s\+"
syn match sasSteps  "\s*PROC \w\+"
" Specific PROCs do not need to be listed if we use this line.
syn keyword sasSteps  RUN QUIT ENDDATA

"""syn match sasDatasetOpt  "[(\s]*COMPRESS="
syn match sasDatasetOpt  "\s\+COMPRESS="
syn match sasDatasetOpt  "\s\+DROP="
syn match sasDatasetOpt  "\s\+GENNUM="
syn match sasDatasetOpt  "\s\+KEEP="
syn match sasDatasetOpt  "\s\+IN="
syn match sasDatasetOpt  "\s\+INDEX="
syn match sasDatasetOpt  "\s\+LIBRARY="
syn match sasDatasetOpt  "\s\+NOBS="
syn match sasDatasetOpt  "\s*OBS="
syn match sasDatasetOpt  "\s\+RENAME="
syn match sasDatasetOpt  "\s\+WHERE="
syn match sasDatasetOpt  "\s*DATA="
syn match sasDatasetOpt  "\s*KEY="
"""syn match sasDatasetOpt  "\w\+SET"
syn match sasDatasetOpt  "\s*WIDTH="
"""syn match sasDatasetOpt  "\s*LRECL="
syn match sasDatasetOpt  "\s*FIRSTOBS="

syn match sasWild "\w\+:[^\\]\W"

syn match sasMisc  "\s\+FILENAME="
syn match sasMisc  "\s\+END="
syn keyword sasMisc  MISSOVER FLOWOVER TRUNCOVER DSD DLM NOOBS NODUP NODUPKEY NOEQUALS DUPOUT
syn keyword sasMisc  NOLIST DELIMITER LRECL FILEVAR OUTOBS NOTSORTED GROUPFORMAT

syn keyword sasConditional  DO TO ELSE END IF THEN UNTIL WHILE EQ: EQ EQT GT LT LE GE 
syn keyword sasConditional  NE: NE IN NOTIN OVER CASE WHEN SELECT OTHERWISE AND 
syn keyword sasConditional  OR BY

" TODO match only statements not followed by '.' or another word
" TODO won't work if put() comes on 1st col but that would be rare
syn match sasStatement  "[IN]*PUT\s"
syn match sasStatement  "TITLE\d\?"
syn match sasStatement  "FOOTNOTE\d\+"

syn keyword sasStatement  ABORT ARRAY ATTRIB AXIS1 AXIS2 CATNAME CLASS COLUMNS CONTAINS
syn keyword sasStatement  CONTINUE CNTLIN DATALINES DATALINES4 DELETE DISPLAY
syn keyword sasStatement  DECLARE DCL DEFINE DESC DESCENDING DM DROP FILE FILENAME 
syn keyword sasStatement  FOOTNOTE FORMAT GOTO INFILE INFORMAT INVALUE KEEP LABEL 
syn keyword sasStatement  LEAVE LENGTH LIBNAME LINK LIST LOSTCARD MERGE MISSING 
syn keyword sasStatement  MODIFY ODS OUTPUT PAGE PAGEBY PLOT PUT REDIRECT REMOVE 
syn keyword sasStatement  RENAME REPLACE RETAIN RETURN SET SKIP STARTSAS STOP SUMBY SYMGET UPDATE
syn keyword sasStatement  WAITSAS WEIGHT WINDOW

" User-defined macro calls use sasMacroCall instead of these
syn match sasMacro  "%BQUOTE"
syn match sasMacro  "%BY\s"
syn match sasMacro  "%CMPRES"
syn match sasMacro  "%COMPSTOR"
syn match sasMacro  "%DATATYP"
syn match sasMacro  "%DISPLAY"
syn match sasMacro  "%DO\s"
syn match sasMacro  "%DO;"
syn match sasMacro  "%ELSE"
syn match sasMacro  "%END"
syn match sasMacro  "%EVAL"
syn match sasMacro  "%GLOBAL"
syn match sasMacro  "%GOTO"
syn match sasMacro  "%IF\s"
syn match sasMacro  "%INCLUDE"
syn match sasMacro  "%INDEX"
syn match sasMacro  "%INPUT"
syn match sasMacro  "%KEYDEF"
syn match sasMacro  "%LABEL"
syn match sasMacro  "%LEFT"
syn match sasMacro  "%LENGTH"
syn match sasMacro  "%LET\s"
syn match sasMacro  "%LOCAL"
syn match sasMacro  "%LOWCASE"
syn match sasMacro  "%NRBQUOTE"
syn match sasMacro  "%NRQUOTE"
syn match sasMacro  "%NRSTR"
syn match sasMacro  "%PUT\s"
syn match sasMacro  "%PUT;"
syn match sasMacro  "%QCMPRES"
syn match sasMacro  "%QCMPRES"
syn match sasMacro  "%QLEFT"
syn match sasMacro  "%QLOWCASE"
syn match sasMacro  "%QSCAN"
syn match sasMacro  "%QSUBSTR"
syn match sasMacro  "%QSYSFUNC"
syn match sasMacro  "%QTRIM"
syn match sasMacro  "%QUOTE"
syn match sasMacro  "%QUPCASE"
syn match sasMacro  "%SCAN"
"""syn match   sasMacro	   "%STR()"
syn match sasMacro  "%SUBSTR"
syn match sasMacro  "%SUPERQ"
syn match sasMacro  "%SYMEXIST"
syn match sasMacro  "%SYMDEL"
syn match sasMacro  "%SYSCALL"
syn match sasMacro  "%SYSEVALF"
syn match sasMacro  "%SYSEXEC"
syn match sasMacro  "%SYSFUNC"
syn match sasMacro  "%SYSGET"
syn match sasMacro  "%SYSLPUT"
syn match sasMacro  "%SYSPROD"
syn match sasMacro  "%SYSRC"
syn match sasMacro  "%SYSRPUT"
syn match sasMacro  "%THEN"
syn match sasMacro  "%TO\s"
syn match sasMacro  "%TRIM"
syn match sasMacro  "%UNQUOTE"
syn match sasMacro  "%UNTIL"
syn match sasMacro  "%UNTIL\s"
syn match sasMacro  "%UPCASE"
syn match sasMacro  "%VERIFY"
syn match sasMacro  "%WHILE "
syn match sasMacro  "%WINDOW"

" TODO match only functions not followed by '('
syn match sasFunction  "\s*PUT("
syn match sasFunction  "\s*INPUT("
syn match sasFunction  "\s*INDEX("
syn keyword sasFunction  ABS ADDR AIRY ANYDIGIT ANYALPHA ANYPUNCT ANYSPACE ARCOS ARSIN ATAN ATTRC ATTRN
syn keyword sasFunction  BAND BETAINV BLSHIFT BNOT BOR BRSHIFT BXOR
syn keyword sasFunction  BYTE CALL CAT CATS CATT CATQ CATX CDF CEIL CEXIST CINV CLOSE 
syn keyword sasFunction  CNONCT COLLATE COMPBL COMPOUND COMPRESS COS COSH CSS CUROBS
syn keyword sasFunction  CV DACCDB DACCDBSL DACCSL DACCSYD DACCTAB
syn keyword sasFunction  DAIRY DATE DATEJUL DATEPART DATETIME DAY
syn keyword sasFunction  DCLOSE DEPDB DEPDBSL DEPDBSL DEPSL DEPSL
syn keyword sasFunction  DEPSYD DEPSYD DEPTAB DEPTAB DEQUOTE DHMS
syn keyword sasFunction  DIF DIGAMMA DIM DINFO DNUM DOPEN DOPTNAME
syn keyword sasFunction  DOPTNUM DOSUBL DREAD DROPNOTE DSNAME ERF ERFC EXIST EXECUTE
syn keyword sasFunction  EXP FAPPEND FCLOSE FCOL FDELETE FETCH FETCHOBS
syn keyword sasFunction  FEXIST FGET FILEEXIST FILENAME FILEREF FINFO
syn keyword sasFunction  FINV FIPNAME FIPNAMEL FIPSTATE FLOOR FNONCT
syn keyword sasFunction  FNOTE FOPEN FOPTNAME FOPTNUM FPOINT FPOS
syn keyword sasFunction  FPUT FREAD FREWIND FRLEN FSEP FUZZ FWRITE
syn keyword sasFunction  GAMINV GAMMA GETOPTION GETVARC GETVARN HBOUND
syn keyword sasFunction  HMS HOSTHELP HOUR IBESSEL INDEXC
syn keyword sasFunction  INDEXW INPUTC INPUTN INT INTCK INTNX
syn keyword sasFunction  INTRR IRR JBESSEL JULDATE KURTOSIS LAG LAG1 LAG2 LAG3 LAG4 LAG6 LARGEST
syn keyword sasFunction  LBOUND LEFT LENGTHN LGAMMA LIBNAME LIBREF LOG LOG10
syn keyword sasFunction  LOG2 LOGPDF LOGPMF LOGSDF LOWCASE MIN MAX MDY
syn keyword sasFunction  MEAN MIN MINUTE MOD MONOTONIC MONTH MOPEN MORT N
syn keyword sasFunction  NETPV NMISS NOTALPHA NOTDIGIT NOTNUM NORMAL NPV OPEN ORDINAL
syn keyword sasFunction  PATHNAME PDF PEEK PEEKC PMF POINT POISSON POKE
syn keyword sasFunction  PROBBETA PROBBNML PROBCHI PROBF PROBGAM
syn keyword sasFunction  PROBHYPR PROBIT PROBNEGB PROBNORM PROBT
syn keyword sasFunction  PRXCHANGE PRXPARSE PRXMATCH PRXFREE
syn keyword sasFunction  PUTC PUTN QTR QUOTE RANBIN RANCAU RANEXP
syn keyword sasFunction  RANGAM RANGE RANK RANNOR RANPOI RANTBL RANTRI
syn keyword sasFunction  RANUNI REPEAT RESOLVE REVERSE REWIND RIGHT
syn keyword sasFunction  ROUND SAVING SCAN SDF SIGN SIN SINH SORT SORTN SORTC STRIP
syn keyword sasFunction  SKEWNESS SMALLEST SOUNDEX SPEDIS SQRT STD STDERR STFIPS
syn keyword sasFunction  STNAME STNAMEL SUBSTR SUM SYMPUT SYMGET SYSGET 
syn keyword sasFunction  SYSMSG SYSPROD SYSRC SYSTEM TAN TANH TIME TIMEPART
syn keyword sasFunction  TINV TNONCT TODAY TRANSLATE TRANWRD TRIGAMMA
syn keyword sasFunction  TRIM TRIMN TRUNC UNIFORM UPCASE USS VAR
syn keyword sasFunction  VARFMT VARINFMT VARLABEL VARLEN VARNAME
syn keyword sasFunction  VARNUM VARRAY VARRAYX VARTYPE VERIFY VFORMAT
syn keyword sasFunction  VFORMATD VFORMATDX VFORMATN VFORMATNX VFORMATW
syn keyword sasFunction  VFORMATWX VFORMATX VINARRAY VINARRAYX VINFORMAT
syn keyword sasFunction  VINFORMATD VINFORMATDX VINFORMATN VINFORMATNX
syn keyword sasFunction  VINFORMATW VINFORMATWX VINFORMATX VLABEL
syn keyword sasFunction  VLABELX VLENGTH VLENGTHX VNAME VNAMEX VTYPE VTYPEX 
syn keyword sasFunction  WEEKDAY WHICHN WHICHC YEAR YYQ ZIPFIPS ZIPNAME ZIPNAMEL ZIPSTATE 

syn keyword sasSQL  ALTER AS AVG CASCADE COALESCE COALESCEC DELETE DESCRIBE DISTINCT DROP
syn keyword sasSQL  FOREIGN FROM HAVING INSERT INTO IN JOIN LIKE MIN MAX MODIFY
syn keyword sasSQL  MSGTYPE NOT NULL ON PRIMARY REFERENCES RESTRICT THRU
syn keyword sasSQL  UPDATE VIEW WHERE
syn match sasSQL  "INNER JOIN"
syn match sasSQL  "LEFT JOIN"
syn match sasSQL  "GROUP BY"
syn match sasSQL  "CREATE TABLE"
syn match sasSQL  "ORDER BY"
syn match sasSQL  "INDEX CREATE"

" Always contained in a comment
syn keyword sasTodo  TODO TBD FIXME DEBUG contained 

syn match sasUnderscore  "\s*_NULL_"
syn match sasUnderscore  "\s*_NUMERIC_"
syn match sasUnderscore  "\s*-NUMERIC-"
syn match sasUnderscore  "\s*_CHARACTER_"
syn match sasUnderscore  "\s*-CHARACTER-"
syn match sasUnderscore  "\s*_ALL_"
syn match sasUnderscore  "\s*_IORC_"
syn match sasUnderscore  "\s*_DSENOM"
syn match sasUnderscore  "\s*_SOK"
syn match sasUnderscore  "\s*_LOCAL_"
syn match sasUnderscore  "\s*_GLOBAL_"
syn match sasUnderscore  "\s*_USER_"
syn match sasUnderscore  "\s*_WEBOUT"
syn match sasUnderscore  "\s*_TEMPORARY_"
syn match sasUnderscore  "\s*_INFILE_"
syn match sasUnderscore  "_N_"
syn match sasUnderscore  "\s*_ERROR_"
syn match sasUnderscore  "\s*_ODS_"
syn match sasUnderscore  "\s_ROW_"
syn match sasUnderscore  "\sfirst\."
syn match sasUnderscore  "\slast\."
syn match sasUnderscore  "\s_LAST_"
syn match sasUnderscore  "_LAST_"
syn match sasUnderscore  "_BLANKPAGE_"
syn match sasUnderscore  "_I_"
syn match sasUnderscore  "_PAGE_"
syn match sasUnderscore  "_TYPE_"
syn match sasUnderscore  "_FREQ_"
syn match sasUnderscore  "_SAME_"
" SAS Special Missing Values (not an underscore but no better place to put this)
syn match sasUnderscore  "\.[a-z];"

" See saslog.vim
"""syn match sasLogmsgOK  "NOTE:"
"""syn match sasLogmsgMAYBE  "WARNING:"
"""syn match sasLogmsgRED  "ERROR:"

" Emphasize important msgs in Log
syn match sasBang  "^!!!.*"

syn match sasInpMod  "&$\d\+\."      " ampersand input modifier
syn match sasInpMod  "&COMMA\."      " ampersand input modifier
syn match sasInpMod  "&$CHAR\d\+\."  " ampersand input modifier
syn match sasInpMod  ":$\d\+\."      " colon input modifier
syn match sasInpMod  ":COMMA\."      " colon input modifier
syn match sasInpMod  ":$CHAR\d\+\."  " colon input modifier
syn match sasInpMod  ":DATE\."       " colon input modifier (:DATE9. etc is an error)
syn match sasInpMod  "@\+;"          " actually linehold but good enough for now

" For use in  RUN CANCEL;  statements.
syn match sasErrMsg  "cancel;"

" goptions for SAS Graph
syn region sasOption  start="g\?options " end=";"

syn match sasSemi  ";"

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_sas_syntax_inits")
   if version < 508
      let did_sas_syntax_inits = 1
      command -nargs=+ HiLink hi link <args>
   else
      command -nargs=+ HiLink hi def link <args>
   endif

   hi sasBang        ctermfg=LightYellow guifg=LightYellow cterm=bold gui=bold
   hi sasCards	     ctermfg=DarkGray  guifg=Gray
   hi sasDatasetOpt  ctermfg=Yellow guifg=Yellow
   hi sasEnd	       ctermfg=DarkGray guifg=DarkGray
   hi sasErrMsg      ctermfg=Yellow ctermbg=Red cterm=bold gui=bold 
   hi sasFunction    ctermfg=LightYellow guifg=LightYellow
   hi sasInpMod      ctermfg=LightCyan guifg=LightCyan cterm=bold gui=bold
"""   hi sasLogmsgMAYBE ctermfg=Yellow guifg=Yellow cterm=bold gui=bold
"""   hi sasLogmsgOK    ctermfg=Green guifg=Green cterm=bold gui=bold
"""   hi sasLogmsgRED   ctermfg=Red guifg=Red cterm=bold gui=bold
   hi sasMacroBlock  ctermfg=Magenta guifg=Magenta cterm=bold gui=bold 
   hi sasMacroCall   ctermfg=161 guifg=Red cterm=bold gui=bold 
   hi sasMacroVar    ctermfg=LightCyan guifg=LightCyan cterm=bold gui=bold 
   hi sasMisc        ctermfg=Blue guifg=Blue
   hi sasNoteLine    ctermfg=DarkGreen guifg=Green
   hi sasOption      ctermfg=Brown guifg=Brown
   hi sasSelect	     ctermfg=DarkBlue guifg=DarkBlue cterm=bold gui=bold 
   hi sasSemi        ctermfg=White guifg=White cterm=bold gui=bold
   hi sasStatement   ctermfg=LightCyan guifg=LightCyan
   hi sasSteps       ctermfg=LightYellow guifg=LightYellow cterm=bold gui=bold 
   hi sasSymbolg     ctermfg=LightBlue guifg=LightBlue
   hi sasUnderscore  ctermfg=Green guifg=Green cterm=bold gui=bold
   hi sasWild        ctermfg=Red guifg=Red
   hi sasComment ctermbg=Black ctermfg=DarkGray guifg=DarkGray guibg=Black

   " Defaults via .vimrc:
   " HiLink sasComment     Comment
   HiLink sasConditional Conditional
   HiLink sasMacro       PreProc
   HiLink sasNumber      Number
   HiLink sasSQL         Conditional
   HiLink sasString      String
   HiLink sasTodo        Todo
  delcommand HiLink
endif

" Handle comments, etc. located partially off-screen when Vim starts 
syn sync minlines=150

let b:current_syntax="sas"


" vim: ts=8
