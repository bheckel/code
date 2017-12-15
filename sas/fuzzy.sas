
options nocenter ls=180 ps=max;
data t;
  infile cards truncover;
  input idx ln $80.;
  cards;
01 Brashear's Pharmacy Inverness
02 Brashear Pharmacy Lacanto
03 Tims Pharmacy Beavercreek
04 Clark's Rx-Cedarville
05 Clark's Rx-Brookville
06 Clark's Rx-Sullivan
07 Clark's Rx-Farmington
08 Clark's Rx-Bourbon
09 Clark's Rx-Ironton
10 Clark's Rx-Huber Heights
11 Clark's Rx-Roanoke Pharmacy
12 Clark's Rx-Metamora
13 Clark's Rx-Low Cost Pharmacy
14 D&H Drugstore Broadway
15 D&H Drugstore Paris
16 Medicine Shoppe 1198
17 Lehan Drugs
18 Kinston Clinic Pharmacy
19 Daniel Pharmacy
20 Kramer Pharmacy
21 Reinbeck Pharmacy
22 Erickson Pharmacy
23 Hometown Pharmacy #3
24 The Prescription Shop
25 Bremo Pharmacy
26 Dusini Drug Inc
27 Medicine Shoppe 1430
28 Osborn Drugs
29 Scheffe Prescription Shop
30 Bowen South Pharmacy
31 Bowen Pharmacy
32 Langley Drug
33 Perry Pharmacy
34 Riggs Drugs
35 Stones Corner
36 Lindburg Pharmacy
37 Austin Drugs
38 Cardinal Drug Store
39 Porter Drug
40 Spoon Drug
41 Lindburg Pharmacy North
42 Osborn Drug2
43 Paul Jones Drug
44 Wagner Pharmacy
45 Breen's Thrifty White Drug
46 Wall's Health Mart Pharmacy
47 Wall's Medicine Center
48 Medicap 8321
49 Medicap 8255
50 Medicap 8290
51 Healthsmart Pharmacy Conover
52 Healthfirst Pharmacy
53 Healthsmart Pharmacy Newton
54 Healthsmart Pharmacy
55 Healthsmart Pharmacy Claremont
56 Healthsmart Pharmacy Catawba
57 Healthsmart Pharmacy Startown
;
run;
/* title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;run;title; */

options ls=180 ps=max; libname func '/Drugs/FunctionalData' access=readonly;
proc sql;
  create table t2 as
  select a.*, b.long_client_name, b.clientid, spedis(ln, long_client_name) as score
  from t a, func.clients_shortname_lookup b
  where (ln eq long_client_name) or (spedis(ln, long_client_name) le 15)
  order by score
  ;
quit;
/* title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;run;title; */


proc sql;
  create table t3 as
  select a.*, b.*
  from t a left join t2 b on a.idx=b.idx
  order by idx
  ;
quit;
/* title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;run;title; */


data t4;
  set t3;
  by idx;
  /* Single match indicates a direct "0.0" hit */
  if first.idx and last.idx then do;
    close=1;
  end;
  /* Get rid of the fuzzy matches if we already have a direct hit */
  else do;
    if ln ne long_client_name then close=0; else close=1;
  end;

  if close eq 0 then delete;
run;


 /* Make no-matches re-appear */
proc sql;
  create table t5 as
  select a.idx, a.ln, b.*
  from t a left join t4 b on a.idx=b.idx
  ;
quit;  
title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;run;title;
