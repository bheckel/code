//BQH0EFGH JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=1,CLASS=F,REGION=0M
//STEP1    EXEC SAS90,TIME=100,OPTIONS='MEMSIZE=0,ALTPRINT=OLST,
//                                                ALTLOG=OLOG'
//OLST     DD DISP=SHR,DSN=BQH0.INC.SASLIST WAIT=10
//OLOG     DD DISP=SHR,DSN=BQH0.INC.SASLOG WAIT=10
//WORK     DD SPACE=(CYL,(100,100),,,ROUND)
//SYSIN    DD *

libname B 'BQH0.SASLIB' DISP=OLD;

libname NEWTEMP 'bqh0.TEMPLATE.LIB' DISP=SHR;

ODS NOPTITLE;
ODS PATH SASHELP.TMPLMST (READ) NEWTEMP.TEMPLAT (READ);

ODS ESCAPECHAR='¬';
ODS PDF FILE='/u/bqh0/public_html/bob/junk.pdf' STYLE=STYLES.TEST1 NOTOC;


proc report data=b.allcnt;
  column y rec_count;
  define y          / 'Year' order STYLE={CELLWIDTH=75PT JUST=left};
  define rec_count  / 'Record Count' F=comma8.;
run;

ODS PDF CLOSE;
