options nocenter ls=180 ps=max; libname l '~/bob';
data t;
  input clid :10.;
  cards;
2 
7 
10 
12 
17 
19 
22 
55 
118 
137 
190 
256 
329 
395 
583 
599 
605 
627 
641 
651 
652 
664 
668 
670 
678 
680 
684 
685 
686 
690 
691 
699 
713 
715 
718 
752 
757 
760 
764 
769 
771 
776 
777 
778 
782 
788 
826 
828 
833 
838 
841 
848 
854 
874 
884 
888 
889 
891 
893 
925 
926 
934 
935 
936 
938 
952 
955 
963 
964 
969 
1011 
1014 
1027 
1028 
1031 
1033 
1043 
1047 
;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;

options ls=180 ps=max; libname func '/Drugs/FunctionalData' access=readonly;
proc sql;
  create table t2 as
  select a.*, b.short_client_name, b.long_client_name
  from t a left join func.clients_shortname_lookup b
  on a.clid=b.clientid
  ;
quit;
/***title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;run;title;***/
proc print data=_LAST_(obs=max) width=minimum heading=H NOobs;var clid long_client_name; run;
