" Prepare code for production

:%substitute/%let DIRROOT = c:\\cygwin\\home\\bheckel\\projects\\datapost\\tmp\\VALTREX_Caplets;//g

:%substitute/\*\*\*%let DIRROOT = \\\\rtpsawnv0312\\pucc\\VALTREX_Caplets;/%let DIRROOT = \\\\rtpsawnv0312\\pucc\\VALTREX_Caplets;/g

:%substitute/\/\*\*\*proc printto LOG=".CODE\\log\\.PRODUCT..log" NEW PRINT=".CODE\\log\\.PRODUCT..lst" NEW; run;\*\*\*\//proc printto LOG="!!!!!CODE\\log\\!!!!!PRODUCT..log" NEW PRINT="!!!!!CODE\\log\\!!!!!PRODUCT..lst" NEW; run;/g
" Hack to avoid '&' interpolation
:%substitute/!!!!!/\&/g

:%substitute/%let DELCSVS = \w\+;  \/\* yes or no \*\//%let DELCSVS = yes;  \/\* yes or no \*\//g

:%substitute/\*\*\*endsas/endsas/g

" TODO 
""":e excel
:echo 'now edit excel2csv.bat'
