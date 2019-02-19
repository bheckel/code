c:/winnt/System32/net.exe stop "World Wide Web Publishing Service"
c:/winnt/System32/net.exe stop "FTP Publishing Service"
c:/winnt/System32/net.exe stop "Simple Mail Transfer Protocol (SMTP)"
c:/winnt/System32/net.exe stop "HTTP SSL"
c:/winnt/System32/net.exe stop "IIS Admin Service"
c:/winnt/System32/net.exe stop "SAS IntrNet Load Manager" 
d:\sas_programs\startstopsas\pv.exe -kf sas.exe
d:\sas_programs\startstopsas\pv.exe -kf mtx.exe

sleep 10

c:/winnt/System32/net.exe start "IIS Admin Service"
c:/winnt/System32/net.exe start "World Wide Web Publishing Service"
c:/winnt/System32/net.exe start "FTP Publishing Service"
c:/winnt/System32/net.exe start "Simple Mail Transfer Protocol (SMTP)"
c:/winnt/System32/net.exe start "HTTP SSL"
c:/winnt/System32/net.exe start "SAS IntrNet Load Manager" 
