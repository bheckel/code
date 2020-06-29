...
    select count(1)
      into cnt
      from employee_base b
     where b.sas_empno = pSasEmpno;
  
    if (cnt = 0) Then
      dbms_output.put_line('User ' || pSasEmpno || ' is not valid');
      raise_application_error(-20999,
                              'User ' || pSasEmpno || ' is not valid',
                              TRUE);
    end if;
...
