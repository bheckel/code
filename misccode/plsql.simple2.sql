CREATE TABLE tmpbobh (
  fooN1  NUMBER,
  fooC1  VARCHAR2(5)
);

INSERT INTO tmpbobh (fooN1,fooC1) VALUES (66,'one');
INSERT INTO tmpbobh (fooN1,fooC1) VALUES (67,'two');
INSERT INTO tmpbobh (fooN1,fooC1) VALUES (68,'three');

-- drop table tmpbobh;


CREATE OR REPLACE FUNCTION charat(str IN VARCHAR2, pos IN NUMBER)
  RETURN VARCHAR2 
  IS
  BEGIN
    RETURN SUBSTR(str, pos, 1);
  END charat
;
/


SELECT fooC1, charat(fooC1, 2) x
FROM tmpbobh
;
