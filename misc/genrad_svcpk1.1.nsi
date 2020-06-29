; Modified: Thu 22 Mar 2001 16:32:14 (Bob Heckel)

Name "Service Pack 1.1"
CRCCheck on
SetCompress auto
DirText "Setup has determined the optimal location to install."
OutFile genrad_svcpk1.1.exe
SetOverwrite on
InstallDir c:\local
ComponentText "GenRad Custom Applications"
InstType "Select Only One"
InstType "Desktop System"
InstType "Tester System"
InstType "Tester TSL System"

; Dummy required to make this crap work.
Section "Select Desktop or Tester"
SectionIn 1

; TODO no way to trap an error like this...
;MessageBox MB_OK "Sorry, you must select one item from the list.  Please restart the installer.  Exiting."

Section "Desktop"
SectionIn 2
SetOutPath $INSTDIR\bin
; Assuming that most recent grsuite files are in these directories.
File p:\Projects\grsuite\bin\gr*.bat
SetOutPath $INSTDIR\lib
File p:\Projects\grsuite\lib\gr*.pl
MessageBox MB_OK "Sucessfully updated desktop files.  Click to close installer."

Section "Tester without TSL Handler"
SectionIn 3
SetOutPath $INSTDIR\bin
File p:\Projects\grsuite\bin\gr*.bat
SetOutPath $INSTDIR\lib
File p:\Projects\grsuite\lib\gr*.pl
MessageBox MB_OK "Sucessfully updated non-TSL tester files.  Click OK to close installer."

Section "Tester with TSL Handler"
SectionIn 4
SetOutPath $INSTDIR\bin
File p:\Projects\grsuite\bin\gr*.bat
File p:\Projects\tslhack\automation.bat
SetOutPath $INSTDIR\lib
File p:\Projects\grsuite\lib\gr*.pl
MessageBox MB_OK "Sucessfully updated TSL tester files.  Click OK to close installer."

