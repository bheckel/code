-- Create a pl/sql function that returns an Oracle collection type

select * from hr.employees where rownum<5;

CREATE OR REPLACE TYPE lnm_ty IS OBJECT(last_name varchar2(30)); 

CREATE OR REPLACE TYPE lnm_tbl_ty IS TABLE OF lnm_ty; 

CREATE OR REPLACE FUNCTION q_lnm(employee_id NUMBER) RETURN lnm_tbl_ty
   IS
     CURSOR cur(c_employee_id NUMBER)
       IS
         SELECT  last_name
           FROM  hr.employees
          WHERE  employee_id = c_employee_id
          ;
		 ty             lnm_ty;
		 tbl            lnm_tbl_ty := lnm_tbl_ty();
   BEGIN
      FOR rec IN cur (employee_id) LOOP
         ty := lnm_ty(rec.last_name);
         tbl.EXTEND;
         tbl(tbl.LAST) := ty;
      END LOOP;

      RETURN tbl;
   END;

create or replace view myv as SELECT * FROM TABLE(Q_lnm(100));

create or replace view myv2 as SELECT * FROM TABLE(Q_lnm(101));

select * from myv2
