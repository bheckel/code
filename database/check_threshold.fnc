CREATE OR REPLACE FUNCTION THRESHOLD_LESS_THAN_AMOUNT(in_threshold IN NUMBER,
                                                      in_id        IN NUMBER)
  RETURN NUMBER AS

  isLessThanSumOfCols NUMBER := 0;

BEGIN
  BEGIN
    SELECT CASE
             WHEN (in_threshold < (NVL(cb.software, 0) + NVL(cb.managed, 0) + NVL(cb.education, 0))) THEN
              1
             ELSE
              0
           END
      INTO isLessThanSumOfCols
      FROM opp co
      JOIN oppx cb
        ON cb.my_id = co.my_id
     WHERE co.opp_id = in_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        isLessThanSumOfCols := 0;
  END;

  RETURN isLessThanSumOfCols;
END REFERENCE_THRESHOLD_LESS_THAN_COMIT_SALE_AMOUNT;
