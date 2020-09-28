-- Adapted: 22-Sep-2020 (Bob Heckel--Oracle DevGym)

-- Determine the pay (salary + commission) for each employee

/*
    EMP_ID     SALARY
---------- ----------
        10     110000
        20     120000  <--salary only
        30     130000


    EMP_ID COMMISSION
---------- ----------
        10      10000
        30      30000
        40      40000  <--commission only
*/

-- FAIL Inner join misses 40 & 20
SELECT NVL(c.emp_id, s.emp_id) emp_id
     , NVL(s.salary, 0) + NVL(c.commission, 0) pay
  FROM plch_salaries s
     , plch_commissions c
 WHERE c.emp_id = s.emp_id
ORDER BY emp_id;
/*
    EMP_ID        PAY
---------- ----------
        10     120000
        30     160000
*/

-- FAIL Right join misses 40
SELECT NVL(c.emp_id, s.emp_id) emp_id
     , NVL(s.salary, 0) + NVL(c.commission, 0) pay
  FROM plch_salaries s
     , plch_commissions c
 WHERE c.emp_id(+) = s.emp_id
ORDER BY emp_id
/*
    EMP_ID        PAY
---------- ----------
        10     120000
        20     120000
        30     160000
*/

-- FAIL Left join misses 20
SELECT NVL(c.emp_id, s.emp_id) emp_id
     , NVL(s.salary, 0) + NVL(c.commission, 0) pay
  FROM plch_salaries s
     , plch_commissions c
 WHERE c.emp_id = s.emp_id(+)
ORDER BY emp_id;
/*
    EMP_ID        PAY
---------- ----------
        10     120000
        30     160000
        40      40000
*/        


-- Pre-9i Oracle FULL JOIN solution. An outer join "one way", then an outer join "the other way" but 
-- filtering away those that would be in the first join, and finally UNION ALL
SELECT emp_id, pay
  FROM (
    SELECT s.emp_id, s.salary + NVL(c.commission, 0) pay
       FROM plch_salaries s, plch_commissions c
      WHERE c.emp_id(+) = s.emp_id

    UNION ALL

    SELECT c.emp_id, NVL(s.salary, 0) + c.commission pay
      FROM plch_salaries s, plch_commissions c
     WHERE c.emp_id = s.emp_id(+)
       AND s.emp_id IS NULL
  )
ORDER BY emp_id

-- Same. Stack the 2 compensation tables then use an aggregate on it. Possibly more efficient.
SELECT emp_id, SUM(pay) as pay
  FROM (
    SELECT emp_id, salary     as pay FROM plch_salaries
    UNION ALL
    SELECT emp_id, commission as pay FROM plch_commissions 
  )
GROUP BY emp_id
ORDER BY emp_id;

-- Same
SELECT COALESCE(c.emp_id, s.emp_id) emp_id,
       COALESCE(s.salary, 0) + COALESCE(c.commission, 0) pay
  FROM plch_salaries s FULL OUTER JOIN plch_commissions c ON c.emp_id=s.emp_id
 ORDER BY emp_id;

-- Same best?
SELECT emp_id,
       COALESCE(s.salary, 0) + COALESCE(c.commission, 0) pay
  FROM plch_salaries s FULL OUTER JOIN plch_commissions c USING (emp_id)
 ORDER BY emp_id;

/*
    EMP_ID        PAY
---------- ----------
        10     120000
        20     120000
        30     160000
        40      40000
*/
