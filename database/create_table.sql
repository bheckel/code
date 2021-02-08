-----------------------------------
-- Modified: 04-Feb-2021 (Bob Heckel)
-----------------------------------

create table bob (
  OPPORTUNITY_OPT_OUT_ID     NUMBER,
  H_VERSION                  NUMBER default 0,
  actual_updated             TIMESTAMP(6)
);

INSERT INTO bob VALUES (11, 1, sysdate);commit;
ALTER TABLE bob ADD newcol NUMBER default -99;  -- Oracle goes back and populates the records already existing with -99
INSERT INTO bob (OPPORTUNITY_OPT_OUT_ID/*, h_version*/, actual_updated) VALUES (44, /*1,*/ sysdate);commit;
INSERT INTO bob (OPPORTUNITY_OPT_OUT_ID, h_version, actual_updated, newcol) VALUES (54, 1, sysdate, 1000);commit;

SELECT * FROM bob;

---

--DROP TABLE emp PURGE;

CREATE TABLE emp (
  empno    NUMBER(4) CONSTRAINT pk_emp PRIMARY KEY,
  ename    VARCHAR2(10),
  job      VARCHAR2(9),
  mgr      NUMBER(4),
  hiredate DATE,
  sal      NUMBER(7,2),
  comm     NUMBER(7,2),
  deptno   NUMBER(2)
);

INSERT INTO emp VALUES (7369,'SMITH','CLERK',7902,to_date('17-12-1980','dd-mm-yyyy'),800,NULL,20);
INSERT INTO emp VALUES (7499,'ALLEN','SALESMAN',7698,to_date('20-2-1981','dd-mm-yyyy'),1600,300,30);
INSERT INTO emp VALUES (7521,'WARD','SALESMAN',7698,to_date('22-2-1981','dd-mm-yyyy'),1250,500,30);
INSERT INTO emp VALUES (7566,'JONES','MANAGER',7839,to_date('2-4-1981','dd-mm-yyyy'),2975,NULL,20);
INSERT INTO emp VALUES (7654,'MARTIN','SALESMAN',7698,to_date('28-9-1981','dd-mm-yyyy'),1250,1400,30);
INSERT INTO emp VALUES (7698,'BLAKE','MANAGER',7839,to_date('1-5-1981','dd-mm-yyyy'),2850,NULL,30);
INSERT INTO emp VALUES (7782,'CLARK','MANAGER',7839,to_date('9-6-1981','dd-mm-yyyy'),2450,NULL,10);
INSERT INTO emp VALUES (7788,'SCOTT','ANALYST',7566,to_date('13-JUL-87','dd-mm-rr')-85,3000,NULL,20);
INSERT INTO emp VALUES (7839,'KING','PRESIDENT',NULL,to_date('17-11-1981','dd-mm-yyyy'),5000,NULL,10);
INSERT INTO emp VALUES (7844,'TURNER','SALESMAN',7698,to_date('8-9-1981','dd-mm-yyyy'),1500,0,30);
INSERT INTO emp VALUES (7876,'ADAMS','CLERK',7788,to_date('13-JUL-87', 'dd-mm-rr')-51,1100,NULL,20);
INSERT INTO emp VALUES (7900,'JAMES','CLERK',7698,to_date('3-12-1981','dd-mm-yyyy'),950,NULL,30);
INSERT INTO emp VALUES (7902,'FORD','ANALYST',7566,to_date('3-12-1981','dd-mm-yyyy'),3000,NULL,20);
INSERT INTO emp VALUES (7934,'MILLER','CLERK',7782,to_date('23-1-1982','dd-mm-yyyy'),1300,NULL,10);
COMMIT;

---

CREATE TABLE target (pk number, data varchar2(10));
CREATE TABLE source (pk_s number, data_s varchar2(10));
INSERT INTO target VALUES (1, 'a');
INSERT INTO target VALUES (3, 'c');
INSERT INTO source VALUES (1, 'a');
INSERT INTO source VALUES (2, 'b');
INSERT INTO source VALUES (3, 'c');
INSERT INTO source VALUES (4, 'd');
COMMIT;

---

-- Oracle
CREATE TABLE TMPCUSTOMERS( 
   ID   INT NOT NULL, 
   NAME VARCHAR (20) NOT NULL, 
   AGE INT NOT NULL, 
   ADDRESS CHAR (25), 
   SALARY   DECIMAL (18, 2),        
   PRIMARY KEY (ID) 
);  

INSERT INTO TMPCUSTOMERS (ID,NAME,AGE,ADDRESS,SALARY) 
VALUES (1, 'Ramesh', 32, 'Ahmedabad', 2000.00 );  

INSERT INTO TMPCUSTOMERS (ID,NAME,AGE,ADDRESS,SALARY) 
VALUES (2, 'Khilan', 25, 'Delhi', 1500.00 );  

INSERT INTO TMPCUSTOMERS (ID,NAME,AGE,ADDRESS,SALARY) 
VALUES (3, 'kaushik', 23, 'Kota', 2000.00 );
  
INSERT INTO TMPCUSTOMERS (ID,NAME,AGE,ADDRESS,SALARY) 
VALUES (4, 'Chaitali', 25, 'Mumbai', 6500.00 ); 
 
INSERT INTO TMPCUSTOMERS (ID,NAME,AGE,ADDRESS,SALARY) 
VALUES (5, 'Hardik', 27, 'Bhopal', 8500.00 );  

INSERT INTO TMPCUSTOMERS (ID,NAME,AGE,ADDRESS,SALARY) 
VALUES (6, 'Komal', 22, 'MP', 4500.00 ); 

---

-- Oracle
create sequence UID_OPPORTUNITY_OPT_OUT
minvalue 1000
maxvalue 999999999999999999999999999
start with 1001
increment by 1
cache 5;

-- Create table
create table OPPORTUNITY_OPT_OUT
(
  OPPORTUNITY_OPT_OUT_ID     NUMBER,
  OPPORTUNITY_ID             NUMBER,
  POOR_CLOSEOUT_OPT_OUT      NUMBER,
  POOR_CLOSEOUT_EMAIL_1_SENT DATE, 
  POOR_CLOSEOUT_REASON       VARCHAR2(255),
  PTG_INVOICED_OPT_OUT       NUMBER,
  CREATED                    DATE,
  CREATEDBY                  NUMBER,
  UPDATED                    DATE,
  UPDATEDBY                  NUMBER,
  H_VERSION                  NUMBER default 0,
  actual_updated             TIMESTAMP(6),
  actual_updatedby           NUMBER,
  retired_time               TIMESTAMP(6),
  audit_source               VARCHAR2(255)
)
tablespace ES_01
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
alter table OPPORTUNITY_OPT_OUT
  add constraint OPPORTUNITY_OPT_OUT_PK primary key (OPPORTUNITY_OPT_OUT_ID)
  using index 
  tablespace ES_01
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create unique index OPPORTUNITY_OPT_OUT_OPP_ID_IX on OPPORTUNITY_OPT_OUT (OPPORTUNITY_ID)
  tablespace ES_01
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
create index OPPORTUNITY_OPT_OUT_POOR_IX1 on OPPORTUNITY_OPT_OUT (POOR_CLOSEOUT_OPT_OUT)
  tablespace ES_01
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Create/Recreate check constraints 
alter table OPPORTUNITY_OPT_OUT
  add constraint NN_OPPOPTOUT_CREATEDBY_01
  check ("CREATEDBY" IS NOT NULL);
alter table OPPORTUNITY_OPT_OUT
  add constraint NN_OPPOPTOUT_CREATED_02
  check ("CREATED" IS NOT NULL);
alter table OPPORTUNITY_OPT_OUT
  add constraint NN_OPPOPTOUT_UPDATED_03
  check ("UPDATED" IS NOT NULL);
alter table OPPORTUNITY_OPT_OUT
  add constraint NN_OPPOPTOUT_UPDATEDBY_04
  check ("UPDATEDBY" IS NOT NULL);
alter table OPPORTUNITY_OPT_OUT
  add constraint NN_OPPOPTOUT_HVERSION_05
  check ("H_VERSION" IS NOT NULL);
alter table OPPORTUNITY_OPT_OUT
  add constraint NN_OPPOPTOUT_OPPID_06
  check ("OPPORTUNITY_ID" IS NOT NULL);

-- Grant/Revoke object privileges 
grant select on OPPORTUNITY_OPT_OUT to SEKMC;

---

-- postgres
CREATE TABLE priorityprogram.uhcclients
(
  uhcclientsid serial NOT NULL,
  clientid integer,
  planyear date NOT NULL DEFAULT date_part('year',current_date),
  deactivated boolean NOT NULL DEFAULT FALSE,
  cap integer NOT NULL DEFAULT 9999999,
  created timestamp without time zone NOT NULL DEFAULT now(),
  lastmodified timestamp without time zone NOT NULL DEFAULT now(),
  lastmodifiedby text NOT NULL DEFAULT "current_user"()
);



CREATE TABLE public.enrollchgdashboard
(
  enrollchgdashboardid serial NOT NULL,
  clientid integer NOT NULL,
  clientstoreid text,
  eligible integer,
  enrolled integer,
  optout integer,
  unenrolled integer,
  eligchange integer,
  enrollchange integer,
  optoutchange integer,
  unenrollchange integer,
  healthplanid integer,
  measurementdate date,
  lastmodified timestamp without time zone NOT NULL DEFAULT now(),
  lastuser character varying(32) NOT NULL DEFAULT "current_user"(),

  CONSTRAINT pk_enroll PRIMARY KEY (enrollchgdashboardid)
);
GRANT ALL ON TABLE public.enrollchgdashboard TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.enrollchgdashboard TO analytics_group;
GRANT ALL ON TABLE public.enrollchgdashboard TO etl_group;
COMMENT ON TABLE public.enrollchgdashboard
  IS 'Daily enrollment data for Dashboards';

---

use sandbox
CREATE TABLE #vapharm (
 claim_id VARCHAR(100),
 pharmacy VARCHAR(12)
)

INSERT #table VALUES ('some id num', 'abba')

---

drop table mailing_list;

create table mailing_list (
       id   varchar(100) NOT NULL primary key,
       name varchar(100)
);

create table phone_numbers (
       id           varchar(100) NOT NULL references mailing_list(id),
       number_type  varchar(15) check (number_type in ('work','home','cell','beeper')),
       phone_number varchar(20) NOT NULL
);

---

CREATE TABLE employees
    ( employee_id    NUMBER(6)
    , first_name     VARCHAR2(20)
    , last_name      VARCHAR2(25) CONSTRAINT emp_last_name_nn  NOT NULL
    , email          VARCHAR2(25) CONSTRAINT emp_email_nn  NOT NULL
    , phone_number   VARCHAR2(20)
    , hire_date      DATE CONSTRAINT emp_hire_date_nn  NOT NULL
    , job_id         VARCHAR2(10) CONSTRAINT emp_job_nn  NOT NULL
    , salary         NUMBER(8,2)
    , commission_pct NUMBER(2,2)
    , manager_id     NUMBER(6)
    , department_id  NUMBER(4)
    , CONSTRAINT     emp_salary_min CHECK (salary > 0) 
    , CONSTRAINT     emp_email_uk UNIQUE (email)
    ) ;

CREATE UNIQUE INDEX emp_emp_id_pk
ON employees (employee_id) ;


/* ALTER TABLE employees */
/* ADD ( CONSTRAINT     emp_emp_id_pk */
/*                      PRIMARY KEY (employee_id) */
/*     , CONSTRAINT     emp_dept_fk */
/*                      FOREIGN KEY (department_id) */
/*                       REFERENCES departments */
/*     , CONSTRAINT     emp_job_fk */
/*                      FOREIGN KEY (job_id) */
/*                       REFERENCES jobs (job_id) */
/*     , CONSTRAINT     emp_manager_fk */
/*                      FOREIGN KEY (manager_id) */
/*                       REFERENCES employees */
/*     ) ; */

INSERT INTO employees VALUES 
        ( 100
        , 'Steven'
        , 'King'
        , 'SKING'
        , '515.123.4567'
        , TO_DATE('17-JUN-1987', 'dd-MON-yyyy')
        , 'AD_PRES'
        , 24000
        , NULL
        , NULL
        , 90
        );

INSERT INTO employees VALUES 
        ( 101
        , 'Neena'
        , 'Kochhar'
        , 'NKOCHHAR'
        , '515.123.4568'
        , TO_DATE('21-SEP-1989', 'dd-MON-yyyy')
        , 'AD_VP'
        , 17000
        , NULL
        , 100
        , 90
        );

INSERT INTO employees VALUES 
        ( 102
        , 'Lex'
        , 'De Haan'
        , 'LDEHAAN'
        , '515.123.4569'
        , TO_DATE('13-JAN-1993', 'dd-MON-yyyy')
        , 'AD_VP'
        , 17000
        , NULL
        , 100
        , 90
        );

INSERT INTO employees VALUES 
        ( 103
        , 'Alexander'
        , 'Hunold'
        , 'AHUNOLD'
        , '590.423.4567'
        , TO_DATE('03-JAN-1990', 'dd-MON-yyyy')
        , 'IT_PROG'
        , 9000
        , NULL
        , 102
        , 60
        );

INSERT INTO employees VALUES 
        ( 108
        , 'Nancy'
        , 'Greenberg'
        , 'NGREENBE'
        , '515.124.4569'
        , TO_DATE('17-AUG-1994', 'dd-MON-yyyy')
        , 'FI_MGR'
        , 12000
        , NULL
        , 101
        , 100
        );

INSERT INTO employees VALUES 
        ( 109
        , 'Daniel'
        , 'Faviet'
        , 'DFAVIET'
        , '515.124.4169'
        , TO_DATE('16-AUG-1994', 'dd-MON-yyyy')
        , 'FI_ACCOUNT'
        , 9000
        , NULL
        , 108
        , 100
        );

INSERT INTO employees VALUES 
        ( 110
        , 'John'
        , 'Chen'
        , 'JCHEN'
        , '515.124.4269'
        , TO_DATE('28-SEP-1997', 'dd-MON-yyyy')
        , 'FI_ACCOUNT'
        , 8200
        , NULL
        , 108
        , 100
        );

INSERT INTO employees VALUES 
        ( 111
        , 'Ismael'
        , 'Sciarra'
        , 'ISCIARRA'
        , '515.124.4369'
        , TO_DATE('30-SEP-1997', 'dd-MON-yyyy')
        , 'FI_ACCOUNT'
        , 7700
        , NULL
        , 108
        , 100
        );

INSERT INTO employees VALUES 
        ( 112
        , 'Jose Manuel'
        , 'Urman'
        , 'JMURMAN'
        , '515.124.4469'
        , TO_DATE('07-MAR-1998', 'dd-MON-yyyy')
        , 'FI_ACCOUNT'
        , 7800
        , NULL
        , 108
        , 100
        );

INSERT INTO employees VALUES 
        ( 123
        , 'Shanta'
        , 'Vollman'
        , 'SVOLLMAN'
        , '650.123.4234'
        , TO_DATE('10-OCT-1997', 'dd-MON-yyyy')
        , 'ST_MAN'
        , 6500
        , NULL
        , 100
        , 50
        );

INSERT INTO employees VALUES 
        ( 124
        , 'Kevin'
        , 'Mourgos'
        , 'KMOURGOS'
        , '650.123.5234'
        , TO_DATE('16-NOV-1999', 'dd-MON-yyyy')
        , 'ST_MAN'
        , 5800
        , NULL
        , 100
        , 50
        );

INSERT INTO employees VALUES 
        ( 185
        , 'Alexis'
        , 'Bull'
        , 'ABULL'
        , '650.509.2876'
        , TO_DATE('20-FEB-1997', 'dd-MON-yyyy')
        , 'SH_CLERK'
        , 4100
        , NULL
        , 121
        , 50
        );

INSERT INTO employees VALUES 
        ( 186
        , 'Julia'
        , 'Dellinger'
        , 'JDELLING'
        , '650.509.3876'
        , TO_DATE('24-JUN-1998', 'dd-MON-yyyy')
        , 'SH_CLERK'
        , 3400
        , NULL
        , 121
        , 50
        );
