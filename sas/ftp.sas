options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: ftp.sas
  *
  *  Summary: Demo of using SAS's internal FTP feature so that a remote file 
  *           doesn't have to first be copied to the local machine to be read.
  *
  *  Adapted: Fri 24 Oct 2003 14:40:09 (Bob Heckel --
  *                       http://www.ats.ucla.edu/stat/sas/faq/readftp.htm)
  *---------------------------------------------------------------------------
  */
options source;

filename IN FTP 'test.dat' 
            LRECL=80 
            CD='/home/bqh0' 
            HOST='daeb'
            USER='kjk4'
            PASS='dAebrpt5'
            ;
data foo;
  infile IN;
  input gpa hsm hss hse satm satv gender;
run;
 
proc print data=foo (obs= 10);
run;

endsas;
5.32     10     10     10     670     600       1
5.14      9      9     10     630     700       2
3.84      9      6      6     610     390       1
5.34     10      9      9     570     530       2
4.26      6      8      5     700     640       1
4.35      8      6      8     640     530       1
5.33      9      7      9     630     560       2
4.85     10      8      8     610     460       2
4.76     10     10     10     570     570       2
5.72      7      8      7     550     500       1

