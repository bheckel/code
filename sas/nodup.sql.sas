data shipment_orders;
  length shipment $6 purchase_order $7 item_sku $12;
  input id  shipment  purchase_order $  item_sku $;
  cards;
3    435436     A123765          453987001201
46   435436     A123765          453987001201
354  435436     A123765          453987001201
23   981123     C543219          843209132209
613  981123     C543219          843209132209
354  435436     A123765          453987001201
354  435436     X123765          453987001201
  ;
run;
proc print data=_LAST_(obs=max); run;

 /* No pre-sort required */
proc sql;
  select distinct *
  from shipment_orders
  ;
quit;

 /* Same */
title 'nodup';
proc sort nodup out=t; by shipment purchase_order item_sku id; run;
proc print data=_LAST_ width=minimum heading=H;run;title;

title 'nodupkey';
proc sort nodup out=t; by shipment purchase_order item_sku; run;
proc print data=_LAST_ width=minimum heading=H;run;title;

title 'sql';
proc sql;
  select *
  from shipment_orders
  group by shipment, purchase_order, item_sku, id
  having count(*)>1
  ;
quit;
