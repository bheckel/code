options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: format.nested.sas
  *
  *  Summary: Demo of nesting SAS formats, both standard and user.
  *
  *  Adapted: Tue 31 Mar 2009 15:11:56 (Bob Heckel - SUGI 041-2008)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

proc format;
  value REGIS
    LOW - <'15Jul2005'd = 'Not Open'
    '15Jul2005'd - '31Dec2006'd = [MMDDYY10.]
    '01Jan2007'd - HIGH = 'Too Late'
    ;
run;


data conference;
  input @1 Name $10.  @11 Date MMDDYY10.;
  format Date REGIS.;
  datalines;
Smith     10/21/2005
Jones     06/13/2005
Harris    01/03/2007
Arnold    09/12/2005
  ;
run;
proc print data=_LAST_(obs=max); run;



endsas;
proc format;
  invalue yearexp
    1946 = 250
    1947 = 244
    1948 = 240
    1949 = 200
    1950 = 188
    1951 = 150
    1952 = 100
    ;

  invalue exp
    LOW -< 1946 = [7.1]
    1946 - 1952 = [yearexp.]
    1952 <- HIGH = [7.1]
    ;
run;

data benzene;
  infile 'c:\books\learning\benzene.txt';
  input ID Exposure : exp4.;
run;
