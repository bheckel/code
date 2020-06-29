echo Debugging harness for the grsuite.
echo Created: Thu, 02 Nov 2000 15:14:42 (Bob Heckel)
echo Start...

rem Messes up path on repeated runs.
set path=%path%;c:\local\bin

cmd /c c:\local\bin\grls.bat -h
cmd /c c:\local\bin\grls.bat swtest103
cmd /c c:\local\bin\grls.bat -i swtest103
cmd /c c:\local\bin\grls.bat -r /gr8xprog swtest103
cmd /c c:\local\bin\grls.bat -l bheckel swtest103
cmd /c c:\local\bin\grls.bat -d swtest103

cmd /c c:\local\bin\grget.bat -h
cmd /c c:\local\bin\grget.bat swtest103
cmd /c c:\local\bin\grget.bat -t swtest103
cmd /c c:\local\bin\grget.bat swtest103.tpg
cmd /c c:\local\bin\grget.bat -w c:\temp swtest103
cmd /c c:\local\bin\grget.bat -d swtest103

cmd /c c:\local\bin\grput.bat -h
cmd /c c:\local\bin\grput.bat swtest103
cmd /c c:\local\bin\grput.bat -f swtest103
cmd /c c:\local\bin\grput.bat -w c:\temp swtest103
cmd /c c:\local\bin\grput.bat -d swtest103

cmd /c c:\local\bin\grrel.bat -h
cmd /c c:\local\bin\grrel.bat -s swtest103
cmd /c c:\local\bin\grrel.bat -s swtest103 123
cmd /c c:\local\bin\grpatch.bat -h
cmd /c c:\local\bin\grpatch.bat -s swtest103
echo Finished...
