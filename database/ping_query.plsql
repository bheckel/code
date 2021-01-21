-------------------------------------------------------
-- Modified: 20-Jan-2021 (Bob Heckel)
-------------------------------------------------------

declare
  x date; xx date;
  y number;
  z number;
begin
  SELECT INACTIVE_SINCE into x FROM DOMAIN_INDEX_STATUS_V WHERE idx_name='ACCOUNT_SEARCH_BING_IX';
  
  if x is not null then
    y := 0;
    DBMS_OUTPUT.put_line('inactive, continuing');

    while y = 0 loop
      execute immediate 'SELECT INACTIVE_SINCE FROM DOMAIN_INDEX_STATUS_V WHERE idx_name=''ACCOUNT_SEARCH_BING_IX'''
        into xx;
        
      DBMS_OUTPUT.put_line('looping '||xx);
      
      if xx is not null then
        DBMS_OUTPUT.put_line('xx is notnull ' || xx);
        SYS.DBMS_SESSION.sleep(30);
        DBMS_OUTPUT.put_line('...sleeping ');
      else -- it is null
        y := 1;
        -- TODO send email
        DBMS_OUTPUT.put_line('active again, done at ' || sysdate);
      end if;
    end loop;
  else
    DBMS_OUTPUT.put_line('active, done');
  end if;
end;
