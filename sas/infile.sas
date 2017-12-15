options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: infile.sas 
  *
  *  Summary: Read from several input textfiles.
  *
  *           On the mainframe, using JCL is sometimes easier:
  *
  * //BQH0M03 JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=2,CLASS=D,REGION=0M
  * /*ROUTE    PRINT R341
  * //PRINT OUTPUT FORMDEF=A10111,PAGEDEF=V06683,CHARS=D225,COPIES=1
  * //ANNUAL  EXEC SAS,TIME=100,OPTIONS='MEMSIZE=0'
  * //SASLIST DD SYSOUT=0,OUTPUT=*.PRINT,RECFM=FBA,LRECL=136,BLKSIZE=136
  * //IN      DD DISP=SHR,DSN=BF19.ID01.ID03011A.MORCRE.R414P001
  * //        DD DISP=SHR,DSN=BF19.ID01.ID03012A.MORCRE.R414P002
  * //        DD DISP=SHR,DSN=BF19.ID01.ID03021A.MORCRE.R414P003
  * //LAYOUT  DD DISP=SHR,DSN=BQH0.PGM.LIB(MOR2003X)
  * //WORK DD SPACE=(CYL,(100,100),,,ROUND)
  * //SYSIN     DD *
  *
  *           See also loop_filenames_in_ds.sas for another complex demo
  *
  *           Apparently a * wildcard can be used in INFILE statement.
  *
  *  Adapted: Thu 29 May 2003 12:22:42 (Bob Heckel --
  *                   file:///C:/bookshelf_sas/lgref/z0146932.htm#z0177201)
  * Modified: Mon 21 Jun 2010 09:43:48 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data tmp;
  infile 'BF19.NVX0422.NATMER' obs=10;
  input @1 foo $CHAR1.;
run;


data foo;
  /* Start reading the 10th line of data */
  infile 'BF19.NVX0422.NATMER' firstobs=10;
  input @1 foo $CHAR1.;
run;


 /* Simple, single filename: */
***filename F 'BF19.AKX0215.MORMER' DISP=SHR;
 /* Concatenated, multiple hardcoded filenames: */
filename F ('BF19.AKX0305.MORMER','BF19.AKX0215.MORMER',
            'BF19.AKX0119.MORMER','BF19.AKX0021.MORMER1',
            'BF19.AKX9915.MORMER1') DISP=SHR
           ;

data tmp;
  infile F;
  input @5 certno $CHAR6.  @47 alias 1.  @48 sex $1.
        @49 dmonth $CHAR2.  @51 dday $CHAR2.  @64 ageunit $CHAR1.
        @65 age $CHAR2.  @67 bmonth $CHAR2.  @69 bday $CHAR2.
        @74 stbirth $2.  @76 typlac $1.  @77 stocc $CHAR2.
        @82 marstat $1.  @89 stres $CHAR2.  @94 hisp $CHAR1.
        @95 race $1.  @96 educ $2.  @117 injury $CHAR1.
        @135 yr $4.  @135 dyear $CHAR4.  @139 byear $CHAR4.
        ;
run;
proc print data=tmp (obs= 10); run;



 /* Complex but dynamic (filenames come from a dataset) */
 /* Part I, build the dataset. */
data tmp;
  infile cards;
  input @1 fn $CHAR9.;
  put "!!! " _INFILE_;
  cards;
junk1.txt
junk2.txt
  ;
run;

 /* Part II, use the dataset to read all the files. */
data tmp;
  set tmp;
  length currentinfile $50;

 /* The INFILE statement closes the current file and opens a new one if
  * fn changes value when INFILE executes. FILEVAR must be same as var on the
  * ds that holds the filenames.
  */
  infile TMPBOBH FILEVAR=fn FILENAME=currentinfile TRUNCOVER END=done; 

  do while ( not done );
    /* Read all input records from the currently opened input file, write to
     * work.tmp. 
     */
    input @1 block $CHAR80.;
    output;
  end;
  put '!!!finished reading ' currentinfile=; 
run;
proc print; run;


endsas;


The set of options explained below are used on the INFILE statement:

DELIMITER= (DLM=) - This option allows you to tell SAS what character is used
as a delimiter in a file. If this option is not specified, SAS assumes the
delimiter is a space. Some common delimiters are comma, vertical pipe,
semi-colon, and asterisk. The syntax for the option would be as follows:

DLM=',|;*'

where char is equal to the character used as the delimiter in the text file.
Since there is no key available for the tab character, you need to use the
hexadecimal representation for tab. On ASCII based platforms, this is defined
as '09'x, and the representation is '05'x on EBCDIC platforms. The syntax
would be as follows:

DLM='09'x

DSD - It has three functions when reading delimited files. The first function
is to strip off any quotes that surround values in the text file. The second
function deals with missing values. When SAS encounters consecutive delimiters
in a file, the default action is to treat the delimiters as one unit. If a
file has consecutive delimiters, it's usually because there are missing
values between them. DSD tells SAS to treat consecutive delimiters separately;
therefore, a value that is missing between consecutive delimiters will be read
as a missing value when DSD is specified. The third function assumes the
delimiter is a comma. If DSD is specified and the delimiter is a comma, the
DLM= option is not necessary. If another delimiter is used, the DLM= option
must be used as well.

LRECL= - This option should be used when the length of the records in a file
are greater than 256 bytes (on ASCII platforms). The input buffer is 256 bytes
by default, and records that are greater than this length will be truncated
when they are read. Setting the LRECL= option to a greater length assures that
the input buffer is long enough to read the whole record.

FIRSTOBS= - This option indicates that you want to start reading the input
file at the record number specified, rather than beginning with the first
record. This option is helpful when reading files that contain a header
record, since a user can specify FIRSTOBS=2 and skip the header record
entirely. 

PAD - Avoid problems when reading variable length records that contain fixed-field
data.  Pads each record with blanks so each line ends up as the same length.
