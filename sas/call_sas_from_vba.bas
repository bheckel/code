''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'     Name: call_sas_from_vba.bas
'
'  Summary: Control SAS from within Excel VBA
'
'  Adapted: Fri 20 Apr 2007 09:10:23 (Bob Heckel - Phil Mason email tips)
' Modified: Mon 21 May 2007 15:15:41 (Bob Heckel)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Option Explicit

'''''''''''''''''''''''
' Raw SAS statements

Sub sasexp()
  Dim OleSAS As Object
  Set OleSAS = CreateObject("SAS.Application")
  OleSAS.Visible = True
  OleSAS.Submit ("libname sasdata 'C:\Program Files\SAS Institute\SAS\V8\core\sashelp';")
  OleSAS.Submit ("proc print data=sasdata.shoes; run;")
  OleSAS.Quit
  Set OleSAS = Nothing
  '''ChDir "C:\"
  '''Workbooks.Open Filename:="C:\sasexp.csv"
End Sub


'''''''''''''''''''''''
' "Stored procedure"

' Save this in c:/temp as t.sas

' libname l 'c:/temp';
' 
' data t;
'   set sashelp.shoes(obs=10);
' run;
' 
' data l.t2;
'   set t;
' run;


' Then try this:

Sub RunSAS()
  Dim OleSAS As Object
  Set OleSAS = CreateObject("SAS.Application")
  OleSAS.Visible = True
  OleSAS.Submit ("%include 'c:/temp/t.sas';")
  OleSAS.Quit
  Set OleSAS = Nothing
End Sub
