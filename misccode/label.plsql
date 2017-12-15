
<<outer>>
DECLARE
   birthdate DATE;
BEGIN
   DECLARE
      birthdate DATE;
   BEGIN
      ...
      IF birthdate = outer.birthdate THEN ...
   END;
   ...
END;
