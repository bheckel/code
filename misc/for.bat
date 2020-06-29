
:: Iterate over files
for %f in (*) do echo %f

:: Iterate over dirs
for /d %f in (*) do echo %f

:: Iterate over numbers 1 to 9 by twos
for /l % in (1,2,10) do ( @echo %i)

:: Cat files
for %f in (*.doc *.txt) do type %f 
