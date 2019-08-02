
-- Adapted: Tue, Jul 30, 2019  (Bob Heckel -- http://oracle-developer.net/display.php?id=301) 
-- see also member_of.plsql

CREATE OR REPLACE TYPE varchar2_ntt AS TABLE OF VARCHAR2(4000);

CREATE OR REPLACE PROCEDURE which_objects( which_types_in IN varchar2_ntt ) AS
	BEGIN
		 FOR r IN (SELECT object_name
							 FROM   user_objects
							 WHERE  object_type IN (SELECT column_value
                                        FROM   TABLE(which_types_in)))  -- collection is a pseudo-table
		 LOOP
				DBMS_OUTPUT.PUT_LINE(r.object_name);
		 END LOOP;
   END;

DECLARE
  nt_types varchar2_ntt := varchar2_ntt('TABLE','TYPE','PACKAGE');
BEGIN
  which_objects( which_types_in => nt_types );
END;

-- better but slower on large tables where it does a table scan
CREATE OR REPLACE PROCEDURE which_objects_10g( which_types_in IN varchar2_ntt ) AS
	BEGIN
		 FOR r IN (SELECT object_name
							 FROM   user_objects
							 WHERE  object_type MEMBER OF which_types_in)
		 LOOP
				DBMS_OUTPUT.PUT_LINE(r.object_name);
		END LOOP;
END;

DECLARE
  nt_types varchar2_ntt := varchar2_ntt('TABLE','TYPE','PACKAGE');
BEGIN
  which_objects_10g( which_types_in => nt_types );
END;
