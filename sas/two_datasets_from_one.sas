
DATA admit06 admit07 ;
  SET ex.admissions ;
  IF YEAR(admdate) = 2006 THEN OUTPUT admit06;
  ELSE IF YEAR(admdate) = 2007 THEN OUTPUT admit07;
RUN;

PROC SQL ;
  CREATE TABLE admit06 AS
  SELECT * FROM ex.admissions
  WHERE YEAR(admdate) = 2006
  ;

  CREATE TABLE admit07 AS
  SELECT * FROM ex.admissions
  WHERE YEAR(admdate) = 2007
  ;
QUIT;
