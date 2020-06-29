
CHECK:
Scheduled ~/vhfaplots.bat runs 7am wednesdays on zebwd08D26987
vi -R //rtpsawnv0312/pucc/plots/Ventolin_HFA/CODE/LOG/0_MAIN_build_plots.log && ls -l '\\rtpsawnv0312\pucc\plots\Ventolin_HFA\OUTPUT\Formatted\cgm60'; echo; echo; ls -l '\\rtpsawnv0312\pucc\plots\Ventolin_HFA\OUTPUT\Formatted\cgm200'; echo; echo; ls -l '\\rtpsawnv0312\pucc\ADVAIR_HFA\Output_Compiled_Data\PLOTS\stability' && du -sk '\\rtpsawnv0312\pucc\plots\Ventolin_HFA\OUTPUT\Formatted\cgm60' '\\rtpsawnv0312\pucc\plots\Ventolin_HFA\OUTPUT\Formatted\cgm200' '\\rtpsawnv0312\pucc\ADVAIR_HFA\Output_Compiled_Data\PLOTS\stability' '\\rtpsawnv0312\pucc\ADVAIR_HFA\Output_Compiled_Data\PLOTS'

28864   \\rtpsawnv0312\pucc\plots\Ventolin_HFA\OUTPUT\Formatted\cgm60
56900   \\rtpsawnv0312\pucc\plots\Ventolin_HFA\OUTPUT\Formatted\cgm200
34680   \\rtpsawnv0312\pucc\ADVAIR_HFA\Output_Compiled_Data\PLOTS\stability
1980313 \\rtpsawnv0312\pucc\ADVAIR_HFA\Output_Compiled_Data\PLOTS

IF OK, RUN:
cd '\\rtpsawnv0312\pucc\plots\Ventolin_HFA\OUTPUT\Formatted\Plots60' && d=60_`date +%d%b%y`; for i in *.ppt; do mv "$i" `echo $i |sed "s/^........../${d}/g"`; done; st .; cd '\\rtpsawnv0312\pucc\plots\Ventolin_HFA\OUTPUT\Formatted\Plots200' && d=200_`date +%d%b%y`; for i in *.ppt; do mv "$i" `echo $i |sed "s/^.........../${d}/g"` && st .; done;

then run 3 200 & 3 60 PPT macros by hand, close Explorer


cd '\\rtpsawnv0312\pucc\ADVAIR_HFA\Output_Compiled_Data\PLOTS' && d=`date +%d%b%y`; for i in *.ppt; do mv "$i" `echo $i |sed "s/^......./${d}/g"` && st .; done;

then run 6 PPT macros and 1 DOC macro ("update entire table") by hand

