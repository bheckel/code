On Error resume Next

'Declare Variable for Shell Object
Dim objShell
Set objShell = WScript.CreateObject("Wscript.Shell")

'Declare Variable for Filesystem Object
Dim objFileSys
Set objFileSys = WScript.CreateObject("Scripting.FileSystemObject")

'Declare Variable for Network Object
Dim objNetwork
Set objNetwork = WScript.CreateObject("WScript.Network")

'Set Constants for file access (read, write, append)
Const ForReading = 1, ForWriting = 2, ForAppending = 8

Const HKEY_CURRENT_USER = &H80000001
Const HKEY_LOCAL_MACHINE = &H80000002

LastBackslashPosition = InStrRev(WScript.ScriptFullName, "\")
ScriptSourcePath = Mid(WScript.ScriptFullName,1,LastBackslashPosition)

'open generic log file
Set ProcessLog = objFileSys.OpenTextFile("c:\windows\logs\PerformanceCounterCheck.log", ForWriting, 1)
ProcessLog.Writeline("")
ProcessLog.Writeline(MyDateTime & " " & "Begin process...")
ProcessLog.Writeline(MyDateTime & " " & "")

'Check for Existence of PerfOS key, assume they are missing

PerfOSKeyExist = False
PerfOSDisableExist = False
PerfProcKeyExist = False
PerfProcDisableExist = False


ProcessLog.Writeline(MyDateTime & " " & "Retrieving Subkeys from HKLM\SYSTEM\CurrentControlSet\Services")

strComputer = "."
 
Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & _ 
    strComputer & "\root\default:StdRegProv")
 
strKeyPath = "SYSTEM\CurrentControlSet\Services"
oReg.EnumKey HKEY_LOCAL_MACHINE, strKeyPath, arrSubKeys
 
For Each subkey In arrSubKeys
	If Ucase(subkey) = "PERFOS" then
		ProcessLog.Writeline(MyDateTime & " " & "Found PerfOS subkey...")

		PerfOSKeyExist = True
		
		
		'Check for Existence of PerfOS\Disable Performance Counter Value
		CounterValue = "HKLM\SYSTEM\CurrentControlSet\Services\PerfOS\Performance\Disable Performance Counters"
		checkValue = objShell.RegRead(CounterValue)

		If Err.number <> 0 Then
		    PerfOSDisableExist = False	
			ProcessLog.Writeline(MyDateTime & " " & "Disable Performance Counter value missing...")

		Else 
		    ProcessLog.Writeline(MyDateTime & " " & "Disable Performance Counter value Found. Value: " & checkValue)
			PerfOSDisableExist = True
			PerfOSDisableValue = checkValue
		End If

		Err.clear
    End If
	
	If Ucase(subkey) = "PERFPROC" then
		ProcessLog.Writeline(MyDateTime & " " & "Found PerfProc subkey...")

		PerfProcKeyExist = True	

		'Check for Existence of PerfOS\Disable Performance Counter Value
		CounterValue = "HKLM\SYSTEM\CurrentControlSet\Services\PerfProc\Performance\Disable Performance Counters"
		checkValue = objShell.RegRead(CounterValue)

		If Err.number <> 0 Then
		    PerfProcDisableExist = False	
			ProcessLog.Writeline(MyDateTime & " " & "Disable Performance Counter value missing...")

		Else 
			ProcessLog.Writeline(MyDateTime & " " & "Disable Performance Counter value Found. Value: " & checkValue)
			PerfProcDisableExist = True
			PerfProcDisableValue = checkValue
		End If
		Err.clear

	End If
	
Next

If PerfOSKeyExist = false then
	ProcessLog.Writeline(MyDateTime & " " & "PerfOS subkey missing...")
End If

If PerfProfKeyExist = false then
	ProcessLog.Writeline(MyDateTime & " " & "PerfProc subkey missing...")
End If



	
strOutput = GetFQDN & "," & MyDate
strOutput = strOutput & "," & PerfOSKeyExist & "," & PerfOSDisableExist & "," & PerfOSDisableValue
strOutput = strOutput & "," & PerfProcKeyExist & "," & PerfProcDisableExist & "," & PerfProcDisableValue

ProcessLog.Writeline(MyDateTime & " " & strOutput)

'Write to central server
ProcessLog.Writeline(MyDateTime & " " & "")
ProcessLog.Writeline(MyDateTime & " " & "*************************************************************************")
ProcessLog.Writeline(MyDateTime & " " & "*    Reporting                                                          *")
ProcessLog.Writeline(MyDateTime & " " & "*************************************************************************")
ProcessLog.Writeline(MyDateTime & " " & "")

'get the log server, based on geographical location
Country = Ucase(objShell.ExpandEnvironmentStrings("%COUNTRY%"))
ProcessLog.Writeline(MyDateTime & " " & "Country identified as: " & Country)

ServerLogPath = ""

If Len(Country) > 1 then

	ProcessLog.Writeline(MyDateTime & " " & "Using THInfo.ini to retrieve Primary log server name.")
	'get server info from THInfo.ini based on country
	tmpLogServerPath = LTrim(RTrim(ReadINI(ScriptSourcePath & "\THInfo.ini",Country,"PRIMARY LOG SERVER")))
	ProcessLog.Writeline(MyDateTime & " " & "Server read as: " & tmpLogServerPath)
	If Instr(tmpLogServerPath,"001") <> 0 then   'valid server
		ServerLogPath = "\\" & tmpLogServerPath & "\Log\DisablePerformance\machinelog\"
	End If

	ServerLogName = "\\" & tmpLogServerPath & "\Log\DisablePerformance\machinelog\" & funGetEnv("%ComputerName%") & ".log"
	ProcessLog.Writeline(MyDateTime & " " & "Server log name set to: " & ServerLogName)
	
End If


If objFileSys.FolderExists(ServerLogPath) Then
	'Assume the summary log to already exist on the server
	ProcessLog.WriteLine(MyDateTime & " " & "Server logging area accessible...")

	ServerLogName = "\\" & tmpLogServerPath & "\Log\DisablePerformance\machinelog\" & funGetEnv("%ComputerName%") & ".log"
	
	Dim ServerLog
	Set ServerLog = objFileSys.OpenTextFile(ServerLogName,ForWriting,True) 
	Serverlog.Writeline strOutput
	Serverlog.Close
	
	ProcessLog.WriteLine(MyDateTime & " " & "Machine data logged to central server.")
	
	
Else
	ProcessLog.WriteLine(MyDateTime & " " & "Unable to read/access server based machine log.")
	
End if

ProcessLog.Writeline(MyDateTime & " " & "End process")
ProcessLog.Writeline(MyDateTime & " " & "")

Wscript.Quit


Function MyDatetime
	'Set date/Time format for logging
	MyDateTime =  DAY(date()) & "-" & MonthName(Month(Date()),True) & "-" & Year(Date()) & " " & FormatDateTime(Time(), 3) &  " " 
End Function

Function MyDate
	'Set date format for logging
	MyDate =  DAY(date()) & "-" & MonthName(Month(Date()),True) & "-" & Year(Date())
End Function


Function GetFQDN

	Dim objWMIService 
    Dim colSettings 
    Dim objComputer 

	strComputer = "."

    Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2") 
    Set colSettings = objWMIService.ExecQuery("Select Domain from Win32_ComputerSystem") 


    For Each objComputer In colSettings 
      GetFQDN = objComputer.Name & "." & objComputer.Domain
    Next 

	

End Function


Function ReadINI(File, Section, Item) 
	On Error Resume Next
	Dim FormattedLine

	ReadIni=""

	If objFileSys.FileExists(File) then

		'Open Ini File
		Set ini = objFileSys.OpenTextFile(File, ForReading, False)

		Do While ini.AtEndofStream = False

			'Read Line
			line = ini.ReadLine
			
			'Check for Section
			If Instr(UCase(line), "["&Trim(UCase(Section))&"]") <> 0 then
				
				'Read Line	 
				If ini.AtEndofStream = False then line=ini.ReadLine

				'Check for Item	
					Do While left(line,1)<>"["
					
						If Instr(line, "=") <> 0 then
					    	EqualPosition = Instr(line, "=")
			    			FormattedLine = Rtrim(Ltrim(Mid(Line,1,EqualPosition-1)))
							If UCase(FormattedLine) = UCase(Item) then
			    				ReadIni = Rtrim(Ltrim(Mid(Line,EqualPosition+1,Len(Line) - EqualPosition)))
			    				Exit Function
			    			End if
			    		End if
			    			 
			    			 'Read Line
			    		If ini.AtEndofStream = False then
							line=ini.ReadLine
						Else
						  Exit Do
						End If
					Loop
				exit do
			End If
		loop
	  
		'Close Ini File
		ini.Close
	  
	End If 

End Function

Private Function funGetEnv(strEnvVar)
'                ~~~~~~~~~
   funGetEnv = objShell.ExpandEnvironmentStrings(strEnvVar)
   If funGetEnv = strEnvVar Then funGetEnv = "na"
End Function



'' SIG '' Begin signature block
'' SIG '' MIIVAgYJKoZIhvcNAQcCoIIU8zCCFO8CAQExCzAJBgUr
'' SIG '' DgMCGgUAMGcGCisGAQQBgjcCAQSgWTBXMDIGCisGAQQB
'' SIG '' gjcCAR4wJAIBAQQQTvApFpkntU2P5azhDxfrqwIBAAIB
'' SIG '' AAIBAAIBAAIBADAhMAkGBSsOAwIaBQAEFJx3F98w0YY+
'' SIG '' 1IsN/OttRuAd1Cf8oIIRCjCCA3owggJioAMCAQICEDgl
'' SIG '' 1/r4Ya+e9JDnJrXWWtUwDQYJKoZIhvcNAQEFBQAwUzEL
'' SIG '' MAkGA1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlTaWduLCBJ
'' SIG '' bmMuMSswKQYDVQQDEyJWZXJpU2lnbiBUaW1lIFN0YW1w
'' SIG '' aW5nIFNlcnZpY2VzIENBMB4XDTA3MDYxNTAwMDAwMFoX
'' SIG '' DTEyMDYxNDIzNTk1OVowXDELMAkGA1UEBhMCVVMxFzAV
'' SIG '' BgNVBAoTDlZlcmlTaWduLCBJbmMuMTQwMgYDVQQDEytW
'' SIG '' ZXJpU2lnbiBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNp
'' SIG '' Z25lciAtIEcyMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCB
'' SIG '' iQKBgQDEtfJSFbyIhmApFkpbL0uRa4eR8zVUWDXq0TZe
'' SIG '' Yk1SUTRxwntmHYnI3SrEagr2N9mYdJH2kq6wtXaW8alK
'' SIG '' Y0VHLmsLkk5LK4zuWEqL1AfkGiz4gqpY2c1C8y3Add6N
'' SIG '' q8eOHZpsTAiVHt7b72fhcsJJwp5gPOHivhajY3hpFHut
'' SIG '' LQIDAQABo4HEMIHBMDQGCCsGAQUFBwEBBCgwJjAkBggr
'' SIG '' BgEFBQcwAYYYaHR0cDovL29jc3AudmVyaXNpZ24uY29t
'' SIG '' MAwGA1UdEwEB/wQCMAAwMwYDVR0fBCwwKjAooCagJIYi
'' SIG '' aHR0cDovL2NybC52ZXJpc2lnbi5jb20vdHNzLWNhLmNy
'' SIG '' bDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAOBgNVHQ8B
'' SIG '' Af8EBAMCBsAwHgYDVR0RBBcwFaQTMBExDzANBgNVBAMT
'' SIG '' BlRTQTEtMjANBgkqhkiG9w0BAQUFAAOCAQEAUMVLyCSA
'' SIG '' 3+QNJMLeGrGhAqGmgi0MgxWBNwqCDiywWhdhtdgF/ojb
'' SIG '' 8ZGRs1YaQKbrkr44ObB1NnQ6mE/kN7qZicqVQh2wuceg
'' SIG '' jVfg+tVkBEI1TgHRM6IXyE2qJ8fy4YZMAjhNg3jG/FPg
'' SIG '' 6+AGh92klp5eDJjipb6/goXDYOHfrSjYx6VLZNrHG1u9
'' SIG '' rDkI1TgioTOLL4qa67wHIT9EQQkHtWUcJLxI00SA66HP
'' SIG '' yQK0FM9UxxajgFz5eT5dcn2IF54sQ6LKU859PfYqOrhP
'' SIG '' lAClbQqDXfleU/QYs1cPcMP79a2VoA4X3sQWgGDJDytu
'' SIG '' hgTx6/R4J9EFxe40W165STLyMzCCA8QwggMtoAMCAQIC
'' SIG '' EEe/GZXfjVJGQ/fbbUgNMaQwDQYJKoZIhvcNAQEFBQAw
'' SIG '' gYsxCzAJBgNVBAYTAlpBMRUwEwYDVQQIEwxXZXN0ZXJu
'' SIG '' IENhcGUxFDASBgNVBAcTC0R1cmJhbnZpbGxlMQ8wDQYD
'' SIG '' VQQKEwZUaGF3dGUxHTAbBgNVBAsTFFRoYXd0ZSBDZXJ0
'' SIG '' aWZpY2F0aW9uMR8wHQYDVQQDExZUaGF3dGUgVGltZXN0
'' SIG '' YW1waW5nIENBMB4XDTAzMTIwNDAwMDAwMFoXDTEzMTIw
'' SIG '' MzIzNTk1OVowUzELMAkGA1UEBhMCVVMxFzAVBgNVBAoT
'' SIG '' DlZlcmlTaWduLCBJbmMuMSswKQYDVQQDEyJWZXJpU2ln
'' SIG '' biBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIENBMIIBIjAN
'' SIG '' BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqcqypMzN
'' SIG '' IK8KfYmsh3XwtE7x38EPv2dhvaNkHNq7+cozq4QwiVh+
'' SIG '' jNtr3TaeD7/R7Hjyd6Z+bzy/k68Numj0bJTKvVItq0g9
'' SIG '' 9bbVXV8bAp/6L2sepPejmqYayALhf0xS4w5g7EAcfrkN
'' SIG '' 3j/HtN+HvV96ajEuA5mBE6hHIM4xcw1XLc14NDOVEpkS
'' SIG '' ud5oL6rm48KKjCrDiyGHZr2DWFdvdb88qiaHXcoQFTyf
'' SIG '' hOpUwQpuxP7FSt25BxGXInzbPifRHnjsnzHJ8eYiGdvE
'' SIG '' s0dDmhpfoB6Q5F717nzxfatiAY/1TQve0CJWqJXNroh2
'' SIG '' ru66DfPkTdmg+2igrhQ7s4fBuwIDAQABo4HbMIHYMDQG
'' SIG '' CCsGAQUFBwEBBCgwJjAkBggrBgEFBQcwAYYYaHR0cDov
'' SIG '' L29jc3AudmVyaXNpZ24uY29tMBIGA1UdEwEB/wQIMAYB
'' SIG '' Af8CAQAwQQYDVR0fBDowODA2oDSgMoYwaHR0cDovL2Ny
'' SIG '' bC52ZXJpc2lnbi5jb20vVGhhd3RlVGltZXN0YW1waW5n
'' SIG '' Q0EuY3JsMBMGA1UdJQQMMAoGCCsGAQUFBwMIMA4GA1Ud
'' SIG '' DwEB/wQEAwIBBjAkBgNVHREEHTAbpBkwFzEVMBMGA1UE
'' SIG '' AxMMVFNBMjA0OC0xLTUzMA0GCSqGSIb3DQEBBQUAA4GB
'' SIG '' AEpr+epYwkQcMYl5mSuWv4KsAdYcTM2wilhu3wgpo17I
'' SIG '' ypMT5wRSDe9HJy8AOLDkyZNOmtQiYhX3PzchT3AxgPGL
'' SIG '' OIez6OiXAP7PVZZOJNKpJ056rrdhQfMqzufJ2V7duyuF
'' SIG '' PrWdtdnhV/++tMV+9c8MnvCX/ivTO1IbGzgn9z9KMIIE
'' SIG '' vzCCBCigAwIBAgIQQZGhWjl4389JZWY4HUx1wjANBgkq
'' SIG '' hkiG9w0BAQUFADBfMQswCQYDVQQGEwJVUzEXMBUGA1UE
'' SIG '' ChMOVmVyaVNpZ24sIEluYy4xNzA1BgNVBAsTLkNsYXNz
'' SIG '' IDMgUHVibGljIFByaW1hcnkgQ2VydGlmaWNhdGlvbiBB
'' SIG '' dXRob3JpdHkwHhcNMDQwNzE2MDAwMDAwWhcNMTQwNzE1
'' SIG '' MjM1OTU5WjCBtDELMAkGA1UEBhMCVVMxFzAVBgNVBAoT
'' SIG '' DlZlcmlTaWduLCBJbmMuMR8wHQYDVQQLExZWZXJpU2ln
'' SIG '' biBUcnVzdCBOZXR3b3JrMTswOQYDVQQLEzJUZXJtcyBv
'' SIG '' ZiB1c2UgYXQgaHR0cHM6Ly93d3cudmVyaXNpZ24uY29t
'' SIG '' L3JwYSAoYykwNDEuMCwGA1UEAxMlVmVyaVNpZ24gQ2xh
'' SIG '' c3MgMyBDb2RlIFNpZ25pbmcgMjAwNCBDQTCCASIwDQYJ
'' SIG '' KoZIhvcNAQEBBQADggEPADCCAQoCggEBAL687rx+74Pr
'' SIG '' 4DdP+wMQOL4I0ox9nfqSfxkMwmvuQlKM3tMcSBMl6sFj
'' SIG '' evlRZe7Tqjv18JScK/vyZtQk2vf1n24ZOTa80KN2CB4i
'' SIG '' JyRsOJEn4oRJrhuKof0lgiwQMOhxqyjod0pR8ezN+PBU
'' SIG '' 1G/A420Kj9nYZI1jsi1OJ/aFDv5t4ymZ4oVHfC2Gf+hX
'' SIG '' j61nwjMykRMg/KkjFJptwoRLdmgE1XEsXSH6iA0m/R8t
'' SIG '' kSvnAVVN8m01KILf2WtcttbZqoH9X82DumOd0CL8qTtC
'' SIG '' abKOOrW8tJ4PXsTqLIKLKP1TCJbdtQEg0fmlGOfA7lFw
'' SIG '' N+G2BUhSSG846sPobHtEhLsCAwEAAaOCAaAwggGcMBIG
'' SIG '' A1UdEwEB/wQIMAYBAf8CAQAwRAYDVR0gBD0wOzA5Bgtg
'' SIG '' hkgBhvhFAQcXAzAqMCgGCCsGAQUFBwIBFhxodHRwczov
'' SIG '' L3d3dy52ZXJpc2lnbi5jb20vcnBhMDEGA1UdHwQqMCgw
'' SIG '' JqAkoCKGIGh0dHA6Ly9jcmwudmVyaXNpZ24uY29tL3Bj
'' SIG '' YTMuY3JsMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEF
'' SIG '' BQcDAzAOBgNVHQ8BAf8EBAMCAQYwEQYJYIZIAYb4QgEB
'' SIG '' BAQDAgABMCkGA1UdEQQiMCCkHjAcMRowGAYDVQQDExFD
'' SIG '' bGFzczNDQTIwNDgtMS00MzAdBgNVHQ4EFgQUCPVR6Pv+
'' SIG '' PT1kNnxoz1t4qN+5xTcwgYAGA1UdIwR5MHehY6RhMF8x
'' SIG '' CzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5WZXJpU2lnbiwg
'' SIG '' SW5jLjE3MDUGA1UECxMuQ2xhc3MgMyBQdWJsaWMgUHJp
'' SIG '' bWFyeSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eYIQcLrk
'' SIG '' HRDZKTS2OMp7A8y6vzANBgkqhkiG9w0BAQUFAAOBgQCu
'' SIG '' Ohe4SntV+mRV7ECk7UlBkJmcibyvLh3KeCP5HBkPf+to
'' SIG '' vDLZiDje3D/TibQ/sYKW8aRauu0uJtPefAFuAAoApAaS
'' SIG '' EUgJQPkcGHlnIyTgu9XhUK4b9Q7d4C6BzYCjbFJPkXVV
'' SIG '' iroi8tLqQXWIL2NVfR5UWpVZytk0gcBfXvZ6tTCCBP0w
'' SIG '' ggPloAMCAQICEC7KNu8ILLGXLtIbgT7o0zMwDQYJKoZI
'' SIG '' hvcNAQEFBQAwgbQxCzAJBgNVBAYTAlVTMRcwFQYDVQQK
'' SIG '' Ew5WZXJpU2lnbiwgSW5jLjEfMB0GA1UECxMWVmVyaVNp
'' SIG '' Z24gVHJ1c3QgTmV0d29yazE7MDkGA1UECxMyVGVybXMg
'' SIG '' b2YgdXNlIGF0IGh0dHBzOi8vd3d3LnZlcmlzaWduLmNv
'' SIG '' bS9ycGEgKGMpMDQxLjAsBgNVBAMTJVZlcmlTaWduIENs
'' SIG '' YXNzIDMgQ29kZSBTaWduaW5nIDIwMDQgQ0EwHhcNMDYw
'' SIG '' NTA0MDAwMDAwWhcNMDkwNzIzMjM1OTU5WjCBwDELMAkG
'' SIG '' A1UEBhMCVVMxFTATBgNVBAgTDFBlbm5zeWx2YW5pYTEY
'' SIG '' MBYGA1UEBxMPS2luZyBvZiBQcnVzc2lhMRgwFgYDVQQK
'' SIG '' FA9HbGF4b1NtaXRoS2xpbmUxPjA8BgNVBAsTNURpZ2l0
'' SIG '' YWwgSUQgQ2xhc3MgMyAtIE1pY3Jvc29mdCBTb2Z0d2Fy
'' SIG '' ZSBWYWxpZGF0aW9uIHYyMQwwCgYDVQQLFANTQ1MxGDAW
'' SIG '' BgNVBAMUD0dsYXhvU21pdGhLbGluZTCBnzANBgkqhkiG
'' SIG '' 9w0BAQEFAAOBjQAwgYkCgYEAtJjGqSbt5xLzqirknAU8
'' SIG '' MYT+4vZcyZy0Dc8MXTdpO1yfQtUWwpD250001b9ID/D5
'' SIG '' Yjzig27yojTP/ITnJjARFkR6/i/0pZ+8z+1vtcDnzpnj
'' SIG '' frOTBoX3tRwpHfTXDyR+BGAC+QFECfS2wJjZQgozu4yi
'' SIG '' J1hcjH2028BJ5sJ62/8CAwEAAaOCAX8wggF7MAkGA1Ud
'' SIG '' EwQCMAAwDgYDVR0PAQH/BAQDAgeAMEAGA1UdHwQ5MDcw
'' SIG '' NaAzoDGGL2h0dHA6Ly9DU0MzLTIwMDQtY3JsLnZlcmlz
'' SIG '' aWduLmNvbS9DU0MzLTIwMDQuY3JsMEQGA1UdIAQ9MDsw
'' SIG '' OQYLYIZIAYb4RQEHFwMwKjAoBggrBgEFBQcCARYcaHR0
'' SIG '' cHM6Ly93d3cudmVyaXNpZ24uY29tL3JwYTATBgNVHSUE
'' SIG '' DDAKBggrBgEFBQcDAzB1BggrBgEFBQcBAQRpMGcwJAYI
'' SIG '' KwYBBQUHMAGGGGh0dHA6Ly9vY3NwLnZlcmlzaWduLmNv
'' SIG '' bTA/BggrBgEFBQcwAoYzaHR0cDovL0NTQzMtMjAwNC1h
'' SIG '' aWEudmVyaXNpZ24uY29tL0NTQzMtMjAwNC1haWEuY2Vy
'' SIG '' MB8GA1UdIwQYMBaAFAj1Uej7/j09ZDZ8aM9beKjfucU3
'' SIG '' MBEGCWCGSAGG+EIBAQQEAwIEEDAWBgorBgEEAYI3AgEb
'' SIG '' BAgwBgEBAAEB/zANBgkqhkiG9w0BAQUFAAOCAQEAeQos
'' SIG '' ejQGHj3hhf04dtAVtjmUi0e+MhMCPePCr5sNNkn+lxNW
'' SIG '' kdzJbjLoVdpL1BoLOuDWme4+iKc/fGK9eC30QkHou5/A
'' SIG '' +RbafCZFwMCTxU01ypf4afGP6q0wtrn7LIOBJItwZNbj
'' SIG '' xtgz0DvNryv4KKufWlUkUtGcHK1N4wbRD8zqpsY9IuuC
'' SIG '' 9X+pNdTcdRrvwqfE0wKjiRoDptkfR7zblTr/Jz5sNYz8
'' SIG '' aCUjVY3uyCEYPprdimRqxNBz75ddw5p+GlV2HLiqRiLu
'' SIG '' Z7xryp7WJf+Hs+yuNItfhzDOuroBT2exEQOOUlWuPyad
'' SIG '' s8XEwLFKU9SSUSGzRKfIqpUYwKCUwTGCA2QwggNgAgEB
'' SIG '' MIHJMIG0MQswCQYDVQQGEwJVUzEXMBUGA1UEChMOVmVy
'' SIG '' aVNpZ24sIEluYy4xHzAdBgNVBAsTFlZlcmlTaWduIFRy
'' SIG '' dXN0IE5ldHdvcmsxOzA5BgNVBAsTMlRlcm1zIG9mIHVz
'' SIG '' ZSBhdCBodHRwczovL3d3dy52ZXJpc2lnbi5jb20vcnBh
'' SIG '' IChjKTA0MS4wLAYDVQQDEyVWZXJpU2lnbiBDbGFzcyAz
'' SIG '' IENvZGUgU2lnbmluZyAyMDA0IENBAhAuyjbvCCyxly7S
'' SIG '' G4E+6NMzMAkGBSsOAwIaBQCgcDAQBgorBgEEAYI3AgEM
'' SIG '' MQIwADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAc
'' SIG '' BgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkq
'' SIG '' hkiG9w0BCQQxFgQUdtCjnZD7CZ2IZAylGoZbK0Q+3wgw
'' SIG '' DQYJKoZIhvcNAQEBBQAEgYAFoeegsQou5aHbjZ9w0BOo
'' SIG '' N3Ms/2FmYVKdWOBzRRU96yXNqRNmlRPGf2q3cl+q7Fr4
'' SIG '' JcEV0YsdZp6ttsvT820W7lCqOS2pbhQKvebSFhCxEq+b
'' SIG '' cEPCj1yWdJEkbAbPuPtNJp8LE1xzmaqdrNAnpY2N/4va
'' SIG '' XwGEli36SkD4653Av6GCAX4wggF6BgkqhkiG9w0BCQYx
'' SIG '' ggFrMIIBZwIBATBnMFMxCzAJBgNVBAYTAlVTMRcwFQYD
'' SIG '' VQQKEw5WZXJpU2lnbiwgSW5jLjErMCkGA1UEAxMiVmVy
'' SIG '' aVNpZ24gVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBDQQIQ
'' SIG '' OCXX+vhhr570kOcmtdZa1TAMBggqhkiG9w0CBQUAoFkw
'' SIG '' GAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG
'' SIG '' 9w0BCQUxDxcNMDgwOTMwMTM0OTMwWjAfBgkqhkiG9w0B
'' SIG '' CQQxEgQQyB3+sXQnZunshDGn1BwM+zANBgkqhkiG9w0B
'' SIG '' AQEFAASBgHwTVspCz8VadCRVhunTvG8ccuT48Ijy1qpN
'' SIG '' aPP26nA75lJpg1pLBm62TAfr88Oo2z7LNqPrQb9Y55lW
'' SIG '' po65OGTl3n9v1gcNtwD+o0b3PFXSjBmK+G4tE7V5HXFg
'' SIG '' FCvYhsRKHSZC4986WOTaSjplV2lyQgr5AHlN8CbM+N7W
'' SIG '' NKF9
'' SIG '' End signature block
