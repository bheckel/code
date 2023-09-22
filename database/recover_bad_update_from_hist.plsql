-- Created: 21-Sep-2023 (Bob Heckel)
declare
  oldre  number;
  cnt    number := 0;
begin
  for rec in ( SELECT * FROM reference_employee WHERE audit_source='DMA-862' /*and rownum<9*/ ) loop
    select t.employee_id 
      into oldre
      from (
            SELECT a.employee_id, row_number() over (order by a.h_version desc) rn
              FROM reference_employee_hist a
             WHERE reference_employee_id=rec.reference_employee_id
      ) t
      where t.rn=1;
    DBMS_OUTPUT.put_line(rec.reference_employee_id || ':' || rec.reference_id || ' ' || rec.employee_id || ' restored to ' || oldre);
    update reference_employee set employee_id = oldre where reference_employee_id = rec.reference_employee_id and employee_id=rec.employee_id;
    cnt := cnt + sql%rowcount;
    rollback;
  end loop;
  DBMS_OUTPUT.put_line('fixed:'||cnt);
end;
