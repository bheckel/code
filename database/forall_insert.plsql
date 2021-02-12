
DECLARE
  TYPE idTable IS TABLE OF NUMBER;
  id_table idTable;

  CURSOR rowCursor IS
    SELECT mkc_invoice_id
      FROM DBG_INVOICE_REVENUE6
     where sdm_business_key is not null;
BEGIN
  OPEN rowCursor;

  LOOP
    FETCH rowCursor BULK COLLECT
      INTO id_table LIMIT 100000;
  
    EXIT WHEN id_table.COUNT = 0;
  
    FORALL i IN 1 .. id_table.COUNT
      INSERT INTO MKC_REVENUE_BASE
        (USM_MON_RATE_XR,
         HASH_COLUMN_XF,
         UPDATED_XF,
         USD_MON_RATE_XF,
         USM_MON_RATE_XF,
         USX_MON_RATE_XF,
         HASH_COLUMN_IN,
         CUSTOMER_NAME_UD,
         AMOUNT_APPLIED_PS)
        SELECT USM_MON_RATE_XR,
               HASH_COLUMN_XF,
               UPDATED_XF,
               USD_MON_RATE_XF,
               USM_MON_RATE_XF,
               USX_MON_RATE_XF,
               HASH_COLUMN_IN,
               AMOUNT_APPLIED_PS
          FROM BDG_INVOICE_REVENUE6
         WHERE MKC_INVOICE_ID = id_table(i);
  
    COMMIT;
  END LOOP;

  COMMIT;

  CLOSE rowCursor;
END;
