-- Adapted: 04-Dec-2020 (Bob Heckel--https://blogs.oracle.com/sql/updates-to-the-customer-orders-sample-schema)

-- Find all products ordered where the outstanding quantity to ship is greater than the stock available. Stockout.

with quantity_to_ship as (
  select store_id, product_id, sum(quantity) ordered_quantity
    from co.orders
    join co.order_items oi
   using ( order_id )
   where oi.shipment_id is null
  --and store_id = 1
    and order_status <> 'CANCELLED'
  group by store_id, product_id
)
select product_id, ordered_quantity, product_inventory
  from quantity_to_ship
  join co.inventory
 using ( store_id, product_id )
 where ordered_quantity > product_inventory;
