select TO_DATE('15-may-2006 06:00:01','dd-mon-yyyy hh24:mi:ss') from dual;

TO_DATE('10-12-06','MM-DD-YY')

TO_DATE('jan 2007','MON YYYY')

TO_DATE('2007/05/31','YYYY/MM/DD')

TO_DATE('12-31-2007 12:15','MM-DD-YYYY HH:MI')

TO_DATE('2006,091,00:00:00' , 'YYYY,DDD,HH24:MI:SS')

TO_DATE('15-may-2006 06:00:01','dd-mon-yyyy hh24:mi:ss')

TO_DATE('022002','mmyyyy')

TO_DATE('12319999','MMDDYYYY')

TO_DATE(substr( collection_started,1,12),'DD-MON-YY HH24')

TO_DATE('2004/10/14 21', 'yyyy/mm/dd hh24')

TO_DATE(First_Load_Time, 'yyyy-mm-dd/hh24:mi:ss'))*24*60)

select TO_TIMESTAMP('1960-01-01 00:00:00.0','YYYY-MM-DD HH24:MI:SS.FF') + NUMTODSINTERVAL(mrstart, 'DAY') from IPD_LGCY;

