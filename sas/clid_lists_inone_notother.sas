data potential_new_items;
  infile cards;
  input clid :8.;
  cards;
861
862
863
864
865
866
867
868
869
870
875
876
877
878
879
880
881
882
883
884
885
886
887
888
1165
1166
1167
1168
1169
1170
1171
1172
1173
1174
1175
1176
1177
1178
1179
1180
1181
1182
1183
1184
1185
;
run;

data existing_items;
  infile cards;
  input clid :8.;
  cards;
  861
  862
  863
  866
  867
  868
  870
  875
  876
  878
  879
  880
  882
  883
  884
  885
  886
  887
  888
 1165
 1166
 1167
 1168
 1169
 1170
 1171
 1172
 1173
 1174
 1175
 1176
 1177
 1178
 1179
 1180
 1181
 1182
 1183
 1184
 1185
;
run;

proc sql;
  create table t as
  select a.* 
  from potential_new_items a 
  where clid not in (select distinct clid from existing_items)
  ;
quit;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;

