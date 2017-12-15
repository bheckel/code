
proc sort data=Valtrex_batch_data_2007_API;
  by Batch Material_Number API_Lot_Number;
run;
proc transpose data=Valtrex_batch_data_2007_API out=lotlookup;
  by  Batch;
  var API_Lot_Number;
run;

/* TODO calc 5 cols w/diction instead & clean trailing */
data lotlookup;
  set lotlookup;
  commadelimlot = col1 || ',' || col2 || ',' ||  col3 || ',' || col4 || ',' || col5;
  commadelimlot = compress(commadelimlot);
run;
