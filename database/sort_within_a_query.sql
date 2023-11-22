-- Show a max of 3 records for each object, sorted by itself
WITH v AS (
  SELECT ORA_DICT_OBJ_NAME, EVENT_DATE, LOGIN_USER, ORA_DICT_OBJ_TYPE, ORA_SYS_EVENT, OSUSER, MACHINE, PROGRAM, MODULE, CLIENT_IDENTIFIER, row_number() OVER (partition by ora_dict_obj_name, ora_dict_obj_type order by event_date desc) rn 
    FROM ddl_event 
   WHERE event_date>sysdate-30 AND upper(ora_dict_obj_name) in('ASP_PKG','ASP_PKG_TYPES','ACCOUNT_ASSIGNMENTS_TYPES','ACCOUNT_ASSIGNMENTS') AND ora_sys_event not in('GRANT','ALTER') and ora_dict_obj_type not in('SYNONYM','OBJECT PRIVILEGE')
)
select * from v where rn<3 order by 1, 2 desc, 4;
