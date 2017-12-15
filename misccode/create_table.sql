
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
