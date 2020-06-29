
CREATE PROCEDURE purge_sales
    @order_id VARCHAR(20) = NULL
AS
IF @order_id IS NULL
    RAISERROR 50001 "Error! Please supply transaction order number."
ELSE
    DELETE temp_sales 
    -- The datediff function tells us if the order date in the ord_date value
    -- is more than 2 years older than the current date stored in getdate().
    WHERE  ord_num  = @order_id
      AND  DATEDIFF(year, ord_date, GETDATE()) > 2
GO
