
create or replace package ORION32822 is

  -- ----------------------------------------------------------------------------
  -- Author: Bob Heckel (boheck)
  -- Date:   19-Oct-18
  -- Usage:  Add invitations based on a user-provided list of contact IDs
  -- JIRA:   ORION-32822
  -- ----------------------------------------------------------------------------
  g_event_id    PLS_INTEGER  := 2884300;  /* event_base.eventname is "EMEA: CSS 2018 October wave" */
  g_status_date VARCHAR2(10) := '10/29/2018';
    
  PROCEDURE invite1;
  
  PROCEDURE invite2;
  
  PROCEDURE invite_test;

end ORION32822;
/
create or replace package body ORION32822 is
      
  PROCEDURE invite1 IS
    
    l_limit_group  PLS_INTEGER;
    l_tab_size     PLS_INTEGER;
    l_tab_size_tot PLS_INTEGER;

    CURSOR c1 IS
      select uid_event_contact.nextval AS seq, t.contact_ID, g_event_id AS event_id, 0 AS requestedInformation, SYSDATE AS created, 0 AS createdby, SYSDATE AS updated, 0 AS updatedby, 0 AS h_version, 1 AS current_status, to_date(g_status_date,'mm/dd/yyyy') AS status_date
      from zzzorion32822 t
      where not exists (select 1 from event_contact ec where ec.contact_id = t.contact_id and ec.EVENT_ID = g_event_id)
      ;

    TYPE t1 IS TABLE OF c1%ROWTYPE;
    l_lst t1;
            
    BEGIN  
      
      l_limit_group  := 0;
      l_tab_size     := 0;
      l_tab_size_tot := 0;
      OPEN c1;
      LOOP
        FETCH c1 BULK COLLECT INTO l_lst LIMIT 500;  
        
        l_limit_group := l_limit_group + 1;
        l_tab_size := l_lst.COUNT;
        l_tab_size_tot := l_tab_size_tot + l_tab_size;
        dbms_output.put_line(to_char(sysdate, 'DD-Mon-YYYY HH24:MI:SS') || ': iteration ' || l_limit_group || ' processed ' || l_tab_size || ' records' || ' total ' || l_tab_size_tot);
        
        EXIT WHEN l_tab_size = 0;
        
        FORALL i IN 1 .. l_tab_size
          INSERT INTO EVENT_CONTACT_BASE (event_contact_ID, contact_ID, event_ID, requestedInformation, created, createdBy, updated, updatedBy, h_version, current_status, status_date) 
          VALUES (l_lst(i).seq, l_lst(i).contact_ID,l_lst(i).event_id, l_lst(i).requestedInformation, l_lst(i).created, l_lst(i).createdby, l_lst(i).updated, l_lst(i).updatedby, l_lst(i).h_version, l_lst(i).current_status, l_lst(i).status_date)
          ;
          
      END LOOP;

      CLOSE c1;
      
      MAINT.logdatachange(step => 0, status => 'ORION-32822: Update interaction status for Global CSS', release => 'N/A', defect => 'N/A', startTime => SYSDATE, do_commit => 0); 

  END;
  

  PROCEDURE invite2 IS
    
    l_limit_group  PLS_INTEGER;
    l_tab_size     PLS_INTEGER;
    l_tab_size_tot PLS_INTEGER;

    /* ec_weight = 1 is "Invited" per EventContactStatusEnum.java */
    CURSOR c2 IS
      select uid_event_contact_status.nextval as seq, event_contact_ID, 1 as ec_weight, sysdate as ec_date, sysdate as created, 0 as createdby, sysdate as updated, 0 as updatedby, 0 as h_version
      from event_contact_base ec, zzzorion32822 t
      where ec.contact_id=t.contact_id and ec.event_id = g_event_id;    

    TYPE t2 IS TABLE OF c2%ROWTYPE;
    l_lst2 t2;
            
    BEGIN  
      
      l_limit_group  := 0;
      l_tab_size     := 0;
      l_tab_size_tot := 0;
      OPEN c2;
      LOOP
        FETCH c2 BULK COLLECT INTO l_lst2 LIMIT 500;  
        
        l_limit_group := l_limit_group + 1;
        l_tab_size := l_lst2.COUNT;
        l_tab_size_tot := l_tab_size_tot + l_tab_size;
        dbms_output.put_line(to_char(sysdate, 'DD-Mon-YYYY HH24:MI:SS') || ': iteration ' || l_limit_group || ' processed ' || l_tab_size || ' records' || ' total ' || l_tab_size_tot);
        
        EXIT WHEN l_tab_size = 0;
        
        FORALL i IN 1 .. l_tab_size
          INSERT INTO EVENT_CONTACT_STATUS (event_contact_status_id, event_contact_id, ec_weight, ec_date, created, createdBy, updated, updatedBy, h_version) 
          VALUES (l_lst2(i).seq, l_lst2(i).event_contact_id, l_lst2(i).ec_weight, l_lst2(i).ec_date, l_lst2(i).created, l_lst2(i).createdby, l_lst2(i).updated, l_lst2(i).updatedby, l_lst2(i).h_version)
          ; 
      END LOOP;

      CLOSE c2;

      MAINT.logdatachange(step => 0, status => 'ORION-32822: Update interaction status for Global CSS', release => 'N/A', defect => 'N/A', startTime => SYSDATE, do_commit => 0); 

  END;

  
  PROCEDURE invite_test IS
    l_cnt1 PLS_INTEGER;
    l_cnt2 PLS_INTEGER;

    BEGIN

      select count(1) into l_cnt1 FROM EVENT_CONTACT_BASE where audit_source = 'ACRYNT\l10e523';
      select count(1) into l_cnt2 FROM EVENT_CONTACT_STATUS where audit_source = 'ACRYNT\l10e523';
      dbms_output.put_line('BEFORE ' || l_cnt1 || ' ' || l_cnt2);
          
      dbms_output.put_line('xxxxx1xxxxxx');
      invite1;
      dbms_output.put_line('xxxxx2xxxxxx');
      invite2;

      select count(1) into l_cnt1 FROM EVENT_CONTACT_BASE where audit_source = 'ACRYNT\l10e523';
      select count(1) into l_cnt2 FROM EVENT_CONTACT_STATUS where audit_source = 'ACRYNT\l10e523';
      dbms_output.put_line(' AFTER ' || l_cnt1 || ' ' || l_cnt2);

/*      dbms_output.put_line('xxxxxxxxxxxx');
      FOR rec IN ( select * FROM EVENT_CONTACT_BASE where audit_source = 'ACRYNT\l10e523' and rownum<9 ) LOOP
        dbms_output.put_line('AFTER: ' || rpad(rec.event_contact_id,10,' ') || ' ' || rec.contact_id || ' updated: ' || rec.updated || ' updatedby: ' || rpad(rec.updatedby,8,' '));
      END LOOP;
      FOR rec IN ( select * FROM EVENT_CONTACT_STATUS where audit_source = 'ACRYNT\l10e523' and rownum<9 ) LOOP
        dbms_output.put_line('AFTER: ' || rpad(rec.event_contact_status_id,10,' ') || ' ' || rec.event_contact_id || ' updated: ' || rec.updated || ' updatedby: ' || rpad(rec.updatedby,8,' '));
      END LOOP;
*/
      
      --ROLLBACK;
      COMMIT;
  
  END;
end ORION32822;
/
