-- oracle
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



use sandbox
CREATE TABLE #vapharm (
 claim_id VARCHAR(100),
 pharmacy VARCHAR(12)
)

INSERT #table VALUES ('some id num', 'abba')



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
