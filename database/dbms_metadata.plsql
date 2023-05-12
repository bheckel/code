-- SQL Developer
--  ddl mytbl
-- or
BEGIN
 DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'STORAGE',false);
 DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SEGMENT_ATTRIBUTES',false);
 DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'PRETTY',true);
 DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);
 DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'REF_CONSTRAINTS',false);
 DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'TABLESPACE',false);
 DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SIZE_BYTE_KEYWORD',false);
END;

-- set long 10000
SELECT dbms_metadata.get_ddl('TABLE','EMP','ADMIN') FROM DUAL;

---

--https://connor-mcdonald.com/2022/06/08/comparing-two-database-objects-for-differences/
-- set long 99999
with t as(
  select dbms_metadata_diff.compare_alter_xml('TABLE','KMC_REVENUE_FULL_BOB','KMC_REVENUE_FULL_PART') xml
    from dual
)
select xt.txt||';'
  from t,
     xmltable(xmlnamespaces(default 'http://xmlns.oracle.com/ku'), '/ALTER_XML/ALTER_LIST/ALTER_LIST_ITEM/SQL_LIST/SQL_LIST_ITEM'
              passing xmltype(t.xml)
              columns
              txt     varchar2(255)  path 'TEXT'
     ) xt;

---

select DBMS_METADATA_DIFF.compare_alter('TABLE','JMPCSV','JMPCSV',network_link2=>'ATLAS_TEST_RW') x from dual;

SELECT dbms_metadata.get_ddl('TABLE','JMPCSV','ESTARS') FROM DUAL;
