These don't start the website:
net start iisadmin  <---ok on cygwin, start first
net start w3svc  <---ok on cygwin, start second
...but should stop them when done or inetinfo.exe keeps running

Start : Pgms : Admin : Personal Web Manager : Start (may take several clicks)

test if up:
http://localhost/iishelp/iis/misc/default.asp
or 
http://localhost/iishelp

parsifal - run pages in c:/inetpub/wwwroot/myweb/t.asp


Webserver config (log location, timeouts, etc.) -
Start : Admin : Internet Serv Mgr : rightclick "Default Web Site" : Properties
