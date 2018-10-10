CREATE TABLE tmpbobh (
  fooN  NUMBER,
  fooC  VARCHAR2(5),
  fooD  DATE
);

INSERT INTO tmpbobh (fooN,fooC,fooD) VALUES (66,'one','01-JAN-1960');
INSERT INTO tmpbobh (fooN,fooC,fooD) VALUES (67,'two','01-FEB-1960');
INSERT INTO tmpbobh (fooN,fooC,fooD) VALUES (68,'three','01-MAR-1960');

DROP TABLE tmpbobh;
