ROLLBACK;
BEGIN;
-- BUILD STATUS

CREATE TABLE aar.tmmtgtbuildstatus
(
  tmmtgtbuildstatusid serial NOT NULL,
  name text NOT NULL,
  CONSTRAINT pk_tmmtgtbuildstatus PRIMARY KEY (tmmtgtbuildstatusid),
  CONSTRAINT uq_tmmtgtbuildstatus UNIQUE (name)
)
WITH (
  OIDS=FALSE
);
GRANT ALL ON TABLE aar.tmmtgtbuildstatus TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE aar.tmmtgtbuildstatus TO analytics_group;
GRANT ALL ON TABLE aar.tmmtgtbuildstatus TO etl_group;
COMMENT ON TABLE aar.tmmtgtbuildstatus
  IS 'Build Status';
-- Table: aar.tmmtgtbuildschedule

-- DROP TABLE aar.tmmtgtbuildschedule;

CREATE TABLE aar.tmmtgtbuildschedule
(
  tmmtgtbuildscheduleid serial NOT NULL,
  name text NOT NULL,
  CONSTRAINT pk_tmmtgtbuildschedule PRIMARY KEY (tmmtgtbuildscheduleid),
  CONSTRAINT uq_tmmtgtbuildschedule UNIQUE (name)
)
WITH (
  OIDS=FALSE
);
GRANT ALL ON TABLE aar.tmmtgtbuildschedule TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE aar.tmmtgtbuildschedule TO analytics_group;
GRANT ALL ON TABLE aar.tmmtgtbuildschedule TO etl_group;
COMMENT ON TABLE aar.tmmtgtbuildschedule
  IS 'Schedules used for scheduling builds';


-- Table: aar.tmmtgtbuildtype

-- DROP TABLE aar.tmmtgtbuildtype;

CREATE TABLE aar.tmmtgtbuildtype
(
  tmmtgtbuildtypeid serial NOT NULL,
  name text NOT NULL,
  CONSTRAINT pk_tmmtgtbuildtype PRIMARY KEY (tmmtgtbuildtypeid),
  CONSTRAINT uq_tmmtgtbuildtype UNIQUE (name)
)
WITH (
  OIDS=FALSE
);
GRANT ALL ON TABLE aar.tmmtgtbuildtype TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE aar.tmmtgtbuildtype TO analytics_group;
GRANT ALL ON TABLE aar.tmmtgtbuildtype TO etl_group;
COMMENT ON TABLE aar.tmmtgtbuildtype
  IS 'Types of builds';


-- Table: aar.archivetmmtgtbuildconfig

-- DROP TABLE aar.archivetmmtgtbuildconfig;

CREATE TABLE aar.archivetmmtgtbuildconfig
(
  archivetmmtgtbuildconfigid serial NOT NULL,
  tgop text NOT NULL,
  tmmtgtbuildconfigid integer,
  tmmtgtbuildtypeid integer,
  clientid integer,
  tmmtgtbuildscheduleid integer,
  datamonthsback integer,
  mindrugs integer,
  usecap boolean,
  numcap integer,
  removeinvalidpatients boolean,
  minage integer,
  importdelay integer,
  lastbuild timestamp without time zone,
  created timestamp without time zone NOT NULL DEFAULT now(),
  createdby text NOT NULL DEFAULT "current_user"(),
  lastmodified timestamp without time zone NOT NULL DEFAULT now(),
  lastmodifiedby text NOT NULL DEFAULT "current_user"(),
  rundatacheck boolean NOT NULL DEFAULT true,
  useatebpatientid boolean NOT NULL DEFAULT true,
  nrx text,
  job_type text NOT NULL DEFAULT 'Imports'::text,
  CONSTRAINT pk_archivetmmtgtbuildconfig PRIMARY KEY (archivetmmtgtbuildconfigid)
)
WITH (
  OIDS=FALSE
);
GRANT ALL ON TABLE aar.archivetmmtgtbuildconfig TO analytics_group;
GRANT ALL ON TABLE aar.archivetmmtgtbuildconfig TO etl_group;
COMMENT ON TABLE aar.archivetmmtgtbuildconfig
  IS 'The archive of default configuration for builds';


-- Table: aar.tmmtgtbuildconfig

-- DROP TABLE aar.tmmtgtbuildconfig;

CREATE TABLE aar.tmmtgtbuildconfig
(
  tmmtgtbuildconfigid serial NOT NULL,
  tmmtgtbuildtypeid integer NOT NULL,
  clientid integer NOT NULL,
  tmmtgtbuildscheduleid integer NOT NULL DEFAULT 1,
  datamonthsback integer NOT NULL, -- The months back data should be considered
  mindrugs integer NOT NULL,
  usecap boolean NOT NULL, -- Whether or not the cap on number of patients should be applied
  numcap integer NOT NULL,
  removeinvalidpatients boolean NOT NULL, -- Whether to remove enrolled, unenrolled, and opted out patients
  minage integer NOT NULL, -- The minimum age for a patient
  importdelay integer NOT NULL,
  lastbuild timestamp without time zone,
  created timestamp without time zone NOT NULL DEFAULT now(),
  createdby text NOT NULL DEFAULT "current_user"(),
  lastmodified timestamp without time zone NOT NULL DEFAULT now(),
  lastmodifiedby text NOT NULL DEFAULT "current_user"(),
  rundatacheck boolean NOT NULL DEFAULT true,
  useatebpatientid boolean NOT NULL DEFAULT true,
  nrx text,
  job_type text NOT NULL,
  CONSTRAINT pk_tmmtgtbuildconfig PRIMARY KEY (tmmtgtbuildconfigid),
  CONSTRAINT fk_tmmtgtbuildconfig_tmmtgtbuildscheduleid FOREIGN KEY (tmmtgtbuildscheduleid)
      REFERENCES aar.tmmtgtbuildschedule (tmmtgtbuildscheduleid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_tmmtgtbuildconfig_tmmtgtbuildtypeid FOREIGN KEY (tmmtgtbuildtypeid)
      REFERENCES aar.tmmtgtbuildtype (tmmtgtbuildtypeid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_tmmtgtbuildconfig_clientid FOREIGN KEY (clientid)
      REFERENCES analytics.tmmclient (clientid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT uq_tmmtgtbuildconfig_tmmtgtbuildtypeid_clientid UNIQUE (tmmtgtbuildtypeid, clientid)
)
WITH (
  OIDS=FALSE
);
GRANT ALL ON TABLE aar.tmmtgtbuildconfig TO analytics_group;
GRANT ALL ON TABLE aar.tmmtgtbuildconfig TO etl_group;
COMMENT ON TABLE aar.tmmtgtbuildconfig
  IS 'The default configuration for builds';
COMMENT ON COLUMN aar.tmmtgtbuildconfig.datamonthsback IS 'The months back data should be considered';
COMMENT ON COLUMN aar.tmmtgtbuildconfig.usecap IS 'Whether or not the cap on number of patients should be applied';
COMMENT ON COLUMN aar.tmmtgtbuildconfig.removeinvalidpatients IS 'Whether to remove enrolled, unenrolled, and opted out patients';
COMMENT ON COLUMN aar.tmmtgtbuildconfig.minage IS 'The minimum age for a patient';


-- Trigger: tr_tmmtgtbuildconfig_archive on aar.tmmtgtbuildconfig

-- DROP TRIGGER tr_tmmtgtbuildconfig_archive ON aar.tmmtgtbuildconfig;

CREATE TRIGGER tr_tmmtgtbuildconfig_archive
  AFTER INSERT OR UPDATE OR DELETE
  ON aar.tmmtgtbuildconfig
  FOR EACH ROW
  EXECUTE PROCEDURE public.tgoparchivetrigger();

-- Trigger: tr_tmmtgtbuildconfig_update_created_by_lm_by on aar.tmmtgtbuildconfig

-- DROP TRIGGER tr_tmmtgtbuildconfig_update_created_by_lm_by ON aar.tmmtgtbuildconfig;

CREATE TRIGGER tr_tmmtgtbuildconfig_update_created_by_lm_by
  BEFORE INSERT OR UPDATE
  ON aar.tmmtgtbuildconfig
  FOR EACH ROW
  EXECUTE PROCEDURE public.update_created_by_lm_by();

-- Table: aar.archivetmmtgtbuild

-- DROP TABLE aar.archivetmmtgtbuild;

CREATE TABLE aar.archivetmmtgtbuild
(
  archivetmmtgtbuildid serial NOT NULL,
  tgop text NOT NULL,
  tmmtgtbuildid integer,
  tmmtgtbuildtypeid integer,
  clientid integer,
  builddate date,
  datamonthsback integer,
  mindrugs integer,
  usecap boolean,
  numcap integer,
  removeinvalidpatients boolean,
  minage integer,
  importdelay integer,
  projectedimport date,
  importpath text,
  note text,
  tmmtgtbuildstatusid integer,
  created timestamp without time zone NOT NULL DEFAULT now(),
  createdby text NOT NULL DEFAULT "current_user"(),
  lastmodified timestamp without time zone NOT NULL DEFAULT now(),
  lastmodifiedby text NOT NULL DEFAULT "current_user"(),
  rundatacheck boolean NOT NULL DEFAULT true,
  useatebpatientid boolean DEFAULT true,
  nrx text,
  job_type text DEFAULT 'Imports'::text,
  CONSTRAINT pk_archivetmmtgtbuild PRIMARY KEY (archivetmmtgtbuildid)
)
WITH (
  OIDS=FALSE
);
GRANT ALL ON TABLE aar.archivetmmtgtbuild TO analytics_group;
GRANT ALL ON TABLE aar.archivetmmtgtbuild TO etl_group;
COMMENT ON TABLE aar.archivetmmtgtbuild
  IS 'A table that archives analytics builds.  See the parent table at aar.tmmtgtbuild';

-- Table: aar.tmmtgtbuild

-- DROP TABLE aar.tmmtgtbuild;

CREATE TABLE aar.tmmtgtbuild
(
  tmmtgtbuildid serial NOT NULL,
  tmmtgtbuildtypeid integer NOT NULL, -- The type of build
  clientid integer NOT NULL, -- The client for whom the build should be processed
  builddate date NOT NULL,
  datamonthsback integer NOT NULL, -- The months back data should be considered
  mindrugs integer NOT NULL,
  usecap boolean NOT NULL, -- Whether or not the cap on number of patients should be applied
  numcap integer NOT NULL,
  removeinvalidpatients boolean NOT NULL, -- Whether to remove enrolled, unenrolled, and opted out patients.  This removal happens prior to import
  minage integer NOT NULL, -- The minimum age for a patient to be included
  importdelay integer NOT NULL, -- The number of days for which an import should wait
  projectedimport date,
  importpath text,
  note text,
  tmmtgtbuildstatusid integer NOT NULL DEFAULT 0, -- The build status:...
  created timestamp without time zone NOT NULL DEFAULT now(),
  createdby text NOT NULL DEFAULT "current_user"(),
  lastmodified timestamp without time zone NOT NULL DEFAULT now(),
  lastmodifiedby text NOT NULL DEFAULT "current_user"(),
  rundatacheck boolean NOT NULL DEFAULT true,
  useatebpatientid boolean DEFAULT true,
  nrx text,
  job_type text,
  CONSTRAINT pk_tmmtgtbuild PRIMARY KEY (tmmtgtbuildid),
  CONSTRAINT fk_tmmtgtbuild_tmmtgtbuildstatusid FOREIGN KEY (tmmtgtbuildstatusid)
      REFERENCES aar.tmmtgtbuildstatus (tmmtgtbuildstatusid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_tmmtgtbuild_tmmtgtbuildtypeid FOREIGN KEY (tmmtgtbuildtypeid)
      REFERENCES aar.tmmtgtbuildtype (tmmtgtbuildtypeid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_tmmtgtbuild_tmmtgtbuildtypeid_clientid FOREIGN KEY (tmmtgtbuildtypeid, clientid)
      REFERENCES aar.tmmtgtbuildconfig (tmmtgtbuildtypeid, clientid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT fk_tmmtgtbuild_clientid FOREIGN KEY (clientid)
      REFERENCES analytics.tmmclient (clientid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT uq_tmmtgtbuild_tmmtgtbuildtypeid_clientid UNIQUE (tmmtgtbuildtypeid, clientid)
)
WITH (
  OIDS=FALSE
);
GRANT ALL ON TABLE aar.tmmtgtbuild TO analytics_group;
GRANT ALL ON TABLE aar.tmmtgtbuild TO etl_group;
COMMENT ON TABLE aar.tmmtgtbuild
  IS 'A table for analytics builds';
COMMENT ON COLUMN aar.tmmtgtbuild.tmmtgtbuildtypeid IS 'The type of build';
COMMENT ON COLUMN aar.tmmtgtbuild.clientid IS 'The client for whom the build should be processed';
COMMENT ON COLUMN aar.tmmtgtbuild.datamonthsback IS 'The months back data should be considered';
COMMENT ON COLUMN aar.tmmtgtbuild.usecap IS 'Whether or not the cap on number of patients should be applied';
COMMENT ON COLUMN aar.tmmtgtbuild.removeinvalidpatients IS 'Whether to remove enrolled, unenrolled, and opted out patients.  This removal happens prior to import';
COMMENT ON COLUMN aar.tmmtgtbuild.minage IS 'The minimum age for a patient to be included';
COMMENT ON COLUMN aar.tmmtgtbuild.importdelay IS 'The number of days for which an import should wait';
COMMENT ON COLUMN aar.tmmtgtbuild.tmmtgtbuildstatusid IS 'The build status:

0 = NEW
1 = STARTED
2 = COMPLETE
3 = IMPORTED';


-- Trigger: tr_tmmtgtbuild_archive on aar.tmmtgtbuild

-- DROP TRIGGER tr_tmmtgtbuild_archive ON aar.tmmtgtbuild;

CREATE TRIGGER tr_tmmtgtbuild_archive
  AFTER INSERT OR UPDATE OR DELETE
  ON aar.tmmtgtbuild
  FOR EACH ROW
  EXECUTE PROCEDURE public.tgoparchivetrigger();

-- Trigger: tr_tmmtgtbuild_update_created_by_lm_by on aar.tmmtgtbuild

-- DROP TRIGGER tr_tmmtgtbuild_update_created_by_lm_by ON aar.tmmtgtbuild;

CREATE TRIGGER tr_tmmtgtbuild_update_created_by_lm_by
  BEFORE INSERT OR UPDATE
  ON aar.tmmtgtbuild
  FOR EACH ROW
  EXECUTE PROCEDURE public.update_created_by_lm_by();





------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-- stored proc
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION aar.tmmtgt_build_get(_clientid integer DEFAULT null)
  RETURNS SETOF aar.tmmtgtbuild AS
$BODY$
BEGIN

-- buildtypeid = 1

-- returns the builds that are available to run (buildstatusid = 0)

RETURN QUERY
SELECT *
FROM aar.tmmtgtbuild
WHERE (clientid = _clientid OR _clientid is null)
AND tmmtgtbuildtypeid = 1
AND tmmtgtbuildstatusid = 0
AND builddate <= current_date
;

END;
$BODY$
LANGUAGE PLPGSQL VOLATILE;

GRANT EXECUTE ON FUNCTION aar.tmmtgt_build_get(integer) TO postgres, analytics_group;
REVOKE ALL ON FUNCTION aar.tmmtgt_build_get(integer) FROM public;


CREATE OR REPLACE FUNCTION aar.tmmtgt_build_import_get(_clientid integer DEFAULT null)
  RETURNS SETOF aar.tmmtgtbuild AS
$BODY$
BEGIN

-- buildtypeid = 1

-- returns the import data, so long as things look good! (buildstatusid = 2)
RETURN QUERY
SELECT *
FROM aar.tmmtgtbuild
where (clientid = _clientid OR _clientid is null)
AND tmmtgtbuildtypeid = 1
AND tmmtgtbuildstatusid = 2
AND builddate <= current_date
AND builddate + importdelay <= current_date
AND importpath IS NOT NULL
;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;

GRANT EXECUTE ON FUNCTION aar.tmmtgt_build_import_get(integer) TO postgres;
GRANT EXECUTE ON FUNCTION aar.tmmtgt_build_import_get(integer) TO analytics_group;
REVOKE ALL ON FUNCTION aar.tmmtgt_build_import_get(integer) FROM public;


CREATE OR REPLACE FUNCTION aar.tmmtgt_build_import_set(
    _clientid integer,
    _importpath text)
  RETURNS SETOF aar.tmmtgtbuild AS
$BODY$
BEGIN

-- buildtypeid = 1

-- sets the import and determines the projected import date

-- at present, importdelay is an integer that we add to current_date...
-- future state will probably have logic associated with it somehow...

RETURN QUERY
UPDATE aar.tmmtgtbuild b
SET importpath = _importpath, projectedimport = current_date + importdelay
	, note = 'Ready for import'
WHERE b.clientid = _clientid
AND b.tmmtgtbuildtypeid = 1
RETURNING b.*
;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;

GRANT EXECUTE ON FUNCTION aar.tmmtgt_build_import_set(integer, text) TO postgres;
GRANT EXECUTE ON FUNCTION aar.tmmtgt_build_import_set(integer, text) TO analytics_group;
REVOKE ALL ON FUNCTION aar.tmmtgt_build_import_set(integer, text) FROM public;



CREATE OR REPLACE FUNCTION aar.tmmtgt_build_schedule_future(_clientid integer)
  RETURNS SETOF aar.tmmtgtbuild AS
$BODY$
DECLARE _rec record;
        _lastbuild date := null;
        _newbuild date := null;
BEGIN

-- uses buildtypeid = 1
SELECT *
FROM aar.tmmtgtbuildconfig
where clientid = _clientid and tmmtgtbuildtypeid = 1
INTO _rec;


_lastbuild := coalesce(_lastbuild,_rec.lastbuild,current_date);


IF _rec.tmmtgtbuildscheduleid = 1 THEN
        -- incremental 30
        _newbuild := _lastbuild::date + 30;
ELSIF _rec.tmmtgtbuildscheduleid = 2 THEN
        -- 10th of following month
        _newbuild := date_trunc('month',(_lastbuild + '1 month'::interval))::date+9;
ELSIF _rec.tmmtgtbuildscheduleid = 3 THEN
        -- incremental 90
        _newbuild := _lastbuild::date + 90;
ELSE
        RAISE EXCEPTION 'Unrecognized buildscheduleid: %',_rec.tmmtgtbuildscheduleid;
END IF;

-- schedule build
RETURN QUERY
SELECT *
FROM aar.tmmtgt_client_build_schedule(_clientid := _clientid, _builddate := _newbuild)
;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  COST 100
  ROWS 1000;

GRANT EXECUTE ON FUNCTION aar.tmmtgt_build_schedule_future(integer) TO analytics_group;
REVOKE ALL ON FUNCTION aar.tmmtgt_build_schedule_future(integer) FROM public;


CREATE OR REPLACE FUNCTION aar.tmmtgt_build_update(
    _clientid integer,
    _buildstatusid integer,
    _note text DEFAULT NULL::text)
  RETURNS SETOF aar.tmmtgtbuild AS
$BODY$
BEGIN

-- buildtypeid = 1

-- updates the aar.tmmtgtbuild record specified
-- * Also stores information in aar.tmmtgtbuildconfig if statusid is 2
RETURN QUERY
WITH thebuild as (
UPDATE aar.tmmtgtbuild b
SET tmmtgtbuildstatusid = _buildstatusid
	, note = coalesce(_note,b.note) -- preserve existing note if none was provided...
WHERE b.clientid = _clientid
 AND b.tmmtgtbuildtypeid = 1
RETURNING b.*
)
, lastbuild as (
UPDATE aar.tmmtgtbuildconfig bc
SET lastbuild = builddate
FROM thebuild b
where b.tmmtgtbuildtypeid = bc.tmmtgtbuildtypeid
and b.clientid = bc.clientid
and b.tmmtgtbuildstatusid = 2 -- only update when buildstatusid = 2
returning bc.*
)
SELECT * from thebuild;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;

GRANT EXECUTE ON FUNCTION aar.tmmtgt_build_update(integer, integer, text) TO postgres;
GRANT EXECUTE ON FUNCTION aar.tmmtgt_build_update(integer, integer, text) TO analytics_group;
GRANT EXECUTE ON FUNCTION aar.tmmtgt_build_update(integer,integer,text) TO implementation_group;
REVOKE ALL ON FUNCTION aar.tmmtgt_build_update(integer, integer, text) FROM public;


CREATE OR REPLACE FUNCTION aar.tmmtgt_client_build_config(
    _clientid integer,
    _importdelay integer DEFAULT 0,
    _buildscheduleid integer DEFAULT 1,
    _datamonthsback integer DEFAULT 6,
    _mindrugs integer DEFAULT 3,
    _usecap boolean DEFAULT true,
    _numcap integer DEFAULT 500,
    _removeinvalidpatients boolean DEFAULT true,
    _minage integer DEFAULT 18,
    _rundatacheck boolean DEFAULT false,
    _useatebpatientid boolean DEFAULT true,
    _nrx text DEFAULT NULL::text,
    _job_type text DEFAULT 'Imports'::text)
  RETURNS SETOF aar.tmmtgtbuildconfig AS
$BODY$
DECLARE outputrec record;
  _clientgroup text;
BEGIN

-- uses buildtypeid = 1

-- check that client exists
IF NOT EXISTS (select clientid from analytics.vtmmclient where clientid = _clientid) THEN
  RAISE EXCEPTION 'Client does not exist in analytics.vtmmclient.  Please ensure that analytics.tmm_client_new() is run first';
END IF;

IF NOT EXISTS (select campaigngroupid from analytics.vtmmclient where clientid = _clientid) THEN
  RAISE EXCEPTION 'Campaign Group ID does not exist in analytics.vtmmclient.  Please ensure that analytics.tmm_client_new() is run first';
END IF;

-- For Large Chains, Set ImportDelay = 5
SELECT clientgroup FROM analytics.vtmmclient where clientid = _clientid INTO _clientgroup;
IF _clientgroup = 'Chain' THEN 
  _importdelay := 5;
END IF;

-- if client already exists, update parameters
IF EXISTS (select clientid from aar.tmmtgtbuildconfig where clientid = _clientid and tmmtgtbuildtypeid = 1) THEN
  RAISE INFO 'Client already exists!  Setting default parameters to those that were provided';

  UPDATE aar.tmmtgtbuildconfig bc
  SET importdelay=_importdelay
    , tmmtgtbuildscheduleid=_buildscheduleid
    , datamonthsback=_datamonthsback
    , mindrugs=_mindrugs
    , usecap=_usecap
    , numcap=_numcap
    , removeinvalidpatients=_removeinvalidpatients
    , minage=_minage
    , rundatacheck=_rundatacheck
    , useatebpatientid=_useatebpatientid
    , nrx=_nrx
    , job_type=_job_type
  WHERE clientid = _clientid and tmmtgtbuildtypeid = 1
  RETURNING bc.* INTO outputrec
  ;

ELSE
  -- NEW build!  Insert record
  INSERT INTO aar.tmmtgtbuildconfig (tmmtgtbuildtypeid, clientid, importdelay, tmmtgtbuildscheduleid, datamonthsback, mindrugs, usecap, numcap
	, removeinvalidpatients, minage, rundatacheck, useatebpatientid, nrx, job_type)
  VALUES (1,_clientid, _importdelay, _buildscheduleid, _datamonthsback, _mindrugs, _usecap, _numcap, _removeinvalidpatients, _minage, _rundatacheck, _useatebpatientid, _nrx, _job_type)
  RETURNING * INTO outputrec
  ;

  PERFORM aar.tmmtgt_client_build_schedule(
    _clientid
    , current_date
    , _importdelay
    , _datamonthsback
    , _mindrugs
    , _usecap
    , _numcap
    , _removeinvalidpatients
    , _minage
    , true
    , _useatebpatientid
    , _nrx
    , _job_type
  );
END IF;

RETURN NEXT outputrec;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;


GRANT ALL ON FUNCTION aar.tmmtgt_client_build_config(integer, integer,integer, integer, integer, boolean, integer, boolean, integer, boolean, boolean, text, text) TO analytics_group, etl_group;
GRANT EXECUTE ON FUNCTION aar.tmmtgt_client_build_config(integer, integer, integer, integer, integer, boolean, integer, boolean, integer, boolean, boolean, text, text) TO 
implementation_group;
REVOKE ALL ON FUNCTION aar.tmmtgt_client_build_config(integer, integer, integer, integer, integer, boolean, integer, boolean, integer, boolean, boolean, text, text) FROM public;



CREATE OR REPLACE FUNCTION aar.tmmtgt_client_build_remove(
    _clientid integer,
    _tmmtgtbuildid integer)
  RETURNS SETOF aar.tmmtgtbuild AS
$BODY$
BEGIN

-- uses tmmtgtbuildtypeid = 1

-- requests _buildid as a sanity check to be sure you are removing the record you want to remove

RETURN QUERY
DELETE FROM aar.tmmtgtbuild b
where clientid = _clientid
and tmmtgtbuildtypeid = 1
and tmmtgtbuildid = _tmmtgtbuildid
returning b.*;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;

GRANT EXECUTE ON FUNCTION aar.tmmtgt_client_build_remove(integer, integer) TO postgres;
GRANT EXECUTE ON FUNCTION aar.tmmtgt_client_build_remove(integer, integer) TO analytics_group;
REVOKE ALL ON FUNCTION aar.tmmtgt_client_build_remove(integer, integer) FROM public;


CREATE OR REPLACE FUNCTION aar.tmmtgt_client_build_schedule(
    _clientid integer,
    _builddate date,
    _importdelay integer DEFAULT NULL::integer,
    _datamonthsback integer DEFAULT NULL::integer,
    _mindrugs integer DEFAULT NULL::integer,
    _usecap boolean DEFAULT NULL::boolean,
    _numcap integer DEFAULT NULL::integer,
    _removeinvalidpatients boolean DEFAULT NULL::boolean,
    _minage integer DEFAULT NULL::integer,
    _rundatacheck boolean DEFAULT NULL::boolean,
    _useatebpatientid boolean DEFAULT true,
    _nrx text DEFAULT NULL::text,
    _job_type text DEFAULT 'Imports'::text)
  RETURNS SETOF aar.tmmtgtbuild AS
$BODY$
BEGIN

-- uses buildtypeid = 1
RETURN QUERY
INSERT INTO aar.tmmtgtbuild (clientid, tmmtgtbuildtypeid, builddate, importdelay, datamonthsback, mindrugs, usecap, numcap, removeinvalidpatients, minage, rundatacheck, useatebpatientid, nrx, job_type)
SELECT _clientid, 1, _builddate
  , coalesce(_importdelay,bc.importdelay)
  , coalesce(_datamonthsback, bc.datamonthsback)
  , coalesce(_mindrugs, bc.mindrugs)
  , coalesce(_usecap, bc.usecap)
  , coalesce(_numcap, bc.numcap)
  , coalesce(_removeinvalidpatients, bc.removeinvalidpatients)
  , coalesce(_minage, bc.minage)
  , coalesce(_rundatacheck, bc.rundatacheck)
  , coalesce(_useatebpatientid, bc.useatebpatientid)
  , coalesce(_nrx, bc.nrx)
  , coalesce(_job_type, bc.job_type)
FROM aar.tmmtgtbuildconfig bc
WHERE bc.clientid = _clientid and bc.tmmtgtbuildtypeid = 1
RETURNING tmmtgtbuild.*
;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;


GRANT EXECUTE ON FUNCTION aar.tmmtgt_client_build_schedule(integer, date, integer, integer, integer, boolean, integer, boolean, integer, boolean, boolean, text, text)
  TO postgres, etl_group, analytics_group, implementation_group;

REVOKE ALL ON FUNCTION aar.tmmtgt_client_build_schedule(integer, date, integer, integer, integer, boolean, integer, boolean, integer, boolean, boolean, text, text) FROM public;


-- METADATA
INSERT INTO aar.tmmtgtbuildstatus (tmmtgtbuildstatusid, name)
values (0,'NEW'),(1,'STARTED'),(2,'COMPLETED'),(3,'IMPORTED'), (4,'FAILED')
;

INSERT INTO aar.tmmtgtbuildstatus (tmmtgtbuildstatusid, name)
values (5,'ONHOLD')
returning *;

INSERT INTO aar.tmmtgtbuildschedule (tmmtgtbuildscheduleid,name)
values (1,'Incremental - 30 days'), (2, '10th of Following Month'), (3,'Incremental - 90 days')
;

INSERT INTO aar.tmmtgtbuildtype (tmmtgtbuildtypeid, name)
values (1,'TMM Targeted List Build')
;

-- VERIFY SCRIPT
/*
select * from aar.tmmtgt_client_build_config(2);
select * from aar.tmmtgtbuild;
SELECT * from aar.tmmtgt_build_update(2,1,'Started the build');
select * from  aar.tmmtgt_build_import_set(2,'/path/to/build/files');
select * from aar.tmmtgt_build_update(2,2,'Finished the build');
select * from aar.tmmtgt_build_update(2,4,'FAILED the build');

select * from aar.tmmtgt_build_import_get(2);

select * from aar.tmmtgt_build_update(2,2,'Back to a useable state');

select * from aar.tmmtgtbuild where clientid = 2;

select * from aar.tmmtgt_build_import_get(2);
select * from aar.tmmtgt_build_update(2,3,'Imported!');


select * from aar.tmmtgt_client_build_remove(2,1);

select * from aar.archivetmmtgtbuild;
select * from aar.tmmtgtbuild;
*/
COMMIT;

GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA aar TO implementation_group;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA aar TO implementation_group;
REVOKE UPDATE,DELETE,TRUNCATE,REFERENCES, TRIGGER ON aar.archivedeliverylog, aar.archiveetljob, aar.archiveetllink, aar.archiveetllog
	, aar.archivereportdeliveryinstance, aar.archivereportetlmap, aar.archivereportjob
	, aar.archivereportjobcustomizeoption, aar.archivereportjobcustomizeparticipant, aar.archivereportjobparticipant
	, aar.archivereportlog, aar.archivetmmtgtbuild, aar.archivetmmtgtbuildconfig
	FROM public, implementation_group, analytics_group, etl_group, aar_group;
