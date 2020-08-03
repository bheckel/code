-- DROP FUNCTION public.increment(integer);
CREATE OR REPLACE FUNCTION public.increment(i integer)
  RETURNS integer AS
$BODY$
BEGIN
      RETURN i + 2;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.increment(integer)
  OWNER TO bheckel;


--then 

select * from analytics.increment(i:=5)

---


-- Function: analytics.tmm_build_import_get(integer)

-- DROP FUNCTION analytics.tmm_build_import_get(integer);

CREATE OR REPLACE FUNCTION analytics.tmm_build_import_get(_clientid integer)
  RETURNS SETOF analytics.build AS
$BODY$
BEGIN

-- buildtypeid = 1

-- returns the import data, so long as things look good! (buildstatusid = 2)
RETURN QUERY
SELECT *
FROM analytics.build
where clientid = _clientid
AND buildtypeid = 1
AND buildstatusid = 2
AND builddate <= current_date
AND builddate + importdelay <= current_date
AND importpath IS NOT NULL
;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION analytics.tmm_build_import_get(integer)
  OWNER TO postgres;
GRANT EXECUTE ON FUNCTION analytics.tmm_build_import_get(integer) TO postgres;
GRANT EXECUTE ON FUNCTION analytics.tmm_build_import_get(integer) TO analytics_group;
REVOKE ALL ON FUNCTION analytics.tmm_build_import_get(integer) FROM public;


---


-- Function: analytics.tmm_build_import_set(integer, text)

-- DROP FUNCTION analytics.tmm_build_import_set(integer, text);

CREATE OR REPLACE FUNCTION analytics.tmm_build_import_set(
    _clientid integer,
    _importpath text)
  RETURNS SETOF analytics.build AS
$BODY$
BEGIN

-- buildtypeid = 1

-- sets the import and determines the projected import date

-- at present, importdelay is an integer that we add to current_date...
-- future state will probably have logic associated with it somehow...

RETURN QUERY
UPDATE analytics.build b
SET importpath = _importpath, projectedimport = current_date + importdelay
WHERE b.clientid = _clientid
AND b.buildtypeid = 1
RETURNING b.*
;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION analytics.tmm_build_import_set(integer, text)
  OWNER TO postgres;
GRANT EXECUTE ON FUNCTION analytics.tmm_build_import_set(integer, text) TO postgres;
GRANT EXECUTE ON FUNCTION analytics.tmm_build_import_set(integer, text) TO analytics_group;
REVOKE ALL ON FUNCTION analytics.tmm_build_import_set(integer, text) FROM public;

